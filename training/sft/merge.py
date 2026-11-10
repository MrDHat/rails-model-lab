"""Merges a LoRA adapter from train.py into the model it was trained on
(Qwen3.5-27B, or MODEL if set, e.g. an earlier round's merged weights) and saves full bf16
weights that vLLM serves like the base model (baseline/models/*-sft.env).

    python3 training/sft/merge.py ADAPTER_DIR OUT_DIR

The tokenizer, chat template and processor files are copied from the base
snapshot, so the merged model renders prompts exactly as the base does.
"""
import shutil
import sys
from pathlib import Path

import torch
from huggingface_hub import snapshot_download
from peft import PeftModel
from transformers import AutoModelForImageTextToText

from train import MODEL, REVISION


def main(adapter, out):
    out = Path(out)
    base = Path(MODEL) if Path(MODEL).is_dir() else Path(snapshot_download(MODEL, revision=REVISION))
    model = AutoModelForImageTextToText.from_pretrained(base, dtype=torch.bfloat16, device_map={"": 0})
    model = PeftModel.from_pretrained(model, adapter).merge_and_unload()
    model.save_pretrained(out, max_shard_size="5GB")
    for path in base.iterdir():
        if not path.name.endswith((".safetensors", ".bin")) and path.name not in ("config.json", "model.safetensors.index.json"):
            shutil.copy(path, out / path.name)
    print(f"merged {adapter} into {out}")


if __name__ == "__main__":
    main(*sys.argv[1:])
