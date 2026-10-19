# Run in a Colab GPU runtime. Smoke test only; no training or evaluation task.
# Dependencies are supplied by Colab; record their versions with each run.
import importlib.metadata as md
import json
import platform
import time
from pathlib import Path

import torch
from huggingface_hub import model_info
from transformers import AutoModelForImageTextToText, AutoProcessor

MODEL_ID = "Qwen/Qwen3.5-4B"
# Set this to a recorded commit hash to reproduce a previous run.
REVISION = model_info(MODEL_ID).sha
assert torch.cuda.is_available(), "Select a GPU runtime before running"
print("Model:", MODEL_ID, "Revision:", REVISION, flush=True)
processor = AutoProcessor.from_pretrained(MODEL_ID, revision=REVISION)
started = time.perf_counter()
model = AutoModelForImageTextToText.from_pretrained(
    MODEL_ID, revision=REVISION, dtype=torch.float16,
    device_map={"": 0}, attn_implementation="eager",
)
model.eval()
torch.cuda.synchronize()
load_seconds = time.perf_counter() - started

prompt = (
    "In Rails, how do includes and joins differ when loading associated records? "
    "Give a concise explanation and one short example of each."
)
messages = [{"role": "user", "content": [{"type": "text", "text": prompt}]}]
inputs = processor.apply_chat_template(
    messages, tokenize=True, add_generation_prompt=True, return_dict=True,
    return_tensors="pt", enable_thinking=False,
).to("cuda")
torch.cuda.reset_peak_memory_stats()
torch.cuda.synchronize()
started = time.perf_counter()
with torch.inference_mode():
    outputs = model.generate(**inputs, max_new_tokens=192, do_sample=False)
torch.cuda.synchronize()
elapsed = time.perf_counter() - started
new_tokens = outputs[0][inputs["input_ids"].shape[-1]:]
answer = processor.decode(new_tokens, skip_special_tokens=True)
record = {
    "model": MODEL_ID, "revision": REVISION, "prompt": prompt, "answer": answer,
    "dtype": str(model.dtype), "gpu": torch.cuda.get_device_name(),
    "python": platform.python_version(),
    "packages": {p: md.version(p) for p in (
        "torch", "transformers", "accelerate", "huggingface_hub"
    )},
    "load_seconds": round(load_seconds, 2), "tokens": len(new_tokens),
    "seconds": round(elapsed, 2),
    "peak_gpu_GiB": round(torch.cuda.max_memory_allocated() / 2**30, 2),
    "max_new_tokens": 192, "do_sample": False, "enable_thinking": False,
    "attn_implementation": "eager",
    "reached_token_limit": len(new_tokens) == 192,
}
Path("qwen-smoke-result.json").write_text(json.dumps(record, indent=2) + "\n")
print(json.dumps(record, indent=2))
