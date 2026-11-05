"""LoRA SFT of Qwen3.5-27B on the agent transcripts from build_dataset.py.

    python3 training/sft/train.py DATA.jsonl OUT_DIR

Loss is on the assistant turns only (reasoning, text and bash calls); the
system prompt, task and tool outputs are context. The base weights stay in
bf16, the same weights vLLM serves. The loss is computed in chunks so the
full vocabulary logits for a long transcript never sit in memory at once.

Spot VMs get preempted, so the adapter, optimizer and data order are saved to
OUT_DIR/checkpoint every SAVE_EVERY optimizer steps, and a rerun resumes from
there. The finished adapter lands in OUT_DIR/adapter.
"""
import contextlib
import json
import math
import os
import random
import sys
import time
from pathlib import Path

import torch
import torch.nn.functional as F
from torch.utils.checkpoint import checkpoint
from peft import LoraConfig, get_peft_model, set_peft_model_state_dict, get_peft_model_state_dict
from transformers import AutoModelForImageTextToText, AutoTokenizer

MODEL = os.environ.get("MODEL", "Qwen/Qwen3.5-27B")
REVISION = os.environ.get("MODEL_REVISION", "fc05daec18b0a78c049392ed2e771dde82bdf654")
EPOCHS = int(os.environ.get("EPOCHS", "2"))
LR = float(os.environ.get("LR", "1e-4"))
ACCUMULATE = int(os.environ.get("ACCUMULATE", "8"))
MAX_TOKENS = int(os.environ.get("MAX_TOKENS", "32768"))
# Above this length the activations saved for the backward pass go to CPU
# memory, so a long transcript fits beside the 54 GB of bf16 weights
# (a 32K-token transcript checkpoints about 21 GB of activations).
OFFLOAD_ABOVE = int(os.environ.get("OFFLOAD_ABOVE", "4096"))
RANK = int(os.environ.get("LORA_RANK", "32"))
SAVE_EVERY = int(os.environ.get("SAVE_EVERY", "2"))
# Run one forward and backward pass on a random sequence this long, print the peak
# GPU memory and exit: a quick check that the longest transcripts fit.
PROBE_TOKENS = int(os.environ.get("PROBE_TOKENS", "0"))
MLP_CHUNK = 4096
SEED = 1234


def conversation(example):
    """The transcript in the form the chat template expects: tool call arguments as dicts."""
    messages = []
    for message in example["messages"]:
        message = dict(message)
        if message.get("tool_calls"):
            message["tool_calls"] = [{**call, "function": {**call["function"],
                                                           "arguments": json.loads(call["function"]["arguments"])}}
                                     for call in message["tool_calls"]]
        messages.append(message)
    return messages


def tokenize(tokenizer, example):
    """(token ids, labels) sequences; labels are -100 outside the assistant turns.

    The chat template drops the reasoning of assistant turns that come before
    the latest user message. So a transcript with a user message partway
    through (the agent framework nudging the model) becomes one sequence per
    user message, each training only the turns that followed it, rendered as
    the model saw them when it generated them.
    """
    messages, tools = conversation(example), example["tools"]
    render = lambda msgs, gen: tokenizer.apply_chat_template(msgs, tools=tools, tokenize=False,
                                                            add_generation_prompt=gen, enable_thinking=True)
    users = [i for i, message in enumerate(messages) if message["role"] == "user"] + [len(messages)]
    sequences = []
    for start, stop in zip(users, users[1:]):
        text = render(messages[:stop], False)
        spans = []
        for i in range(start, stop):
            if messages[i]["role"] != "assistant":
                continue
            prefix, upto = render(messages[:i], True), render(messages[:i + 1], False)
            # Each turn must render the same way inside the sequence, or the spans would be off.
            assert upto.startswith(prefix) and text.startswith(upto), f"template drift at message {i}"
            spans.append((len(prefix), len(upto)))
        if not spans:
            continue
        encoded = tokenizer(text, return_offsets_mapping=True, add_special_tokens=False)
        labels = [token if any(start <= a < end for start, end in spans) else -100
                  for token, (a, _) in zip(encoded["input_ids"], encoded["offset_mapping"])]
        sequences.append((encoded["input_ids"], labels))
    return sequences


