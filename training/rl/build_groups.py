"""Builds the RL batch from the model's own attempts at train-split tasks:
for each task, every scored attempt with its advantage, how much better it
did than the task's other attempts: its reward minus the task's mean reward.
Unlike GRPO this doesn't divide by the group's standard deviation, which
would push as hard on a 0.1-versus-0 difference as on full credit versus a
miss. Tasks where every attempt got the same reward teach nothing and are
left out.

    python3 training/rl/build_groups.py OUT.jsonl RUNS_DIR [RUNS_DIR ...]

Rewards are the graders' 1 (full credit), 0.1 (tests pass but the intended
Rails API is missing) or 0. Only tasks under "train" in the split files are
used, as for SFT and DPO.
"""
import json
import statistics
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "dpo"))
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "sft"))
from build_dataset import TOOLS, splits  # noqa: E402
from build_pairs import attempts  # noqa: E402


def main(out_path, *runs_dirs):
    train, held_out = splits()
    by_task = attempts(runs_dirs, train, held_out)
    kept = {}
    with open(out_path, "w") as out:
        for task in sorted(by_task):
            group = by_task[task]
            rewards = [a["reward"] for a in group]
            if len(group) < 2 or len(set(rewards)) == 1:
                continue
            mean = statistics.mean(rewards)
            for attempt in group:
                out.write(json.dumps({"task": task, "tools": TOOLS, "trial": attempt["trial"],
                                      "reward": attempt["reward"],
                                      "advantage": attempt["reward"] - mean,
                                      "messages": attempt["messages"]}) + "\n")
            kept[task] = f"{sum(r == 1.0 for r in rewards)}/{len(rewards)}"
    print(f"{sum(int(v.split('/')[1]) for v in kept.values())} attempts from {len(kept)} train tasks "
          f"with differing rewards (full credit/attempts): {kept}")


if __name__ == "__main__":
    main(*sys.argv[1:])
