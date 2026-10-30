#!/usr/bin/env python3
"""Plan conservative free-credit waves. Never launch inference or a verifier."""
import argparse
from collections import Counter
from decimal import Decimal, ROUND_CEILING
import hashlib
import json
import math
from pathlib import Path


def seconds(task):
    # Whole multistep attempts stay in one wave, never split across cycles.
    fields = ("sessions", "timeout", "exec_timeout", "build_timeout", "verifier_timeout")
    if any(not isinstance(task[k], (int, float)) or isinstance(task[k], bool)
           or not math.isfinite(task[k]) or task[k] <= 0 for k in fields):
        raise ValueError("Invalid task allowance")
    if int(task["sessions"]) != task["sessions"]:
        raise ValueError("Noninteger session count")
    return (Decimal(str(task["build_timeout"])) + Decimal(str(task["sessions"])) *
            (Decimal(str(task["timeout"])) + Decimal(str(task["exec_timeout"])) +
             Decimal(str(task["verifier_timeout"])) + 120) + 1800)


def prepare(plan, profiles, completed, available, slots=4, hourly="1.50", reserve="1.00"):
    if slots not in (1, 2, 4):
        raise ValueError("Unsupported wave concurrency")
    available, hourly, reserve = map(Decimal, (str(available), str(hourly), str(reserve)))
    if not all(x.is_finite() for x in (available, hourly, reserve)) or min(available, reserve) < 0 or hourly < Decimal("1.50"):
        raise ValueError("Invalid budget or rate below conservative configured allowance")
    attempts = plan["attempts"]
    if any(a.get("status") != "not_started" for a in attempts):
        raise ValueError("Use the immutable unstarted plan and separate attempted ledger")
    ids = [(a["task"], a["attempt"]) for a in attempts]
    if len(ids) != 135 or len(set(ids)) != 135:
        raise ValueError("Expected 135 unique attempts")
    counts = Counter(t for t, _ in ids)
    twice = {"ms-greenfield-helpdesk", "ms-redmine-rails-upgrade", "ms-retire-proposals"}
    if len(counts) != 46 or any(n != (2 if t in twice else 3) for t, n in counts.items()) or not twice <= counts.keys():
        raise ValueError("Wrong repetition schedule")
    if any({i for task, i in ids if task == t} != set(range(1, count + 1)) for t, count in counts.items()):
        raise ValueError("Wrong attempt identities")
    tasks = {p["task"]: p for p in profiles}
    if len(tasks) != len(profiles) or tasks.keys() != counts.keys():
        raise ValueError("Profiles differ from task plan")
    done = {(a["task"], a["attempt"]) for a in completed}
    if len(done) != len(completed) or not done <= set(ids):
        raise ValueError("Unknown or duplicate ledger attempt")
    # Started, interrupted, failed and scored all count as attempted. A score
    # must never affect admission or cause replacement with another attempt.
    pending = [(t, i) for t, i in ids if (t, i) not in done]
    waves, remaining = [], max(Decimal(0), available - reserve)
    for offset in range(0, len(pending), slots):
        group = pending[offset:offset + slots]
        duration = max(seconds(tasks[t]) for t, _ in group)
        charge = (duration * hourly / 3600).quantize(Decimal("0.01"), rounding=ROUND_CEILING)
        if charge > remaining:
            break
        waves.append({"attempts": [{"task": t, "attempt": i, "agent": tasks[t]["agent"]} for t, i in group],
                      "reserved_seconds": float(duration), "reserved_compute_usd": str(charge)})
        remaining -= charge
    admitted = sum(len(w["attempts"]) for w in waves)
    return {"status": "dry_run_only", "launch_authorized": False, "wave_slots": slots,
            "available_free_allowance_usd": str(available), "overhead_reserve_usd": str(reserve),
            "resource_reservation_rate_usd_hour": str(hourly), "already_attempted": len(done),
            "planned_this_cycle": admitted, "remaining_after_cycle": len(pending) - admitted,
            "unallocated_compute_allowance_usd": str(remaining), "waves": waves,
            "policy": "Fixed manifest order; no retries; waves do not overlap; one GPU; whole attempts only. "
                      "Manual billing input is planning evidence, never runtime admission authority."}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=Path)
    parser.add_argument("profiles", type=Path)
    parser.add_argument("--ledger", type=Path, help="JSON list of every already-started attempt")
    parser.add_argument("--available", required=True, help="Minimum of free credits and workspace ceiling headroom")
    parser.add_argument("--slots", type=int, default=4)
    args = parser.parse_args()
    result = prepare(json.loads(args.plan.read_text()), json.loads(args.profiles.read_text()),
                     json.loads(args.ledger.read_text()) if args.ledger else [], args.available, args.slots)
    result["input_sha256"] = {name: hashlib.sha256(path.read_bytes()).hexdigest()
                              for name, path in (("plan", args.plan), ("profiles", args.profiles))}
    print(json.dumps(result, indent=2))