def chunk_loss(lm_head, hidden, labels):
    logits = lm_head(hidden).float()
    return F.cross_entropy(logits.flatten(0, 1), labels.flatten(), ignore_index=-100, reduction="sum")


def chunked_loss(hidden, lm_head, labels, chunk=1024):
    """Mean cross-entropy over labelled positions without materialising all logits.

    Each chunk is checkpointed, so its logits (1.5 GB per 1K tokens with the
    248K vocabulary) are recomputed in the backward pass rather than kept.
    """
    hidden, labels = hidden[:, :-1], labels[:, 1:]
    total, count = hidden.new_zeros((), dtype=torch.float32), (labels != -100).sum()
    for start in range(0, hidden.shape[1], chunk):
        piece = labels[:, start:start + chunk]
        if (piece != -100).any():
            total = total + checkpoint(chunk_loss, lm_head, hidden[:, start:start + chunk], piece,
                                       use_reentrant=False)
    return total / count


def chunk_mlps(model):
    """Runs each MLP over MLP_CHUNK tokens at a time, each piece checkpointed.

    The MLP works token by token, so this gives the same result. Without it,
    recomputing one layer in the backward pass of a 30K-token transcript
    builds several 2 GB intermediates at once and runs out of memory.
    """
    for name, module in model.named_modules():
        if name.endswith(".mlp") and "language_model" in name:
            forward = module.forward

            def chunked(x, forward=forward):
                if x.shape[1] <= MLP_CHUNK:
                    return forward(x)
                return torch.cat([checkpoint(forward, x[:, s:s + MLP_CHUNK], use_reentrant=False)
                                  for s in range(0, x.shape[1], MLP_CHUNK)], dim=1)
            module.forward = chunked


def sequence_loss(decoder, lm_head, ids, labels):
    offload = torch.autograd.graph.save_on_cpu(pin_memory=True) if len(ids) > OFFLOAD_ABOVE \
        else contextlib.nullcontext()
    with offload:
        hidden = decoder(input_ids=torch.tensor([ids], device=0)).last_hidden_state
    # Outside the offload hook: the checkpointed loss chunks keep nothing large anyway.
    return chunked_loss(hidden, lm_head, torch.tensor([labels], device=0))


def load_model():
    """Qwen3.5-27B in bf16 with a fresh LoRA; returns the model, its decoder, its output head
    and the trainable parameters."""
    model = AutoModelForImageTextToText.from_pretrained(MODEL, revision=REVISION, dtype=torch.bfloat16,
                                                        device_map={"": 0})
    model.config.use_cache = False
    model.gradient_checkpointing_enable(gradient_checkpointing_kwargs={"use_reentrant": False})
    model.enable_input_require_grads()
    # Every linear layer of the language model; the vision tower and output head stay frozen.
    lora = LoraConfig(r=RANK, lora_alpha=2 * RANK, lora_dropout=0.0, target_modules="all-linear",
                      exclude_modules=r".*(visual|vision|lm_head|mtp).*", task_type="CAUSAL_LM")
    model = get_peft_model(model, lora)
    model.print_trainable_parameters()
    chunk_mlps(model)
    params = [p for p in model.parameters() if p.requires_grad]
    return model, model.base_model.model.model.language_model, model.base_model.model.lm_head, params


