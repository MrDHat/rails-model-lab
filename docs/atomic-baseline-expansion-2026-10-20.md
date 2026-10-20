# Remaining atomic baseline: prospective scope

Run the sixteen remaining official atomic tasks once each. The three attempts
already recorded in `docs/results.md` remain unchanged and are not rerun.
This is an evaluation-only phase: no training is authorized. Training requires
the user's explicit approval of the separate candidate-example PRs.

## Assignment and execution order

Assignment precedes every new attempt. Each new group contains three easy,
four medium and one hard task, using the pinned upstream difficulty labels.
This is a pragmatic development/holdout split within one application, not a
claim that related Rails capabilities or public benchmark data are independent.

| Order | Official task | Group | Difficulty |
| --- | --- | --- | --- |
| 1 | at-archive-book-access | Development | Easy |
| 2 | at-bulk-access-grants | Development | Medium |
| 3 | at-deep-link-return | Development | Medium |
| 4 | at-error-page-flake | Development | Easy |
| 5 | at-legacy-conversions | Development | Easy |
| 6 | at-log-to-terminal | Development | Medium |
| 7 | at-purge-embedded-images | Development | Hard |
| 8 | at-scoped-broadcast | Development | Medium |
| 9 | at-release-recap | Held out | Easy |
| 10 | at-resumable-cleanup | Held out | Easy |
| 11 | at-throttle-search | Held out | Easy |
| 12 | at-audit-sweep | Held out | Medium |
| 13 | at-enqueue-after-commit | Held out | Medium |
| 14 | at-toc-cache-per-role | Held out | Medium |
| 15 | at-variant-processed-once | Held out | Medium |
| 16 | at-erase-account | Held out | Hard |

## Unchanged execution

Use `bin/validate-benchmark TASK` for oracle/nop controls before the model
attempt on that task. Controls make no model calls. Stop if a control fails;
do not change a task, grader or model response to make it pass.

Use `bin/run-local-evaluation TASK` sequentially with the existing local MLX
model, lemans 1.5.2, miniswen and the unchanged official grader. Benchmark:
`f587d5a44897f3467af2a48c0503aef4eb6acf55`. Model:
`mlx-community/Qwen3.5-4B-4bit`, revision
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`.

Keep the original settings: 32 steps, 16,384 input / 2,048 output tokens,
greedy decoding, thinking disabled, EOS 248046, prefill 1,024, no history
truncation/sliding cache, 30-minute agent deadline, 600-second response deadline,
60-second command timeout. A scored timeout remains a scored failure.
Infrastructure failures remain unscored. Preserve every attempt; no automatic
reruns, hints, tool-output repairs, regrading or selecting the best result.

The batch stops launching tasks after an infrastructure failure, failed input
hash check, less than 2 GiB free before a task, or a resource/monitor failure.
A detected problem never automatically kills or restarts an active attempt.
Remaining tasks are recorded as not run. Retain all evidence under ignored
`runs/`; do not publish raw evidence or official evaluation materials.

## Holdout and delivery

For held-out attempts, the coordinator may inspect the harness's scored flag
to distinguish infrastructure failure from scored completion, and verify input
hashes. Do not inspect or publish reward, credit, patches, trajectories or
verifier diagnostics. Retain those files locally and seal them by SHA-256.
Do not expose held-out baseline results to training/checkpoint selection.
Unlock them only after a trained checkpoint and final comparison protocol are
frozen, or on an explicit user instruction to abandon the holdout.

Training candidates come from independent, newly authored examples. Benchmark
instructions, configurations, graders, reference solutions, generated patches
and run outputs never enter training data. Candidate PR review is not approval
to run training; obtain the user's explicit training authorization first.

A detached local coordinator advances through the fixed scope without agent
polling. It queues one message to the existing chat on batch completion or an
actionable failure, using the already verified `codex queue` delivery route.
No scheduled heartbeat is created. A delivery receipt precedes the queue call
so an ambiguous failure is not automatically resent.

Report development reward and credit separately, with the scored denominator
and infrastructure failure count. Held-out PRs record completion/sealing only.
Do not publish a combined nineteen-task score while the holdout is sealed.
