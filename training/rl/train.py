"""Policy-gradient RL on the groups from build_groups.py: on each train task,
make the attempts that scored above the task's average more likely and the
ones below it less likely, in proportion to how far above or below they were.

    python3 training/rl/train.py GROUPS.jsonl OUT_DIR

This is GRPO's group baseline (without its division by the standard
deviation) with GSPO's sequence-level ratio. The attempts
were sampled from the starting model (the LoRA switched off), so each
attempt's ratio is how much more likely the trained model makes it than the
starting model did, per assistant token: exp((log p - log p_start) / tokens).
An attempt stops pushing once its ratio leaves 1 ± CLIP in the direction it
was pushing, so one round can't move the model far from what it sampled.

One optimizer step per task: all of its attempts, so their advantages
balance out within the step. Same LoRA, memory tricks and checkpoints as
training/sft/train.py; the starting model's log probabilities are cached in
OUT_DIR/start.json.
"""
import json
import math
import os
import random
import sys
import time
from collections import defaultdict
from pathlib import Path

import torch
from transformers import AutoTokenizer

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "sft"))
from train import (MAX_TOKENS, MODEL, REVISION, SEED, load_checkpoint, load_model,  # noqa: E402
                   save_checkpoint, schedule, sequence_loss, tokenize)

LR = float(os.environ.get("LR", "1e-4"))
CLIP = float(os.environ.get("CLIP", "0.1"))
EPOCHS = int(os.environ.get("EPOCHS", "1"))
SAVE_EVERY = int(os.environ.get("SAVE_EVERY", "2"))


def log_prob(decoder, lm_head, seqs, scale=None):
    """Summed log probability of the attempt's assistant tokens. With scale,
    also backpropagates scale times it, one sequence at a time (as in DPO)."""
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


def main(groups_path, out_dir):
    out, ckpt = Path(out_dir), Path(out_dir) / "checkpoint"
    out.mkdir(parents=True, exist_ok=True)
    tokenizer = AutoTokenizer.from_pretrained(MODEL, revision=REVISION)

    attempts, by_task, dropped = {}, defaultdict(list), 0
    for line in open(groups_path):
        attempt = json.loads(line)
        seqs = [(ids, labels, sum(label != -100 for label in labels[1:]))
                for ids, labels in tokenize(tokenizer, attempt)]
        if any(len(ids) > MAX_TOKENS for ids, _, _ in seqs):
            dropped += 1
            continue
        tokens = sum(count for _, _, count in seqs)
        attempts[attempt["trial"]] = (seqs, tokens, attempt["advantage"])
        by_task[attempt["task"]].append(attempt["trial"])
    tasks = sorted(by_task)
    print(f"{len(attempts)} attempts over {len(tasks)} tasks, {dropped} longer than {MAX_TOKENS} "
          f"tokens dropped", flush=True)

    model, decoder, lm_head, params = load_model()
    model.train()

    start_path = out / "start.json"
    start = json.loads(start_path.read_text()) if start_path.exists() else {}
    with model.disable_adapter():
        for trial, (seqs, _, _) in attempts.items():
            if trial not in start:
                start[trial] = log_prob(decoder, lm_head, seqs)
                start_path.write_text(json.dumps(start))
    print(f"starting-model log probabilities for {len(start)} attempts", flush=True)

    optimizer = torch.optim.AdamW(params, lr=LR, weight_decay=0.0, betas=(0.9, 0.99))
    order = []
    for epoch in range(EPOCHS):
        epoch_order = list(tasks)
        random.Random(SEED + epoch).shuffle(epoch_order)
        order += epoch_order
    total_steps = len(order)
    scheduler = torch.optim.lr_scheduler.LambdaLR(optimizer, schedule(total_steps))
    step = load_checkpoint(ckpt, model, optimizer, scheduler)

    started = time.time()
    while step < total_steps:
        task = order[step]
        trials = by_task[task]
        objectives, ratios, clipped = [], [], 0
        for trial in trials:
            seqs, tokens, advantage = attempts[trial]
            ratio = math.exp((log_prob(decoder, lm_head, seqs) - start[trial]) / tokens)
            ratios.append(ratio)
            bounded = min(max(ratio, 1 - CLIP), 1 + CLIP)
            objectives.append(min(ratio * advantage, bounded * advantage))
            if ratio * advantage > bounded * advantage:
                clipped += 1  # past the bound in the direction it pushes: no gradient
                continue
            # d(ratio * advantage) / d log p = advantage * ratio / tokens; minimise its negative.
            log_prob(decoder, lm_head, seqs, scale=-advantage * ratio / tokens / len(trials))
        torch.nn.utils.clip_grad_norm_(params, 1.0)
        optimizer.step()
        scheduler.step()
        optimizer.zero_grad(set_to_none=True)
        step += 1
        print(f"step {step}/{total_steps} {task} objective {sum(objectives) / len(objectives):+.4f} "
              f"ratio {min(ratios):.3f}-{max(ratios):.3f} clipped {clipped}/{len(trials)} "
              f"lr {scheduler.get_last_lr()[0]:.2e} {time.time() - started:.0f}s", flush=True)
        if step % SAVE_EVERY == 0 or step == total_steps:
            save_checkpoint(ckpt, model, optimizer, scheduler, step)

    model.save_pretrained(out / "adapter")
    print(f"saved {out / 'adapter'}", flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
