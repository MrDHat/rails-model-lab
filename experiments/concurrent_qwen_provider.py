"""Single-use private synthetic provider. No benchmark files are uploaded."""
import hashlib
import json
import os
from pathlib import Path
import signal
import time
import modal

MODEL = "Qwen/Qwen3.5-4B"
REVISION = "851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"
image = (modal.Image.from_id(os.environ["QWEN_PREFLIGHT_IMAGE_ID"])
         .env({"PYTHONPATH": "/root"})
         .add_local_file(__file__, "/root/concurrent_qwen_provider.py"))
app = modal.App("rails-qwen-concurrent-synthetic", include_source=False)


@app.function(image=image, cpu=(0.25, 0.25), memory=(512, 512),
              max_containers=1, scaledown_window=2, timeout=30, startup_timeout=30, retries=0)
def packaging_check():
    # This CPU-only function must import this same module before it can run.
    return {"module": __name__, "file": __file__,
            "source_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
            "gpu_requested": False}


@app.cls(image=image, gpu="A10", cpu=(2, 2), memory=(16384, 16384),
         max_containers=1, scaledown_window=600, timeout=210, startup_timeout=300, retries=0)
@modal.concurrent(max_inputs=4, target_inputs=4)
class Qwen:
    @modal.enter()
    def start(self):
        import subprocess
        import threading
        import requests
        self.started = time.monotonic()
        self.deadline = self.started + 600
        self.proc = None
        self.timer = threading.Timer(600, self.expire)
        self.timer.daemon = True
        self.timer.start()
        self.manifest = json.loads(Path("/model-manifest.json").read_text())
        model_path = Path("/model-path").read_text()
        for name, expected in self.manifest.items():
            with (Path(model_path) / name).open("rb") as stream:
                if hashlib.file_digest(stream, "sha256").hexdigest() != expected:
                    raise RuntimeError("Model hash mismatch: " + name)
        self.proc = subprocess.Popen([
            "vllm", "serve", model_path, "--served-model-name", MODEL,
            "--host", "127.0.0.1", "--port", "8000", "--dtype", "bfloat16",
            "--max-model-len", "262144", "--max-num-seqs", "4",
            "--gpu-memory-utilization", "0.85", "--language-model-only",
            "--enable-auto-tool-choice", "--tool-call-parser", "qwen3_coder",
            "--reasoning-parser", "qwen3", "--enable-prefix-caching", "--enforce-eager",
            "--generation-config", "vllm", "--no-enable-log-requests"], start_new_session=True)
        while time.monotonic() < min(self.deadline, self.started + 270):
            if self.proc.poll() is not None:
                raise RuntimeError("Engine exited during startup")
            try:
                if requests.get("http://127.0.0.1:8000/health", timeout=2).ok:
                    return
            except requests.RequestException:
                pass
            time.sleep(1)
        self.stop()
        raise TimeoutError("Bounded startup expired")

    def expire(self):
        self.stop()
        os._exit(70)  # Independent container lifetime bound, including idle time.

    @modal.exit()
    def stop(self):
        if self.proc is not None and self.proc.poll() is None:
            try:
                os.killpg(self.proc.pid, signal.SIGKILL)
            except ProcessLookupError:
                pass

    @modal.method()
    def metadata(self):
        return {"model": MODEL, "revision": REVISION, "hashes": self.manifest,
                "source_sha256": hashlib.sha256(Path("/root/concurrent_qwen_provider.py").read_bytes()).hexdigest(),
                "container": os.environ.get("MODAL_TASK_ID"), "max_inputs": 4,
                "max_sequences": 4, "watchdog_seconds": 600}

    @modal.method()
    def complete(self, payload):
        import requests
        before = time.monotonic()
        if self.deadline - before < 5:
            raise TimeoutError("Synthetic allowance exhausted")
        response = requests.post("http://127.0.0.1:8000/v1/chat/completions",
            json={**payload, "model": MODEL}, timeout=(5, min(180, self.deadline-before)))
        response.raise_for_status()
        end = time.monotonic()
        return {"response": response.json(), "remote_start": before, "remote_end": end,
                "elapsed_seconds": end-before, "container": os.environ.get("MODAL_TASK_ID"),
                "model_revision": REVISION}
