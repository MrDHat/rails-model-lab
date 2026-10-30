"""Bounded real-Qwen check of the upstream host adapter; synthetic inputs only."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import secrets
import shutil
import signal
import subprocess
import time
import modal
from concurrent_qwen_provider import app, Qwen, packaging_check

REPO = Path(__file__).resolve().parents[1]
ROOT = REPO / "runs/host-qwen-preflight-20261030"


def main():
    thread = os.environ["CODEX_NOTIFY_THREAD_ID"]
    os.environ["SYNTHETIC_IMAGE"]
    ROOT.mkdir(parents=True, exist_ok=True)
    with (ROOT / "started.json").open("x") as stream:
        json.dump({"started_at": time.time(), "synthetic_only": True, "local_deadline_seconds": 900,
                   "maximum_gpu_containers": 1, "remote_watchdog_seconds": 600, "paid_spending_usd": 0}, stream)
    names = ["host-qwen-preflight.py", "concurrent_qwen_provider.py", "qwen_cuda_environment.py",
             "concurrent-modal-bridge.py", "test-host-modal-transport.rb"]
    hashes = {n: hashlib.sha256((REPO / "experiments" / n).read_bytes()).hexdigest() for n in names}
    archive = ROOT / "frozen-source"
    archive.mkdir()
    for name in names:
        shutil.copyfile(REPO / "experiments" / name, archive / name)
    settings = {"temperature": 0.6, "top_p": 0.95, "top_k": 20, "seed": 42,
                "presence_penalty": 0, "repetition_penalty": 1.0,
                "chat_template_kwargs": {"enable_thinking": True}, "max_tokens": 32768}
    (ROOT / "frozen-inputs.json").write_text(json.dumps({"source_hashes": hashes, "settings": settings}, indent=2))
    spec = importlib.util.spec_from_file_location("private_bridge", REPO / "experiments/concurrent-modal-bridge.py")
    bridge = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(bridge)
    event = {"status": "failed", "synthetic_only": True}
    server = process = log = None

    def expire(*_):
        raise TimeoutError("Independent 900-second host preflight deadline")

    signal.signal(signal.SIGALRM, expire)
    signal.alarm(900)
    try:
        with app.run():
            (ROOT / "app.json").write_text(json.dumps({"app_id": app.app_id}))
            gate = packaging_check.spawn().get(timeout=60)
            (ROOT / "packaging-check.json").write_text(json.dumps(gate, indent=2))
            assert gate["source_sha256"] == hashes["concurrent_qwen_provider.py"]
            assert gate["toolchain"]["source_sha256"] == hashes["qwen_cuda_environment.py"]
            assert not gate["gpu_requested"]
            model = Qwen()
            metadata = model.metadata.spawn().get(timeout=420)
            (ROOT / "metadata.json").write_text(json.dumps(metadata, indent=2))
            original = json.loads((REPO / "runs/full-baseline-20261026/remote-metadata.json").read_text())
            assert metadata["hashes"] == original["hashes"]
            assert metadata["source_sha256"] == hashes["concurrent_qwen_provider.py"]
            assert metadata["toolchain"]["source_sha256"] == hashes["qwen_cuda_environment.py"]
            assert metadata["toolchain"]["real_driver_found"] and metadata["cuda_graphs_requested"]
            token = secrets.token_hex(32)
            server = bridge.bridge(model, token, ROOT / "rpc", settings, time.monotonic() + 240, max_inflight=1)
            env = dict(os.environ, BUNDLE_GEMFILE=str(REPO / "experiments/leaderboard.Gemfile"),
                       SYNTHETIC_BRIDGE_BASE=f"http://127.0.0.1:{server.server_port}/v1",
                       MODAL_BRIDGE_TOKEN=token, SYNTHETIC_REAL_QWEN="1",
                       SYNTHETIC_RESULT_PATH=str(ROOT / "agent.result.json"))
            log = (ROOT / "agent.log").open("w")
            process = subprocess.Popen(["bundle", "exec", "ruby", "experiments/test-host-modal-transport.rb"],
                                       cwd=REPO, env=env, stdout=log, stderr=subprocess.STDOUT)
            code = process.wait(timeout=240)
            responses = [json.loads(p.read_text()) for p in (ROOT / "rpc").glob("*.response.json")]
            summary = {"agent_exit_code": code, "responses": len(responses),
                       "provider_errors": len(list((ROOT / "rpc").glob("*.error.json"))),
                       "containers": sorted({v["container"] for v in responses})}
            (ROOT / "result.json").write_text(json.dumps(summary, indent=2))
            assert code == 0, "Synthetic host agent failed; retained without rerun"
            assert len(responses) >= 2 and len(summary["containers"]) == 1 and summary["provider_errors"] == 0
            event.update(status="passed", **summary, source_and_model_hashes_verified=True)
    except Exception as error:
        event["error"] = repr(error)
    finally:
        signal.alarm(0)
        if process is not None and process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=10)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
        if log:
            log.close()
        if server:
            server.shutdown()
            server.server_close()
        event["finished_at"] = time.time()
        (ROOT / "event.json").write_text(json.dumps(event, indent=2))
        message = f'The authorized real-Qwen host-agent synthetic preflight finished. Read {ROOT}/event.json, result.json, metadata.json and original synthetic evidence. Verify the exact Modal app stopped, Docker cleanup, frozen source/model hashes and host-agent tool observations. Preserve all failed or partial outcomes; no silent reruns. Publish aggregate outcome only, keeping raw traces and private deployment details local. Update the open checkpoint PR, or create one if merged, acknowledge the event, and continue authorized baseline preparation. No scored benchmark or training may launch automatically. Preserve $0 paid spending, the $25 workspace ceiling, and free-credit-only limits. Use direct callbacks, no scheduled or in-context polling. If insufficient free compute is the remaining blocker, bring the concrete budget/scope decision to the user.'
        delivery = subprocess.run([shutil.which("codex") or "codex", "queue", "--thread", thread, "--message", message],
                                  capture_output=True, text=True, timeout=30)
        (ROOT / "delivery.json").write_text(json.dumps({"returncode": delivery.returncode,
            "stdout": delivery.stdout, "stderr": delivery.stderr}))


if __name__ == "__main__":
    with modal.enable_output():
        main()
