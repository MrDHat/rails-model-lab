"""Qwen3.5-4B on one Modal A10, as a deployed app the GCP harness VM calls.

A deployed app does not depend on any client staying connected, and calls go
through the Modal SDK (no public endpoint, no HTTP request timeout).

    modal deploy baseline/modal_qwen.py      # once; scales to zero when idle
    modal app stop rails-qwen           # after the run
"""
import subprocess
import time

import modal

MODEL = "Qwen/Qwen3.5-4B"
REVISION = "851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"
VLLM_IMAGE = "vllm/vllm-openai:v0.32.0"

# The image has python3 but no `python`, which Modal needs to detect the version.
image = (modal.Image.from_registry(VLLM_IMAGE)
         .dockerfile_commands(["RUN ln -sf /usr/bin/python3 /usr/local/bin/python"])
         .entrypoint([]))
weights = modal.Volume.from_name("rails-qwen-weights", create_if_missing=True)
app = modal.App("rails-qwen", image=image)


@app.cls(gpu="A10", cpu=4, memory=16384, max_containers=1, scaledown_window=300,
         timeout=1800, startup_timeout=900, retries=0,
         volumes={"/root/.cache/huggingface": weights})
@modal.concurrent(max_inputs=4)
class Qwen:
    @modal.enter()
    def start(self):
        import requests
        # Same serving flags as the earlier staged Modal provider (git history), without --enforce-eager.
        self.proc = subprocess.Popen([
            "vllm", "serve", MODEL, "--revision", REVISION,
            "--host", "127.0.0.1", "--port", "8000", "--dtype", "bfloat16",
            "--max-model-len", "262144", "--max-num-seqs", "4",
            "--gpu-memory-utilization", "0.85", "--language-model-only",
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
