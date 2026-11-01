#!/usr/bin/env python3
"""Explicitly gated batch controller. Preparing or importing it starts no GPU."""
import argparse
from concurrent.futures import ThreadPoolExecutor
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import secrets
import shutil
import subprocess
import sys
import time

REPO = Path(__file__).resolve().parents[1]
SOURCES = ["run-staged-baseline.py", "staged-baseline-budget.py", "staged_qwen_provider.py",
           "staged-provider-config.rb", "concurrent-modal-bridge.py", "qwen_cuda_environment.py",
           "installed-modal-transport.rb", "installed-modal-config.rb", "sandbox-inference-relay.rb",
           "leaderboard.Gemfile", "leaderboard.Gemfile.lock"]
SOURCES.append("staged-harness.rb")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def save(path, value):
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(value, indent=2) + "\n")
    temporary.replace(path)


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


def verify(spec):
    for name, expected in spec["sources"].items():
        if digest(REPO / "experiments" / name) != expected:
            raise ValueError("Prepared controller source changed: " + name)
    bench = Path(spec["benchmark_path"])
    for name, expected in spec["benchmark_files"].items():
        if digest(bench / name) != expected:
            raise ValueError("Frozen benchmark input changed")
    for args, expected in ((["rev-parse", "HEAD"], spec["benchmark_revision"]), (["status", "--porcelain"], "")):
        value = subprocess.check_output(["git", "-C", str(bench), *args], text=True).strip()
        if value != expected:
            raise ValueError("Benchmark checkout is not clean and pinned")


def verify_replacements(spec, ledger):
    names = ("parent_prepared", "replacement_review", "replacement_authorization")
    if not any(name in spec for name in names):
        return {}
    records = {}
    for name in names:
        reference = spec[name]
        path = Path(reference["path"])
        if digest(path) != reference["sha256"]:
            raise ValueError("Frozen replacement reference changed: " + name)
        records[name] = json.loads(path.read_text())
    if records["replacement_authorization"].get("user_authorized") is not True:
        raise ValueError("Infrastructure replacement authorization required")
    parent = records["parent_prepared"]
    for name in ("plan", "profiles", "settings", "model_hashes", "benchmark_revision", "benchmark_files"):
        if spec[name] != parent[name]:
            raise ValueError("Frozen replacement configuration differs: " + name)
    key = lambda item: (item["task"], item["attempt"])
    review = records["replacement_review"]["identities"]
    planned = {key(item) for item in spec["plan"]["attempts"]}
    if {key(item) for item in review} != planned or len(review) != len(planned):
        raise ValueError("Replacement review must cover every planned identity exactly once")
    entries = {key(item): item for item in ledger}
    if len(entries) != len(ledger) or entries.keys() - planned:
        raise ValueError("Unexpected or duplicate replacement ledger identity")
    replacements = {}
    for item in review:
        disposition = item["disposition"]
        if disposition not in ("retain_scored_no_retry", "infrastructure_replacement_candidate", "unstarted"):
            raise ValueError("Unresolved replacement disposition")
        if disposition == "unstarted":
            continue
        evidence = Path(item["evidence"])
        if digest(evidence) != item["evidence_sha256"]:
            raise ValueError("Original replacement evidence changed")
        if disposition == "infrastructure_replacement_candidate":
            if evidence.name == "result.json" and json.loads(evidence.read_text())["outcome"]["scored"] is True:
                raise ValueError("Scored original cannot be a replacement candidate")
            replacements[key(item)] = {name: item[name] for name in ("evidence", "evidence_sha256", "reason")}
        if disposition == "retain_scored_no_retry":
            entry = entries.get(key(item), {})
            if entry.get("status") != "finished" or entry.get("results") != [str(evidence)]:
                raise ValueError("Scored original must remain in the ledger without retry")
            original = json.loads(evidence.read_text())
            if original["task"] != item["task"] or original["outcome"]["scored"] is not True:
                raise ValueError("Scored original evidence is invalid")
    return replacements


