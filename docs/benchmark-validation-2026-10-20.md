# Broader local benchmark validation

Pinned benchmark revision: `f587d5a44897f3467af2a48c0503aef4eb6acf55`.
Evidence: `runs/benchmark-validation-7HzR6h`, including `scope.json`.
The benchmark checkout was clean before execution.

| Task | Agent | Trial | Outcome | Reward | Seconds |
| --- | --- | --- | --- | --- | --- |
| at-compact-positions | oracle | at-compact-positions__eR9tk4Y | completed | 1.0 | 41.6 |
| at-compact-positions | nop | at-compact-positions__3aaLMAM | completed | 0.0 | 42.8 |
| at-tenant-isolation | oracle | at-tenant-isolation__W2iPWPh | completed | 1.0 | 58.9 |
| at-tenant-isolation | nop | at-tenant-isolation__oLvpWQR | completed | 0.0 | 38.1 |

All four runs used zero input/output model tokens. The configured model label
in harness output is inherited metadata; oracle/nop do not call that model.
These results broaden infrastructure validation from the earlier announce-once
check to three official tasks cumulatively. They are not an official model
baseline or evidence about Qwen performance. No benchmark material was sent
to Colab, and benchmark prompts, reference solutions, graders, and logs stay
excluded from training.

`bin/validate-benchmark` now accepts an explicit task list, defaults to the
original announce-once task, and writes each invocation into a fresh directory.
It records revision/scope and checks one completed result, expected oracle/nop
reward, and zero token usage per task/agent. It rejects an unknown task before
starting a run. An isolated Docker configuration uses anonymous public-registry
access without changing the user's Docker credentials.

The Colab report also exposes recorded DOM fallback attempts and request IDs.
Absent browser event evidence is reported as unavailable rather than proving
an unassisted run. Nine report fixtures pass, including assisted-delivery and
unrelated-event rejection. The current expense report records 12 fallbacks;
its unscored result is unchanged.
