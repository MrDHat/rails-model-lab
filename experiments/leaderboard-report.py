#!/usr/bin/env python3
"""Read original result.json only; never execute inference or a verifier."""
import argparse
import json
from collections import defaultdict
from pathlib import Path
from statistics import mean


def load_ledger_results(path):
    """Read only ledger-selected originals/replacements, including external originals."""
    results, identities, paths = [], set(), set()
    for entry in json.loads(path.read_text()):
        identity = (entry["task"], entry["attempt"])
        if identity in identities:
            raise ValueError("Duplicate ledger identity")
        identities.add(identity)
        if entry["status"] != "finished":
            continue
        evidence = entry.get("results", [])
        if len(evidence) > 1:
            raise ValueError("Ambiguous ledger result evidence")
        for name in evidence:
            source = Path(name)
            if not source.is_absolute():
                source = path.parent / source
            source = source.resolve()
            if source in paths:
                raise ValueError("Duplicate ledger result evidence")
            paths.add(source)
            result = json.loads(source.read_text())
            if result["task"] != entry["task"]:
                raise ValueError("Ledger task differs from result evidence")
            results.append(result)
    return results


def summarize(plan, results):
    results = list(results)
    if not plan["attempts"]:
        raise ValueError("Empty attempt plan")
    expected = defaultdict(int)
    for attempt in plan["attempts"]:
        expected[attempt["task"]] += 1
    groups, identities = defaultdict(list), set()
    models = {r.get("model") for r in results}
    if len(models) > 1:
        raise ValueError("Mixed model configurations")
    if "model" in plan and models - {plan["model"]}:
        raise ValueError("Model differs from frozen plan")
    for result in results:
        task, identity = result["task"], result["trial"]
        if task not in expected or identity in identities:
            raise ValueError("Unexpected task or duplicate trial")
        identities.add(identity)
        groups[task].append(result)
        if len(groups[task]) > expected[task]:
            raise ValueError("Extra attempts; do not select the best subset")
        if result["outcome"]["scored"]:
            for name in ("reward", "credit"):
                value = result.get(name)
                if not isinstance(value, (int, float)) or not 0 <= value <= 1:
                    raise ValueError(f"Scored result lacks valid {name}")
    rows = []
    for task, count in sorted(expected.items()):
        attempts = groups[task]
        scored = [r for r in attempts if r["outcome"]["scored"]]
        rows.append({"task": task, "expected": count, "attempted": len(attempts),
                     "scored": len(scored), "unscored": len(attempts) - len(scored),
                     "mean_credit": mean(r["credit"] for r in scored) if scored else None,
                     "mean_reward": mean(r["reward"] for r in scored) if scored else None})
    complete = all(r["scored"] == r["expected"] for r in rows)
    return {"complete": complete,
            "accuracy_percent": 100 * mean(r["mean_credit"] for r in rows) if complete else None,
            "tasks": rows,
            # Preserve absent values on unscored original results.
            "attempts": [{k: r.get(k) for k in ("task", "trial", "outcome", "reward", "credit", "duration", "usage")}
                         for r in results],
            "cost_note": "Harness token fees exclude separately billed GPU compute."}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=Path)
    parser.add_argument("trials", type=Path, help="Trial directory, or ledger JSON when --ledger is set")
    parser.add_argument("--ledger", action="store_true", help="Read explicit ledger result paths, including retained originals")
    args = parser.parse_args()
    results = (load_ledger_results(args.trials) if args.ledger else
               [json.loads(p.read_text()) for p in sorted(args.trials.rglob("result.json"))])
    print(json.dumps(summarize(json.loads(args.plan.read_text()), results), indent=2))
