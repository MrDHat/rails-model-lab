# Diagnostic only: run after the model and colab-agent-inference.py are loaded.
# This changes the runtime configuration. Do not resume an earlier scored run.
import gc
import sys
from torch.nn.attention import SDPBackend, sdpa_kernel

# Notebook exception tracebacks can retain tensors from the failed forward pass.
for exception_slot in ("last_exc", "last_value", "last_traceback"):
    if hasattr(sys, exception_slot):
        setattr(sys, exception_slot, None)
gc.collect()
torch.cuda.empty_cache()
model.set_attn_implementation("sdpa")
assert model.config.text_config._attn_implementation == "sdpa"

# Pass the exact failed request string explicitly; do not execute its tool calls.
def probe_request(request_json):
    # Default SDPA also ran out of memory on the T4. Require the efficient
    # backend instead of silently allowing a memory-heavy math fallback.
    with sdpa_kernel(SDPBackend.EFFICIENT_ATTENTION):
        colab_complete(request_json)
