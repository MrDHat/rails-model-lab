"""Single-use controller; direct callback after shutdown, never a benchmark."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import time
import modal
from qwen_graph_context_probe import app, compiler_gate, measure, CASES

REPO = Path(__file__).resolve().parents[1]
ROOT = REPO / "runs/qwen-graph-context-probe-20261029"


def main():
    thread = os.environ["CODEX_NOTIFY_THREAD_ID"]
    ROOT.mkdir(parents=True, exist_ok=True)
    with (ROOT / "started.json").open("x") as stream:
        json.dump({"started_at": time.time(), "synthetic_only": True, "local_deadline_seconds": 1500,
                   "remote_watchdog_seconds": 1140, "remote_timeout_seconds": 1200,
                   "maximum_gpu_containers": 1, "cases_per_mode": CASES}, stream, indent=2)
    sources = ["qwen_graph_context_probe.py", "run-qwen-graph-context-probe.py"]
    hashes = {name: hashlib.sha256((REPO / "experiments" / name).read_bytes()).hexdigest() for name in sources}
    frozen = ROOT / "frozen-source"
    frozen.mkdir()
    for name in sources:
        shutil.copyfile(REPO / "experiments" / name, frozen / name)
    (ROOT / "frozen-inputs.json").write_text(json.dumps({"source_hashes": hashes}, indent=2))

    def expire(*_):
        raise TimeoutError("Independent 1500-second local probe deadline")

    signal.signal(signal.SIGALRM, expire)
    signal.alarm(1500)
    event = {"status": "failed", "synthetic_only": True}
    try:
        with app.run():
            (ROOT / "app.json").write_text(json.dumps({"app_id": app.app_id}))
            gate = compiler_gate.spawn().get(timeout=90)
            (ROOT / "compiler-gate.json").write_text(json.dumps(gate, indent=2))
            assert gate["cuda_compile_passed"] and not gate["gpu_requested"]
            assert gate["source_sha256"] == hashes[sources[0]]
            expected = json.loads((REPO / "runs/full-baseline-20261026/remote-metadata.json").read_text())["hashes"]
            result = measure.spawn(expected).get(timeout=1230)
            (ROOT / "result.json").write_text(json.dumps(result, indent=2))
            assert result["source_sha256"] == hashes[sources[0]], "Remote source changed"
            assert result.get("model_hashes") == expected, "Original model hashes not verified"
            event.update(status=result["status"], completed_cases=len(result["cases"]),
                         source_and_model_hashes_verified=True)
    except Exception as error:
        event["error"] = str(error)
    finally:
        signal.alarm(0)
        event["finished_at"] = time.time()
        (ROOT / "event.json").write_text(json.dumps(event, indent=2))
        message = f'The authorized synthetic Qwen CUDA-graph/context probe finished. Read {ROOT}/event.json, compiler-gate.json and result.json if present. Verify the exact Modal app stopped and frozen source/model hashes. Preserve partial/failed cases and all prior probes. Report measured graph/eager and longer-context throughput with limitations; no scored benchmark or training may launch automatically. Keep raw logs, app identifiers and detailed operational evidence local; publish only aggregate results and configuration without private identifiers. Update the open checkpoint PR or create one if merged. Preserve $0 paid spending and existing budget controls. Acknowledge the event locally. Continue authorized preparation, no silent reruns and no scheduled/in-context polling.'
        delivery = subprocess.run([shutil.which("codex") or "codex", "queue", "--thread", thread, "--message", message],
                                  capture_output=True, text=True, timeout=30)
        (ROOT / "delivery.json").write_text(json.dumps({"returncode": delivery.returncode,
            "stdout": delivery.stdout, "stderr": delivery.stderr}))


if __name__ == "__main__":
    with modal.enable_output():
        main()
