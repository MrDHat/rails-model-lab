# Separate infrastructure diagnostic, never a continuation of a scored run.
import gc
import sys

for exception_slot in ("last_exc", "last_value", "last_traceback"):
    if hasattr(sys, exception_slot):
        setattr(sys, exception_slot, None)
gc.collect()
torch.cuda.empty_cache()
model.set_attn_implementation("eager")
model.generation_config.prefill_chunk_size = 1024


def probe_request(request_json):
    # Single unpadded request; preserve the full history and output-token cap.
    colab_complete(request_json)
