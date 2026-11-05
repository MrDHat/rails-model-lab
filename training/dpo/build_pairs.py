"""Builds preference pairs from the model's own attempts at train-split tasks:
on the same task, one attempt that got full credit (chosen) and one that
didn't (rejected: 0.1, tests pass but the intended Rails API is missing, or
0). Unscored attempts (the agent crashed or ran out of context) are left out.

    python3 training/dpo/build_pairs.py OUT.jsonl RUNS_DIR [RUNS_DIR ...]

Only tasks under "train" in the split files are used, as for SFT. Each task
gives at most PER_TASK pairs, spread over its attempts so one transcript
doesn't fill every pair, and preferring rejected attempts at 0.1, the
mistake the model makes most on held-out tasks.
"""
import itertools
import json
import os
import sys
from collections import defaultdict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "sft"))
from build_dataset import TOOLS, messages, splits  # noqa: E402

PER_TASK = int(os.environ.get("PER_TASK", "6"))


def attempts(runs_dirs, train, held_out):
    by_task = defaultdict(list)
    for runs in runs_dirs:
        for result_path in Path(runs).glob("*/*/result.json"):
            result = json.loads(result_path.read_text())
            task, reward = result["task"], result.get("reward")
            if task in held_out or task not in train or reward is None:
                continue
            trajectory = json.loads((result_path.parent / "trajectory.json").read_text())
            if trajectory.get("extra", {}).get("status") == "error":
                continue
            by_task[task].append({"trial": result["trial"], "reward": reward,
                                  "steps": trajectory["final_metrics"]["total_steps"],
                                  "messages": messages(trajectory)})
    return by_task


def pick(chosen, rejected):
    """Up to PER_TASK pairs, each attempt used as evenly as possible."""
    chosen = sorted(chosen, key=lambda a: (a["steps"], a["trial"]))
    rejected = sorted(rejected, key=lambda a: (-a["reward"], a["steps"], a["trial"]))
    pairs = list(itertools.product(range(len(chosen)), range(len(rejected))))
    # Diagonals first: (0,0), (1,1), ... then (0,1), (1,2), ...
    pairs.sort(key=lambda p: ((p[1] - p[0]) % len(rejected), p[0]))
    return [(chosen[c], rejected[r]) for c, r in pairs[:PER_TASK]]


def main(out_path, *runs_dirs):
    train, held_out = splits()
    by_task = attempts(runs_dirs, train, held_out)
    counts = {}
    with open(out_path, "w") as out:
        for task in sorted(by_task):
            chosen = [a for a in by_task[task] if a["reward"] == 1.0]
            rejected = [a for a in by_task[task] if a["reward"] < 1.0]
            if not chosen or not rejected:
                continue
            for good, bad in pick(chosen, rejected):
                out.write(json.dumps({"task": task, "tools": TOOLS,
                                      "chosen": {"trial": good["trial"], "messages": good["messages"]},
                                      "rejected": {"trial": bad["trial"], "reward": bad["reward"],
                                                   "messages": bad["messages"]}}) + "\n")
            counts[task] = min(PER_TASK, len(chosen) * len(rejected))
    print(f"{sum(counts.values())} pairs from {len(counts)} train tasks: {counts}")


if __name__ == "__main__":
    main(*sys.argv[1:])