def schedule(total_steps):
    """Linear warmup over the first tenth, then cosine decay to zero."""
    warmup = max(1, total_steps // 10)
    return lambda step: min(1.0, (step + 1) / warmup) * 0.5 * (1 + math.cos(math.pi * min(step, total_steps) / total_steps))


def save_checkpoint(ckpt, model, optimizer, scheduler, step):
    ckpt.mkdir(exist_ok=True)
    torch.save({"adapter": get_peft_model_state_dict(model), "optimizer": optimizer.state_dict(),
                "scheduler": scheduler.state_dict(), "step": step}, ckpt / "state.tmp")
    os.replace(ckpt / "state.tmp", ckpt / "state.pt")


def load_checkpoint(ckpt, model, optimizer, scheduler):
    """The step to continue from: 0, or the last saved one."""
    if not (ckpt / "state.pt").exists():
        return 0
    state = torch.load(ckpt / "state.pt", weights_only=False)
    set_peft_model_state_dict(model, state["adapter"])
    optimizer.load_state_dict(state["optimizer"])
    scheduler.load_state_dict(state["scheduler"])
    print(f"resumed at step {state['step']}", flush=True)
    return state["step"]


def main(data_path, out_dir):
    out, ckpt = Path(out_dir), Path(out_dir) / "checkpoint"
    out.mkdir(parents=True, exist_ok=True)
    torch.manual_seed(SEED)
    tokenizer = AutoTokenizer.from_pretrained(MODEL, revision=REVISION)

    examples, dropped = [], 0
    for line in open(data_path):
        for ids, labels in tokenize(tokenizer, json.loads(line)):
            if len(ids) > MAX_TOKENS:
                dropped += 1
                continue
            examples.append((ids, labels))
    print(f"{len(examples)} sequences, {dropped} longer than {MAX_TOKENS} tokens dropped, "
          f"{sum(len(i) for i, _ in examples)} tokens, "
          f"{sum(sum(l != -100 for l in labels) for _, labels in examples)} trained on", flush=True)

    model, decoder, lm_head, params = load_model()
    if PROBE_TOKENS:
        model.train()
        ids = torch.randint(0, 150000, (PROBE_TOKENS,)).tolist()
        started = time.time()
        sequence_loss(decoder, lm_head, ids, ids).backward()
        print(f"probe {PROBE_TOKENS} tokens: peak {torch.cuda.max_memory_allocated() / 2**30:.1f} GiB, "
              f"{time.time() - started:.0f}s", flush=True)
        return

    optimizer = torch.optim.AdamW(params, lr=LR, weight_decay=0.0, betas=(0.9, 0.99))
    total_steps = math.ceil(len(examples) * EPOCHS / ACCUMULATE)
    scheduler = torch.optim.lr_scheduler.LambdaLR(optimizer, schedule(total_steps))

    order = []
    for epoch in range(EPOCHS):
        epoch_order = list(range(len(examples)))
        random.Random(SEED + epoch).shuffle(epoch_order)
        order += epoch_order
    step = load_checkpoint(ckpt, model, optimizer, scheduler)

    model.train()
    started = time.time()
    while step < total_steps:
        batch = order[step * ACCUMULATE:(step + 1) * ACCUMULATE]
        losses = []
        for index in batch:
            ids, labels = examples[index]
            loss = sequence_loss(decoder, lm_head, ids, labels)
            (loss / len(batch)).backward()
            losses.append(loss.item())
        torch.nn.utils.clip_grad_norm_(params, 1.0)
        optimizer.step()
        scheduler.step()
        optimizer.zero_grad(set_to_none=True)
        step += 1
        print(f"step {step}/{total_steps} loss {sum(losses) / len(losses):.4f} "
              f"lr {scheduler.get_last_lr()[0]:.2e} {time.time() - started:.0f}s", flush=True)
        if step % SAVE_EVERY == 0 or step == total_steps:
            save_checkpoint(ckpt, model, optimizer, scheduler, step)

    model.save_pretrained(out / "adapter")
    print(f"saved {out / 'adapter'}", flush=True)


if __name__ == "__main__":
    main(*sys.argv[1:])
