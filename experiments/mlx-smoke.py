"""Offline, non-task smoke test for a separately pinned quantized MLX variant."""
import importlib.metadata
import json
import platform
from pathlib import Path
import sys
import time

MODEL = "mlx-community/Qwen3.5-4B-4bit"
REVISION = "0e7ffd5c629ef7719d4cbc04069232580bfa9d9c"


def main():
    import mlx.core as mx
    from mlx_lm import load, stream_generate
    from mlx_lm.sample_utils import make_sampler

    model_path = Path(sys.argv[1]).resolve()
    output = Path(sys.argv[2])
    # A local immutable Hub snapshot is required; never fetch task-time code.
    if model_path.name != REVISION or not (model_path / "model.safetensors").is_file():
        raise ValueError("Expected the pinned, downloaded local snapshot")
    started = time.perf_counter()
    model, tokenizer = load(str(model_path), trust_remote_code=False)
    end_token = tokenizer.convert_tokens_to_ids("<|im_end|>")
    if end_token != 248046:
        raise ValueError("Unexpected end-of-turn token")
    tokenizer.eos_token_ids = {end_token}
    prompt = tokenizer.apply_chat_template(
        [{"role": "user", "content": "Reply with only OK."}],
        tokenize=True, add_generation_prompt=True, enable_thinking=False,
    )
    mx.reset_peak_memory()
    generated = []
    final = None
    generation_start = time.perf_counter()
    for part in stream_generate(model, tokenizer, prompt, max_tokens=32,
                                sampler=make_sampler(temp=0), prefill_step_size=1024):
        generated.append(part.token)
        final = part
    raw = tokenizer.decode(generated, skip_special_tokens=False)
    text = raw.removesuffix("<|im_end|>")
    result = {
        "diagnostic": "local-mlx-smoke", "model": MODEL, "revision": REVISION,
        "base_revision": None, "quantization": "community 4-bit; distinct from Colab float16",
        "python": platform.python_version(), "machine": platform.machine(),
        "packages": {name: importlib.metadata.version(name) for name in
                     ("mlx", "mlx-lm", "mlx-metal", "transformers", "huggingface-hub")},
        "input_tokens": len(prompt), "output_tokens": len(generated),
        "raw_generation": raw, "finish_reason": final.finish_reason,
        "generation_seconds": round(time.perf_counter() - generation_start, 3),
        "total_seconds": round(time.perf_counter() - started, 3),
        "peak_unified_memory_GiB": round(mx.get_peak_memory() / 2**30, 3),
        "eos_token_id": end_token, "prefill_step_size": 1024,
        "passed": text.strip() == "OK" and final.finish_reason == "stop",
    }
    output.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))
    if not result["passed"]:
        raise SystemExit("Smoke response did not meet the exact non-task check")


if __name__ == "__main__":
    main()
