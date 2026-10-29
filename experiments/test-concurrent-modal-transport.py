"""Four real installed agents, a concurrent bridge, and synthetic provider only."""
import concurrent.futures
import importlib.util
import json
import os
from pathlib import Path
import re
import secrets
import subprocess
import tempfile
import threading
import time
from types import SimpleNamespace
import urllib.error
import urllib.request

spec = importlib.util.spec_from_file_location("bridge", Path(__file__).with_name("concurrent-modal-bridge.py"))
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def post(base, token, payload):
    request = urllib.request.Request(base + "/chat/completions", json.dumps(payload).encode(),
                                     {"Authorization": "Bearer " + token, "Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(request, timeout=15) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, json.load(error)


def test_admission():
    entered = threading.Event()
    release = threading.Event()
    calls = []

    def complete(payload):
        calls.append(payload)
        entered.set()
        if not release.wait(10):
            raise TimeoutError("Synthetic release missing")
        return {"response": {"ok": True}}

    with tempfile.TemporaryDirectory() as evidence:
        token = secrets.token_hex(32)
        server = module.bridge(SimpleNamespace(complete=SimpleNamespace(remote=complete)), token,
                               evidence, {"temperature": 0.6}, time.monotonic() + 30, max_inflight=1)
        base = f"http://127.0.0.1:{server.server_port}/v1"
        try:
            with concurrent.futures.ThreadPoolExecutor() as pool:
                pending = pool.submit(post, base, token, {"messages": [], "temperature": 1})
                assert entered.wait(5), "Request did not enter provider"
                assert post(base, "wrong", {})[0] == 401
                assert post(base, token, {})[0] == 503, "Overload was queued or admitted"
                release.set()
                assert pending.result()[0] == 200
            assert len(calls) == 1 and calls[0]["temperature"] == 0.6
            assert len(list(Path(evidence).glob("*.request.json"))) == 1
        finally:
            release.set()
            server.shutdown()
            server.server_close()
        server = module.bridge(SimpleNamespace(), token, evidence, {}, time.monotonic() - 1)
        try:
            assert post(f"http://127.0.0.1:{server.server_port}/v1", token, {})[0] == 503
        finally:
            server.shutdown()
            server.server_close()


def test_installed_agents():
    first_requests = threading.Barrier(4, timeout=90)
    lock = threading.Lock()
    seen = {}
    active = peak = 0

    def complete(payload):
        nonlocal active, peak
        text = json.dumps(payload["messages"])
        identities = set(re.findall(r"isolated-agent-(agent[0-3])", text))
        assert len(identities) == 1, "Missing or crossed conversation identity"
        identity = identities.pop()
        with lock:
            step = seen.get(identity, 0)
            seen[identity] = step + 1
            active += 1
            peak = max(peak, active)
        try:
            if step == 0:
                first_requests.wait()  # Serial bridges cannot pass this gate.
                command = ('test -z "$GPUSTACK_API_BASE" && test -z "$GPUSTACK_API_KEY" && '
                           f"printf 'installed-check-{identity}' > isolation.txt && cat isolation.txt")
            else:
                assert step == 1, "Unexpected third call/retry"
                observations = [m["content"] for m in payload["messages"] if m["role"] == "tool"]
                assert any(f"installed-check-{identity}" in str(x) for x in observations)
                for other in set(seen) - {identity}:
                    assert f"installed-check-{other}" not in text, "Crossed tool observation"
                command = "echo COMPLETE_TASK_AND_SUBMIT_FINAL_OUTPUT"
            return {"response": {"id": f"synthetic-{identity}-{step}", "object": "chat.completion",
                "created": int(time.time()), "model": "Qwen/Qwen3.5-4B",
                "choices": [{"index": 0, "finish_reason": "tool_calls", "message": {
                    "role": "assistant", "content": None, "tool_calls": [{"id": f"call-{identity}-{step}",
                    "type": "function", "function": {"name": "bash", "arguments": json.dumps({"command": command})}}]}}],
                "usage": {"prompt_tokens": 100, "completion_tokens": 10, "total_tokens": 110}}}
        finally:
            with lock:
                active -= 1

    root = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix="synthetic-concurrent-") as evidence:
        token = secrets.token_hex(32)
        server = module.bridge(SimpleNamespace(complete=SimpleNamespace(remote=complete)), token,
                               evidence, {}, time.monotonic() + 420)
        processes = []
        try:
            for index in range(4):
                env = dict(os.environ, BUNDLE_GEMFILE=str(root / "experiments/leaderboard.Gemfile"),
                           SYNTHETIC_BRIDGE_BASE=f"http://127.0.0.1:{server.server_port}/v1",
                           MODAL_BRIDGE_TOKEN=token, SYNTHETIC_AGENT_ID=f"agent{index}")
                processes.append(subprocess.Popen(["bundle", "exec", "ruby", "experiments/test-installed-modal-transport.rb"],
                    cwd=root, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True))
            deadline = time.monotonic() + 420
            outputs = []
            for process in processes:
                output, _ = process.communicate(timeout=max(1, deadline - time.monotonic()))
                outputs.append(output)
            for process, output in zip(processes, outputs):
                assert process.returncode == 0, output
                assert '"synthetic":"passed"' in output, output
            assert peak == 4 and seen == {f"agent{i}": 2 for i in range(4)}, (peak, seen)
            requests = list(Path(evidence).glob("*.request.json"))
            responses = list(Path(evidence).glob("*.response.json"))
            assert len(requests) == len(responses) == 8
            assert {p.name.split(".")[0] for p in requests} == {p.name.split(".")[0] for p in responses}
            assert not list(Path(evidence).glob("*.error.json"))
            print(json.dumps({"synthetic": "passed", "installed_agents": 4, "peak_provider_calls": peak,
                              "requests": 8, "isolated_markers": 4, "published_ports": 0, "gpu_calls": 0}))
        finally:
            for process in processes:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=10)
            server.shutdown()
            server.server_close()


if __name__ == "__main__":
    test_admission()
    test_installed_agents()
