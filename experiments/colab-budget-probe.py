# Separate synthetic memory diagnostic. No task, grader, or command execution.
def probe_budget():
    import gc
    import time
    import torch

    gc.collect()
    torch.cuda.empty_cache()
    model.set_attn_implementation("eager")
    token = processor.tokenizer.encode("test", add_special_tokens=False)[0]
    inputs = torch.full((1, 12288), token, dtype=torch.long, device="cuda")
    torch.cuda.reset_peak_memory_stats()
    torch.cuda.synchronize()
    started = time.perf_counter()
    try:
        with torch.inference_mode():
            output = model.generate(
                input_ids=inputs, attention_mask=torch.ones_like(inputs),
                max_new_tokens=2048, min_new_tokens=2048, do_sample=False,
                eos_token_id=processor.tokenizer.eos_token_id,
                prefill_chunk_size=1024,
            )
        torch.cuda.synchronize()
        result = {"diagnostic": "synthetic-budget-boundary", "revision": REVISION,
                  "input_tokens": 12288, "output_tokens": output.shape[-1] - 12288,
                  "attention": model.config.text_config._attn_implementation,
                  "prefill_chunk_size": 1024,
                  "seconds": round(time.perf_counter() - started, 2),
                  "peak_gpu_GiB": round(torch.cuda.max_memory_allocated() / 2**30, 2)}
    except Exception as error:
        result = {"diagnostic": "synthetic-budget-boundary",
                  "error": {"type": type(error).__name__, "message": str(error)}}
    print(json.dumps(result))


probe_budget()
