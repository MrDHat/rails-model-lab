"""Single-use real-provider synthetic integration; never starts benchmark tasks."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import secrets
import signal
import shutil
import subprocess
import time
import modal
from concurrent_qwen_provider import app, Qwen, packaging_check

REPO = Path(__file__).resolve().parents[1]
ROOT = REPO / "runs/concurrent-qwen-preflight-20261029-packaging-fix"


def main():
    ROOT.mkdir(parents=True, exist_ok=True)
    with (ROOT / "started.json").open("x") as stream:
        json.dump({"started_at": time.time(), "local_deadline_seconds": 900,
                   "synthetic_only": True, "maximum_containers": 1, "paid_spending_usd": 0}, stream)
    spec = importlib.util.spec_from_file_location("concurrent_bridge", REPO / "experiments/concurrent-modal-bridge.py")
    bridge_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(bridge_module)
    settings = {"temperature": 0.6, "top_p": 0.95, "top_k": 20, "presence_penalty": 0,
                "repetition_penalty": 1.0, "chat_template_kwargs": {"enable_thinking": True},
                "seed": 42, "max_tokens": 32768}
    hashes = {name: hashlib.sha256((REPO / "experiments" / name).read_bytes()).hexdigest()
              for name in ["concurrent_qwen_provider.py", "concurrent-qwen-preflight.py",
                           "concurrent-modal-bridge.py", "test-installed-modal-transport.rb",
                           "installed-modal-transport.rb", "installed-modal-config.rb", "sandbox-inference-relay.rb"]}
    (ROOT / "frozen-inputs.json").write_text(json.dumps({"hashes": hashes, "settings": settings}, indent=2))
    event = {"status": "failed", "synthetic_only": True}
    processes = []
    logs = []
    server = None

    def expire(*_):
        raise TimeoutError("Independent 900-second local preflight deadline")

    signal.signal(signal.SIGALRM, expire)
    signal.alarm(900)
    try:
        with app.run():
            (ROOT / "app.json").write_text(json.dumps({"app_id": app.app_id}))
            packaging = packaging_check.spawn().get(timeout=60)
            (ROOT / "packaging-check.json").write_text(json.dumps(packaging, indent=2))
            assert packaging["module"] == "concurrent_qwen_provider", "Wrong imported module"
            assert packaging["source_sha256"] == hashes["concurrent_qwen_provider.py"], "Packaged source changed"
            model = Qwen()
            metadata = model.metadata.spawn().get(timeout=300)
            (ROOT / "metadata.json").write_text(json.dumps(metadata, indent=2))
            original = json.loads((REPO / "runs/full-baseline-20261026/remote-metadata.json").read_text())
            assert metadata["hashes"] == original["hashes"], "Original model manifest changed"
            assert metadata["source_sha256"] == hashes["concurrent_qwen_provider.py"], "Remote source changed"
            token = secrets.token_hex(32)
            server = bridge_module.bridge(model, token, ROOT / "rpc", settings, time.monotonic() + 240)
            for index in range(4):
                identity = f"agent{index}"
                log = (ROOT / f"{identity}.log").open("w")
                logs.append(log)
                env = dict(os.environ, BUNDLE_GEMFILE=str(REPO / "experiments/leaderboard.Gemfile"),
                           SYNTHETIC_BRIDGE_BASE=f"http://127.0.0.1:{server.server_port}/v1",
                           MODAL_BRIDGE_TOKEN=token, SYNTHETIC_AGENT_ID=identity, SYNTHETIC_REAL_QWEN="1",
                           SYNTHETIC_RESULT_PATH=str(ROOT / f"{identity}.result.json"))
                processes.append(subprocess.Popen(["bundle", "exec", "ruby", "experiments/test-installed-modal-transport.rb"],
                    cwd=REPO, env=env, stdout=log, stderr=subprocess.STDOUT))
            deadline = time.monotonic() + 240
            codes = [process.wait(timeout=max(1, deadline-time.monotonic())) for process in processes]
            responses = [json.loads(path.read_text()) for path in sorted((ROOT / "rpc").glob("*.response.json"))]
            intervals = sorted([(row["remote_start"], 1) for row in responses] + [(row["remote_end"], -1) for row in responses])
            active = peak = 0
            for _, delta in intervals:
                active += delta
                peak = max(peak, active)
            containers = sorted({row["container"] for row in responses})
            summary = {"exit_codes": codes, "responses": len(responses), "peak_remote_calls": peak,
                       "containers": containers, "all_agents_passed": codes == [0, 0, 0, 0],
                       "provider_errors": len(list((ROOT / "rpc").glob("*.error.json")))}
            (ROOT / "result.json").write_text(json.dumps(summary, indent=2))
            assert summary["all_agents_passed"], "One or more real synthetic agents failed; original evidence retained"
            assert len(containers) == 1 and peak >= 2, "Concurrent calls in one container not established"
            assert summary["provider_errors"] == 0
            event.update(status="passed", **summary)
    except Exception as error:
        event["error"] = str(error)
        print(json.dumps({"preflight_error": str(error)}), flush=True)
    finally:
        signal.alarm(0)
        for process in processes:
            if process.poll() is None:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait()
        for log in logs:
            log.close()
        if server:
            server.shutdown()
            server.server_close()
        event["finished_at"] = time.time()
        (ROOT / "event.json").write_text(json.dumps(event, indent=2))
        message = f'The authorized real Qwen concurrent synthetic preflight finished. Read {ROOT}/event.json, result.json and metadata.json if present. Verify the exact Modal app stopped, frozen source/model hashes and Docker cleanup. Diagnose any failed synthetic agents using retained evidence; no silent reruns. Preserve $0 paid spending. No scored benchmark tasks may launch automatically. Record the outcome in PR #33 and continue authorized preparation without asking the user to drive each step. Use no scheduled or in-context polling.'
        delivery = subprocess.run([shutil.which("codex") or "codex", "queue", "--thread", os.environ["CODEX_NOTIFY_THREAD_ID"], "--message", message], capture_output=True, text=True, timeout=30)
        (ROOT / "delivery.json").write_text(json.dumps({"returncode": delivery.returncode, "stdout": delivery.stdout, "stderr": delivery.stderr}))


if __name__ == "__main__":
    with modal.enable_output():
        main()
