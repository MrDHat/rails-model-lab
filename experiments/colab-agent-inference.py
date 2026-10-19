# Paste into the existing Colab runtime after loading the smoke-test model.
# Call colab_complete(request_json). Relay its printed JSON without editing it.
import json
import re
import time
import uuid

EXPECTED_REVISION = "851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"


def parse_calls(raw):
    calls = []
    # The pinned checkpoint's native template uses XML function parameters.
    for block in re.findall(r"<tool_call>\s*(.*?)\s*</tool_call>", raw, re.S):
        match = re.fullmatch(
            r"<function=bash>\s*<parameter=command>\n?(.*?)\n?</parameter>\s*</function>",
            block, re.S,
        )
        if match and not re.search(r"</?parameter(?:=|>)", match.group(1)):
            calls.append({
                "id": "call_" + uuid.uuid4().hex, "type": "function",
                "function": {"name": "bash",
                             "arguments": json.dumps({"command": match.group(1)})},
            })
    return calls


def _colab_complete(request_json):
    import torch

    assert REVISION == EXPECTED_REVISION, "Unexpected model revision"
    request = json.loads(request_json)
    assert request["model"] == MODEL_ID
    messages = request["messages"]
    # OpenAI's wire format uses JSON strings; the Qwen template needs objects.
    for message in messages:
        for call in message.get("tool_calls", []):
            args = call["function"]["arguments"]
            if isinstance(args, str):
                call["function"]["arguments"] = json.loads(args)
    inputs = processor.apply_chat_template(
        messages, tools=request["tools"], tokenize=True,
        add_generation_prompt=True, return_dict=True, return_tensors="pt",
        enable_thinking=False,
    ).to("cuda")
    input_tokens = inputs["input_ids"].shape[-1]
    assert input_tokens <= 8192, "Pilot input budget exceeded"
    cap = min(request["max_new_tokens"], 1024)
    prefill_chunk_size = request.get("prefill_chunk_size")
    assert prefill_chunk_size is None or (type(prefill_chunk_size) is int and prefill_chunk_size > 0)
    end_token = processor.tokenizer.convert_tokens_to_ids("<|im_end|>")
    assert isinstance(end_token, int) and end_token == processor.tokenizer.eos_token_id
    torch.cuda.reset_peak_memory_stats()
    torch.cuda.synchronize()
    started = time.perf_counter()
    with torch.inference_mode():
        output = model.generate(
            **inputs, max_new_tokens=cap, do_sample=False, eos_token_id=end_token,
            prefill_chunk_size=prefill_chunk_size,
        )
    torch.cuda.synchronize()
    generated = output[0][input_tokens:]
    # Keep tool delimiters even if the tokenizer marks them as special tokens.
    raw = processor.decode(generated, skip_special_tokens=False)
    raw = raw.removesuffix("<|im_end|>").removesuffix("<|endoftext|>")
    calls = parse_calls(raw)
    content = re.sub(r"<tool_call>.*?</tool_call>", "", raw, flags=re.S).strip()
    reason = "length" if len(generated) == cap else "tool_calls" if calls else "stop"
    response = {
        "relay_id": request["id"], "model": MODEL_ID, "revision": REVISION,
        "choices": [{"finish_reason": reason, "message": {
            "role": "assistant", "content": content, "tool_calls": calls,
        }}],
        "usage": {"prompt_tokens": input_tokens, "completion_tokens": len(generated)},
        "raw_generation": raw,
        "eos_token_id": end_token,
        "attention": model.config.text_config._attn_implementation,
        "prefill_chunk_size": prefill_chunk_size,
        "seconds": round(time.perf_counter() - started, 2),
        "peak_gpu_GiB": round(torch.cuda.max_memory_allocated() / 2**30, 2),
    }
    return response


def colab_complete(request_json):
    request = json.loads(request_json)
    try:
        response = _colab_complete(request_json)
    except Exception as error:
        # Transport failures are not model answers and must never be scored.
        response = {
            "relay_id": request["id"], "model": MODEL_ID, "revision": REVISION,
            "error": {"type": type(error).__name__, "message": str(error)},
        }
    print(json.dumps(response))