def run(root, approval_path):
    # Authorization is written only after explicit user scored-launch approval.
    # Read it before importing Modal or any provider module.
    spec_path = root / "prepared.json"
    spec = json.loads(spec_path.read_text())
    approval = json.loads(approval_path.read_text())
    if approval.get("user_explicitly_approved_scored_launch") is not True or approval.get("prepared_sha256") != digest(spec_path):
        raise ValueError("Explicit scored-launch approval for this preparation required")
    if "status" in spec and spec["status"] != "launch_ready":
        raise ValueError("Preparation is not launch ready; infrastructure validation required")
    billing = approval["billing"]
    if not 0 <= time.time() - billing["observed_at"] <= 300:
        raise ValueError("Fresh billing verification required for each batch")
    if billing["spend_limit_usd"] != 0 or billing["usage_ceiling_usd"] != 25 or billing["net_spend_usd"] != 0:
        raise ValueError("Existing zero-paid-spend controls must be verified unchanged")
    available = min(billing["free_credits_usd"], 25 - billing["usage_usd"])
    if available <= 1:
        raise ValueError("No free compute after reserve")
    # Conservative stopwatch envelope includes startup, builds, idle and checks.
    seconds = int((available - 1) / 1.50 * 3600)
    expires_at = min(time.time() + seconds, billing["cycle_ends_at"] - 300)
    if expires_at - time.time() < 600:
        raise ValueError("Too close to free-credit cycle boundary")
    # Reject a known local blocker before importing or starting remote compute.
    # Keep the per-wave check too: disk availability can change during a stage.
    if shutil.disk_usage(root).free < 12 * 1024**3:
        raise ValueError("At least 12 GiB free disk required before starting compute")
    verify(spec)
    ledger_path = root / "ledger.json"
    ledger = json.loads(ledger_path.read_text())
    replacement_origins = verify_replacements(spec, ledger)
    budget = load_module("staged_budget", REPO / "experiments/staged-baseline-budget.py")
    remaining = budget.prepare(spec["plan"], spec["profiles"], ledger, available)
    if not remaining["waves"]:
        raise ValueError("No complete wave fits; wait for another credit cycle")
    batch = root / ("batch-" + secrets.token_hex(6))
    batch.mkdir()
    save(batch / "authorization.json", approval)
    save(batch / "bounds.json", {"expires_at": expires_at, "one_gpu": True, "hourly_reservation_usd": 1.5})
    os.environ["QWEN_BASELINE_IMAGE_ID"] = spec["private_image_id"]
    os.environ["QWEN_BATCH_EXPIRES_AT"] = str(expires_at)
    import modal
    provider = load_module("staged_qwen_provider", REPO / "experiments/staged_qwen_provider.py")
    bridge = load_module("staged_bridge", REPO / "experiments/concurrent-modal-bridge.py")
    server = None
    app_id = None
    event = {"status": "failed", "scored_launch": True}
    try:
        with modal.enable_output(), provider.app.run(detach=True):
            app_id = provider.app.app_id
            save(batch / "app.json", {"app_id": app_id})
            gate = provider.packaging_check.spawn().get(timeout=60)
            if gate["source_sha256"] != spec["sources"]["staged_qwen_provider.py"] or gate["gpu_requested"]:
                raise ValueError("CPU packaging verification failed")
            model = provider.Qwen()
            metadata = model.complete.spawn(None).get(timeout=420)
            save(batch / "metadata.json", metadata)
            if (metadata["hashes"] != spec["model_hashes"] or
                metadata["source_sha256"] != spec["sources"]["staged_qwen_provider.py"] or
                metadata["toolchain"]["source_sha256"] != spec["sources"]["qwen_cuda_environment.py"]):
                raise ValueError("Remote source or model changed")
            token = secrets.token_hex(32)
            deadline = time.monotonic() + max(0, expires_at - time.time())
            server = bridge.bridge(model, token, batch / "rpc", spec["settings"], deadline, max_inflight=4)
            env = dict(os.environ, BUNDLE_GEMFILE=str(REPO / "experiments/leaderboard.Gemfile"),
                       GPUSTACK_API_BASE=f"http://127.0.0.1:{server.server_port}/v1", MODAL_BRIDGE_TOKEN=token)
            profiles = {p["task"]: p for p in spec["profiles"]}
            while True:
                # Shared inference faults invalidate admission for later tasks,
                # even when each upstream harness writes an unscored result.
                if any((batch / "rpc").glob("*.error.json")):
                    event["status"] = "shared_provider_failure"
                    break
                verify(spec)
                verify_replacements(spec, ledger)
                pending = [a for a in spec["plan"]["attempts"] if (a["task"], a["attempt"]) not in
                           {(x["task"], x["attempt"]) for x in ledger}]
                if not pending:
                    event["status"] = "all_attempts_finished"
                    break
                wave = pending[:4]
                needed = max(float(budget.seconds(profiles[a["task"]])) for a in wave)
                if time.monotonic() + needed >= deadline:
                    event["status"] = "free_credit_admission_boundary"
                    break
                if shutil.disk_usage(root).free < 12 * 1024**3:
                    event["status"] = "disk_admission_boundary"
                    break
                # Persist all identities before starting any process. Even a
                # crash before generation never authorizes an automatic retry.
                for attempt in wave:
                    record = {"task": attempt["task"], "attempt": attempt["attempt"],
                              "status": "started", "started_at": time.time(), "batch": batch.name}
                    origin = replacement_origins.get((attempt["task"], attempt["attempt"]))
                    if origin:
                        record["replacement_of"] = origin
                    ledger.append(record)
                save(ledger_path, ledger)

                def execute(attempt):
                    trial = batch / f'{attempt["task"]}-{attempt["attempt"]}'
                    trial.mkdir()
                    args = ["bundle", "exec", "ruby", str(REPO / "experiments/staged-harness.rb"), "run",
                            "--bench", spec["benchmark_path"], "--backend", "docker",
                            "--model", "gpustack/Qwen/Qwen3.5-4B", "--max_output_tokens", "32768",
                            "--task", attempt["task"], "--attempts", "1", "--concurrency", "1", "--runs_dir", str(trial)]
                    # No --agent override, retries, result editing or regrading.
                    with (trial / "harness.log").open("w") as log:
                        code = subprocess.run(args, env=env, cwd=REPO, stdout=log, stderr=log).returncode
                    return {"task": attempt["task"], "attempt": attempt["attempt"], "returncode": code,
                            "status": "finished", "finished_at": time.time(),
                            "results": [str(p) for p in trial.rglob("result.json")]}

                with ThreadPoolExecutor(max_workers=4) as pool:
                    outcomes = list(pool.map(execute, wave))
                for outcome in outcomes:
                    next(x for x in ledger if (x["task"], x["attempt"]) == (outcome["task"], outcome["attempt"])).update(outcome)
                save(ledger_path, ledger)
                # Unscored results are retained and independent tasks continue.
                # A failed harness with no result is a global environment issue.
                if any(not x["results"] for x in outcomes) or any(
                    json.loads(Path(path).read_text()).get("outcome", {}).get("name") == "environment_error"
                    for x in outcomes for path in x["results"]
                ):
                    event["status"] = "environment_failure"
                    break
    except Exception as error:
        event["error"] = repr(error)
    finally:
        if server:
            server.shutdown()
            server.server_close()
        # Detached apps survive a transient client disconnect. Stop the exact
        # app explicitly after all started trials have settled. The remote
        # absolute deadline remains the independent bound if this host dies.
        if app_id:
            try:
                stopped = subprocess.run(
                    [sys.executable, "-m", "modal", "app", "stop", "--yes", app_id],
                    capture_output=True, text=True, timeout=60)
                save(batch / "app-stop.json", {"returncode": stopped.returncode,
                    "stdout": stopped.stdout, "stderr": stopped.stderr})
                if stopped.returncode:
                    event["shutdown_error"] = "Explicit app stop failed; verify exact app lifecycle"
            except Exception as error:
                save(batch / "app-stop.json", {"error": repr(error)})
                event["shutdown_error"] = "Explicit app stop failed; verify exact app lifecycle"
        event.update(finished_at=time.time(), ledger_attempts=len(ledger))
        save(batch / "event.json", event)
        message = (f"The explicitly authorized staged baseline batch finished. Read {batch}/event.json and the original ledger/results. "
                   "Verify exact app shutdown, Docker cleanup, frozen provenance and budget. Preserve scored/unscored outcomes, reward and credit; "
                   "do not rerun or regrade. Update the checkpoint with honest coverage. Raw evidence stays local and out of training. "
                   "No automatic next-cycle launch, paid spending or training. Deliver a direct callback only; no polling.")
        try:
            delivery = subprocess.run(["codex", "queue", "--thread", approval["callback_thread"], "--message", message],
                                      capture_output=True, text=True, timeout=30)
            save(batch / "delivery.json", {"returncode": delivery.returncode, "stdout": delivery.stdout, "stderr": delivery.stderr})
        except Exception as error:
            save(batch / "delivery.json", {"error": repr(error)})


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("--approval", type=Path, required=True)
    args = parser.parse_args()
    with (args.root / "controller.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        run(args.root, args.approval)
