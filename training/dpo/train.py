"""DPO on the pairs from build_pairs.py: for each train task, raise the
probability of the model's full-credit attempt relative to its attempt that
missed, measured against the untrained model so it doesn't drift elsewhere.

    python3 training/dpo/train.py PAIRS.jsonl OUT_DIR

Same LoRA, memory tricks and checkpoints as training/sft/train.py. The
reference model is the base model itself: the LoRA switched off. Its log
probabilities are computed once and cached in OUT_DIR/reference.json.

The DPO loss of a pair needs the chosen and the rejected transcript at once,
and two 30K-token backward passes don't fit on one A100. But its gradient is
a number times each transcript's log probability gradient, so each step
first scores both transcripts without gradients, works out those numbers,
then backpropagates one transcript at a time.
"""
import json
import math
import os
import random
import sys
import time
from pathlib import Path

import torch
import torch.nn.functional as F
from transformers import AutoTokenizer

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "sft"))
from train import (MAX_TOKENS, MODEL, REVISION, SEED, load_checkpoint, load_model,  # noqa: E402
                   save_checkpoint, schedule, sequence_loss, tokenize)

BETA = float(os.environ.get("BETA", "0.1"))
LR = float(os.environ.get("LR", "2e-5"))
EPOCHS = int(os.environ.get("EPOCHS", "1"))
ACCUMULATE = int(os.environ.get("ACCUMULATE", "4"))
SAVE_EVERY = int(os.environ.get("SAVE_EVERY", "2"))


def sequences(tokenizer, tools, side):
    """The transcript's (ids, labels, number of trained tokens) sequences."""
    return [(ids, labels, sum(label != -100 for label in labels[1:]))
            for ids, labels in tokenize(tokenizer, {"tools": tools, "messages": side["messages"]})]


def log_prob(decoder, lm_head, seqs, scale=None):
    """Summed log probability of the transcript's assistant tokens. With
    scale, also backpropagates scale times it, one sequence at a time."""
    total = 0.0
    for ids, labels, count in seqs:
        if scale is None:
            with torch.no_grad():
                total -= sequence_loss(decoder, lm_head, ids, labels).item() * count
        else:
            value = -sequence_loss(decoder, lm_head, ids, labels) * count
            (value * scale).backward()
            total += value.item()
    return total


def main(pairs_path, out_dir):
    out, ckpt = Path(out_dir), Path(out_dir) / "checkpoint"
    out.mkdir(parents=True, exist_ok=True)
    tokenizer = AutoTokenizer.from_pretrained(MODEL, revision=REVISION)

    pairs, transcripts, dropped = [], {}, 0
    for line in open(pairs_path):
        pair = json.loads(line)
        sides = [(pair[side]["trial"], sequences(tokenizer, pair["tools"], pair[side])) for side in ("chosen", "rejected")]
        if any(len(ids) > MAX_TOKENS for _, seqs in sides for ids, _, _ in seqs):
            dropped += 1
            continue
        transcripts.update(sides)
        pairs.append((sides[0][0], sides[1][0]))
    print(f"{len(pairs)} pairs over {len(transcripts)} transcripts, {dropped} with a transcript "
          f"longer than {MAX_TOKENS} tokens dropped", flush=True)

    model, decoder, lm_head, params = load_model()
    model.train()

    reference_path = out / "reference.json"
    reference = json.loads(reference_path.read_text()) if reference_path.exists() else {}
    with model.disable_adapter():
        for trial, seqs in transcripts.items():
            if trial not in reference:
                reference[trial] = log_prob(decoder, lm_head, seqs)
                reference_path.write_text(json.dumps(reference))
    print(f"reference log probabilities for {len(reference)} transcripts", flush=True)

    optimizer = torch.optim.AdamW(params, lr=LR, weight_decay=0.0, betas=(0.9, 0.99))
    total_steps = math.ceil(len(pairs) * EPOCHS / ACCUMULATE)
    scheduler = torch.optim.lr_scheduler.LambdaLR(optimizer, schedule(total_steps))
    order = []
    for epoch in range(EPOCHS):
        epoch_order = list(range(len(pairs)))
        random.Random(SEED + epoch).shuffle(epoch_order)
        order += epoch_order
    step = load_checkpoint(ckpt, model, optimizer, scheduler)

    started = time.time()
    while step < total_steps:
        batch = order[step * ACCUMULATE:(step + 1) * ACCUMULATE]
        losses, margins = [], []
        for index in batch:
            chosen, rejected = pairs[index]
            # How far the model has moved each transcript's log probability from the reference.
            gain_chosen = log_prob(decoder, lm_head, transcripts[chosen]) - reference[chosen]
            gain_rejected = log_prob(decoder, lm_head, transcripts[rejected]) - reference[rejected]
            margin = BETA * (gain_chosen - gain_rejected)
            losses.append(-F.logsigmoid(torch.tensor(margin)).item())
            margins.append(margin)
            # d loss / d log p(chosen) = -BETA * sigmoid(-margin), and the opposite for rejected.
            weight = BETA * torch.sigmoid(torch.tensor(-margin)).item() / len(batch)
            log_prob(decoder, lm_head, transcripts[chosen], scale=-weight)
            log_prob(decoder, lm_head, transcripts[rejected], scale=weight)
        torch.nn.utils.clip_grad_norm_(params, 1.0)
        optimizer.step()
        scheduler.step()
        optimizer.zero_grad(set_to_none=True)
        step += 1
        print(f"step {step}/{total_steps} loss {sum(losses) / len(losses):.4f} "
              f"margin {sum(margins) / len(margins):+.3f} "
              f"right {sum(m > 0 for m in margins)}/{len(margins)} "
              f"lr {scheduler.get_last_lr()[0]:.2e} {time.time() - started:.0f}s", flush=True)
        if step % SAVE_EVERY == 0 or step == total_steps:
            save_checkpoint(ckpt, model, optimizer, scheduler, step)

    model.save_pretrained(out / "adapter")
    print(f"saved {out / 'adapter'}", flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
