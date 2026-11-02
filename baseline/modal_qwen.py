"""A Qwen model on one Modal GPU, as a deployed app the GCP harness VM calls.

A deployed app does not depend on any client staying connected, and calls go
through the Modal SDK (no public endpoint, no HTTP request timeout).

QWEN names a file in baseline/models/ (default qwen3.5-4b):

    QWEN=qwen3.5-27b modal run baseline/modal_qwen.py::download   # weights, on CPU
    QWEN=qwen3.5-27b modal deploy baseline/modal_qwen.py          # scales to zero when idle
    modal app stop rails-qwen-27b                                 # after the run
"""
import os
from pathlib import Path
import subprocess
import time

import modal

QWEN = os.environ.get("QWEN", "qwen3.5-4b")
KEYS = ["MODEL", "MODEL_REVISION", "MODAL_APP", "MODAL_GPU", "MODAL_MEMORY_MB",
        "MAX_SEQS", "GPU_MEMORY_UTILIZATION"]


def load_config():
    path = Path(__file__).parent / "models" / f"{QWEN}.env"
    if not path.exists():  # inside the container, the values come from the image env
        return {key: os.environ[key] for key in KEYS}
    lines = [line.strip() for line in path.read_text().splitlines()]
    return dict(line.split("=", 1) for line in lines if line and not line.startswith("#"))


CONFIG = load_config()
VLLM_IMAGE = "vllm/vllm-openai:v0.32.0"

# The image has python3 but no `python`, which Modal needs to detect the version.
image = (modal.Image.from_registry(VLLM_IMAGE)
         .dockerfile_commands(["RUN ln -sf /usr/bin/python3 /usr/local/bin/python"])
         .entrypoint([])
         .env({"QWEN": QWEN, **CONFIG}))
weights = modal.Volume.from_name("rails-qwen-weights", create_if_missing=True)
hf_cache = {"/root/.cache/huggingface": weights}
app = modal.App(CONFIG["MODAL_APP"], image=image)


@app.function(cpu=4, memory=8192, timeout=3600, volumes=hf_cache)
def download():
    from huggingface_hub import snapshot_download
    snapshot_download(CONFIG["MODEL"], revision=CONFIG["MODEL_REVISION"])
    weights.commit()


@app.cls(gpu=CONFIG["MODAL_GPU"], cpu=4, memory=int(CONFIG["MODAL_MEMORY_MB"]),
         max_containers=1, scaledown_window=300, timeout=1800, startup_timeout=1800,
         retries=0, volumes=hf_cache)
@modal.concurrent(max_inputs=int(CONFIG["MAX_SEQS"]))
class Qwen:
    @modal.enter()
    def start(self):
        import requests
        # Same serving flags as the earlier staged Modal provider (git history), without --enforce-eager.
        self.proc = subprocess.Popen([
            "vllm", "serve", CONFIG["MODEL"], "--revision", CONFIG["MODEL_REVISION"],
            "--host", "127.0.0.1", "--port", "8000", "--dtype", "bfloat16",
            "--max-model-len", "262144", "--max-num-seqs", CONFIG["MAX_SEQS"],
            "--gpu-memory-utilization", CONFIG["GPU_MEMORY_UTILIZATION"], "--language-model-only",
            "--enable-auto-tool-choice", "--tool-call-parser", "qwen3_coder",
            "--reasoning-parser", "qwen3", "--enable-prefix-caching",
            "--generation-config", "vllm", "--no-enable-log-requests"])
        while True:
            if self.proc.poll() is not None:
                raise RuntimeError(f"vLLM exited with {self.proc.returncode}")
            try:
                if requests.get("http://127.0.0.1:8000/health", timeout=2).ok:
                    break
            except requests.RequestException:
                pass
            time.sleep(5)
        weights.commit()

    @modal.method()
    def complete(self, payload):
        import requests
        response = requests.post("http://127.0.0.1:8000/v1/chat/completions", json=payload, timeout=1700)
        return {"status": response.status_code, "body": response.text}

    @modal.method()
    def metrics(self):
        import requests
        return requests.get("http://127.0.0.1:8000/metrics", timeout=10).text

    @modal.exit()
    def stop(self):
        self.proc.terminate()
