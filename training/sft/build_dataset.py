"""Builds the SFT dataset from the model's own full-credit attempts at
train-split tasks: rejection sampling, where the tests and the API check
are the filter.

    python3 training/sft/build_dataset.py OUT.jsonl RUNS_DIR [RUNS_DIR ...]

Each line is one attempt as chat messages (system, user, then assistant turns
with their reasoning and bash calls, each followed by the tool output) plus
the tool schema the agent sent. Only tasks listed under "train" in
training/splits.json or training/app-splits.json are used; anything else is
an error, so held-out tasks can't leak in. At most PER_TASK attempts per
task are kept, the ones with the fewest steps, so tasks the model solves
every time don't dominate.
"""
import json
import os
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PER_TASK = int(os.environ.get("PER_TASK", "4"))

# The agent's only tool, exactly as miniswen sends it (see a logged request).
TOOLS = [{"type": "function", "function": {
    "name": "bash", "description": "Execute a bash command",
    "parameters": {"type": "object",
                   "properties": {"command": {"type": "string", "description": "The bash command to execute"}},
                   "required": ["command"], "additionalProperties": False, "strict": True}}}]


def splits():
    train, held_out = set(), set()
    for name in ("splits.json", "app-splits.json"):
        for split, tasks in json.loads((ROOT / name).read_text()).items():
            if isinstance(tasks, list):
                (train if split == "train" else held_out).update(tasks)
    return train, held_out


def messages(trajectory):
    out = []
    for step in trajectory["steps"]:
        source = step["source"]
        if source in ("system", "user"):
            out.append({"role": source, "content": step["message"]})
            continue
        calls = step.get("tool_calls") or []
        out.append({"role": "assistant", "content": step.get("message") or "",
                    "reasoning_content": step.get("reasoning_content") or "",
                    "tool_calls": [{"id": c["tool_call_id"], "type": "function",
                                    "function": {"name": c["function_name"],
                                                 "arguments": json.dumps(c["arguments"])}} for c in calls]})
        for result in (step.get("observation") or {}).get("results", []):
            out.append({"role": "tool", "tool_call_id": result["source_call_id"], "content": result["content"]})
    return out


def main(out_path, *runs_dirs):
    train, held_out = splits()
    by_task = defaultdict(list)
    for runs in runs_dirs:
        for result_path in Path(runs).glob("*/*/result.json"):
            result = json.loads(result_path.read_text())
            task = result["task"]
            if task in held_out or task not in train:
                if result.get("reward") == 1.0 and task in held_out:
                    print(f"skipping held-out task {task}", file=sys.stderr)
                continue
            if result.get("reward") != 1.0:
                continue
            trajectory = json.loads((result_path.parent / "trajectory.json").read_text())
            if trajectory.get("extra", {}).get("status") == "error":
                continue
            by_task[task].append((trajectory["final_metrics"]["total_steps"], result["trial"], trajectory))

    with open(out_path, "w") as out:
        kept = 0
        for task in sorted(by_task):
            for steps, trial, trajectory in sorted(by_task[task], key=lambda x: x[:2])[:PER_TASK]:
                out.write(json.dumps({"task": task, "trial": trial, "tools": TOOLS,
                                      "messages": messages(trajectory)}) + "\n")
                kept += 1
    solved = {t: len(v) for t, v in sorted(by_task.items())}
    print(f"{kept} examples from {len(solved)} of {len(train)} train tasks "
          f"({sum(solved.values())} full-credit attempts before the cap of {PER_TASK}): {solved}")


if __name__ == "__main__":
    main(*sys.argv[1:])
