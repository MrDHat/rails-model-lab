"""Offline MLX file transport. This variant has its own model/revision identity."""
import argparse
from datetime import datetime, timezone
import importlib.metadata
import json
import os
from pathlib import Path
import platform
import re
import runpy
import time
import uuid

MODEL = "mlx-community/Qwen3.5-4B-4bit"
REVISION = "0e7ffd5c629ef7719d4cbc04069232580bfa9d9c"
helpers = runpy.run_path(str(Path(__file__).with_name("colab-agent-inference.py")))


def prepare(request, tokenizer):
    if (request["model"] != MODEL or request["relay_protocol"] != 3 or
            str(uuid.UUID(request["id"])) != request["id"]):
        raise ValueError("Unexpected request identity or protocol")
    if request["enable_thinking"] is not False or request["do_sample"] is not False:
        raise ValueError("Only greedy, thinking-disabled requests are supported")
    if request["prefill_chunk_size"] != 1024:
        raise ValueError("Expected fixed prefill step size 1024")
    messages = json.loads(json.dumps(request["messages"]))
    for message in messages:
        for call in message.get("tool_calls", []):
            args = call["function"]["arguments"]
            if isinstance(args, str):
                call["function"]["arguments"] = json.loads(args)
    tokens = tokenizer.apply_chat_template(
        messages, tools=request["tools"], tokenize=True,
        add_generation_prompt=True, enable_thinking=False,
    )
    helpers["generation_limits"](request, len(tokens))
    return tokens


def response_for(request, raw, prompt_tokens, generated_tokens, finish_reason, seconds, peak):
    raw = raw.removesuffix("<|im_end|>")
    calls = helpers["parse_calls"](raw)
    return {
        "relay_id": request["id"], "model": MODEL, "revision": REVISION,
        "backend": "mlx", "attention": "mlx-native", "quantization_bits": 4,
        "base_revision": None, "eos_token_id": 248046,
        "prefill_chunk_size": 1024, "input_token_limit": request["input_token_limit"],
        "max_new_tokens": request["max_new_tokens"],
        "choices": [{"finish_reason": "length" if finish_reason == "length" else
                     "tool_calls" if calls else "stop", "message": {
                         "role": "assistant", "content": re.sub(
                             r"<tool_call>.*?</tool_call>", "", raw, flags=re.S).strip(),
                         "tool_calls": calls}}],
        "usage": {"prompt_tokens": prompt_tokens, "completion_tokens": generated_tokens},
        "raw_generation": raw, "seconds": round(seconds, 3),
        "peak_unified_memory_GiB": round(peak / 2**30, 3),
    }


def expired(request, directory):
    return (datetime.now(timezone.utc) >= datetime.fromisoformat(request["expires_at"]) or
            (directory / f'{request["id"]}.expired.json').exists())


def deliver(request, response, directory):
    identity = request["id"]
    if (response["relay_id"] != identity or response["revision"] != REVISION or
            response["model"] != MODEL):
        raise ValueError("Response identity mismatch")
    temporary = directory / f"{identity}.worker.tmp"
    with temporary.open("x") as stream:
        json.dump(response, stream)
        stream.write("\n")
    suffix = "late" if expired(request, directory) else "response"
    destination = directory / f"{identity}.{suffix}.json"
    if destination.exists():
        raise ValueError("Refusing to overwrite an existing response")
    temporary.rename(destination)
    return suffix


def serve(root, model_path):
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    os.environ["HF_HUB_DISABLE_IMPLICIT_TOKEN"] = "1"
    import mlx.core as mx
    from mlx_lm import load, stream_generate
    from mlx_lm.sample_utils import make_sampler

    if model_path.name != REVISION or not (model_path / "model.safetensors").is_file():
        raise ValueError("Expected the pinned local snapshot")
    model, tokenizer = load(str(model_path), trust_remote_code=False)
    if tokenizer.convert_tokens_to_ids("<|im_end|>") != 248046:
        raise ValueError("Unexpected end-of-turn token")
    tokenizer.eos_token_ids = {248046}
    (root / "runtime.json").write_text(json.dumps({
        "backend": "mlx", "model": MODEL, "revision": REVISION,
        "base_revision": None, "quantization_bits": 4,
        "python": platform.python_version(), "machine": platform.machine(),
        "eos_token_id": 248046, "prefill_step_size": 1024,
        "packages": {name: importlib.metadata.version(name) for name in
                     ("mlx", "mlx-lm", "mlx-metal", "transformers", "huggingface-hub")},
    }, indent=2) + "\n")
    print("MLX_WORKER_READY", flush=True)
    directory = root / "relay"
    while not (root / "stop-worker").exists():
        pending = [path for path in directory.glob("*.request.json") if not any(
            path.with_name(path.name.replace(".request.json", f".{suffix}.json")).exists()
            for suffix in ("response", "late", "expired"))]
        if len(pending) > 1:
            raise ValueError("Expected one concurrent request")
        if not pending:
            time.sleep(0.25)
            continue
        request = json.loads(pending[0].read_text())
        if pending[0].name != f'{request["id"]}.request.json':
            raise ValueError("Request filename identity mismatch")
        if expired(request, directory):
            time.sleep(0.25)
            continue
        try:
            tokens = prepare(request, tokenizer)
            mx.reset_peak_memory()
            started = time.perf_counter()
            generated, final = [], None
            for part in stream_generate(
                    model, tokenizer, tokens, max_tokens=request["max_new_tokens"],
                    sampler=make_sampler(temp=0), prefill_step_size=1024):
                generated.append(part.token)
                final = part
            response = response_for(
                request, tokenizer.decode(generated, skip_special_tokens=False), len(tokens),
                len(generated), final.finish_reason, time.perf_counter() - started,
                mx.get_peak_memory())
        except Exception as error:
            response = {"relay_id": request["id"], "model": MODEL, "revision": REVISION,
                        "error": {"type": type(error).__name__, "message": str(error)}}
        status = deliver(request, response, directory)
        print(json.dumps({"id": request["id"], "delivery": status,
                          "error": response.get("error"), "usage": response.get("usage")}), flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("run", type=Path)
    parser.add_argument("model_path", type=Path)
    arguments = parser.parse_args()
    serve(arguments.run.resolve(), arguments.model_path.resolve())
