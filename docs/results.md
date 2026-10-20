# Evaluation evidence and retained history

## Current checkpoint

Two official model attempts completed on 2026-10-20. The planned three-task
baseline remains incomplete; no training run has occurred.

| Official task | Outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| `at-announce-once` | Completed / submitted | 0.0 | 0.0 | 30 | 1399.1 |
| `at-compact-positions` | Completed / submitted | 1.0 | 0.10 | 19 | 544.6 |
| `at-tenant-isolation` | Not run: low free disk space | — | — | — | — |

Among the two scored attempts, one solved (50%), mean reward 0.50 and mean
credit 0.05; zero infrastructure failures. These are interim results for two
tasks, not a completed three-task baseline or full-benchmark estimate.
Both agents explicitly submitted with empty submission bodies.

Inference ran offline on the Mac GPU through MLX, with Docker executing the
official Rails tasks. Both runs used clean source
`88ecc36c0d4fb7a2fab46956d4c21cf86c48110c`, the pinned benchmark/model,
lemans 1.5.2 and all settings in the
[frozen protocol](local-baseline-protocol-2026-10-20.md). No hints, repairs,
hidden feedback or configuration changes were supplied during either attempt.

| Evidence directory | Trial | Input / output tokens | Generation seconds | Peak unified GiB | Generated / consumed | Truncated |
| --- | --- | --- | --- | --- | --- | --- |
| `runs/local-evaluation-YyMIWG` | `at-announce-once__DrQJNzh` | 188916 / 5580 | 1360.33 | 4.037 | 30 / 30 | 1 |
| `runs/local-evaluation-W05Vqm` | `at-compact-positions__DQk0bSB` | 73718 / 1848 | 511.49 | 3.569 | 19 / 19 | 0 |

Neither run had pending, expired, late or runtime-error responses. Each directory
retains `summary.json`, frozen input/model hashes, runtime/source records,
the original patch, trajectory and unchanged harness/verifier outputs.

The announcement patch misused Rails' saved-change array as a hash, producing
six errors in the restored existing suite (179 runs, 529 assertions, two skips).
It received reward zero from the official verifier; this was a model failure,
not an infrastructure failure.

The compaction patch corrected a SQL column-name typo. Existing tests completed
with 179 runs, 553 assertions, zero failures/errors and two skips. The official
verification summary reported seven runs, nine assertions and zero failures/errors.
The verifier also printed a skipped-test notice; retain its raw output as written.
The harness awarded reward 1.0 but only credit 0.10: the patch did not use the
target Rails quoting API. Preserve this distinction rather than reporting full
credit for the task.

Free disk space was 3.9 GiB before launch, 2.8 GiB after the first task and
1.1 GiB after the second. Further model launches stopped under the protocol's
resource rule. The cause of the disk-space decrease has not been established.
No caches, run evidence or unrelated files were deleted.
Next: recover sufficient disk headroom, then run the remaining tenant-isolation
task once with the unchanged settings. Do not rerun the two completed attempts
to improve the score.

## Earlier development evidence

Official no-model
controls passed on `at-announce-once`, `at-compact-positions` and
`at-tenant-isolation`: each oracle/nop pair completed at 1.0/0.0 with zero model
tokens. Evidence: `runs/benchmark-validation-7HzR6h` and the original validation
record preserved in Git history.

The local model is the untrained community Qwen3.5-4B 4-bit variant pinned in
README. On the independent team-ticket development task:

| Attempt | Outcome | Generated / consumed | Evidence |
| --- | --- | --- | --- |
| Overnight local | Unscored verifier error after time limit; model introduced an undefined exception class | 22 / 22 | `runs/mlx-development-esBb0Q` |
| After grader fix | Unscored agent timeout; host sleep overlapped request 7's deadline | 6 / 6 | `runs/mlx-development-BMwrom` |
| With scoped idle-sleep guard | Completed, explicit submission at step 24, reward 1.0 | 24 / 24 | `runs/mlx-development-tPLUuK` |

The completed attempt used clean source `5b80a89`; all 28 frozen input hashes
were verified. The restored starter suite passed 3 tests / 12 assertions; hidden
verification passed 18 tests / 74 assertions. Usage: 101,101 input / 3,713 output
tokens, 767.26 generation seconds, 797.5 seconds total harness time, peak unified
memory allocation 3.652 GiB. No expired, late, truncated or runtime-error responses
occurred. The harness records status `submitted` with an empty submission body.
No hidden feedback, operator corrections or tool repairs were supplied.

The development grader fix passed 13 team-ticket and 10 expense mutation cases,
plus real harness oracle/nop controls at 1/0. Evidence:
`runs/team-ticket-grader-5gtr1h3a`, `runs/expense-grader-pku77rnu`,
`runs/development-validation-X2Bbhp`. First validation expectations were wrong
about autoload errors versus setup failure; those failed checks remain in
`runs/team-ticket-grader-n3cjtc6z` and `runs/expense-grader-n8hkk2my`.
The development graders are retired with their tasks; no official grader changes.

This one development pass establishes a working local route, not broad model
quality or training improvement. Previous unscored attempts retain their original
outcomes. The official subset above follows the
[frozen protocol](local-baseline-protocol-2026-10-20.md).

## Preserved experiment history

The previous stack is retained at commit `784805e` on branch
`codex/local-completion` ([checkpoint PR #18](https://github.com/MrDHat/rails-model-lab/pull/18)).
Its detailed records include:

- `docs/qwen-local-results-2026-10-20.md`: original local failure and Colab
  attempt that consumed 16 responses, then disconnected and timed out unscored.
- `docs/local-sleep-interruption-2026-10-20.md`: power-event/deadline evidence.
- `docs/local-completion-2026-10-20.md`: complete successful local run record.
- `docs/overnight-progress-2026-10-20.md`: earlier probes, failures and checkpoints.

Older main history also retains the initial expense pilot (reward 1.0 at step
limit, no submission), GPU memory failure, truncation/context failures, and Colab
transport experiments. These are separate experiments, not an official model
baseline. No failed attempt or raw ignored run directory was removed by cleanup.

PRs #7–#18 are superseded by one replacement against main. Preserve their branches;
do not merge the stack. No code from those PRs needs merging separately.

## Consolidation checks

The retained local provider and worker passed a fresh non-task live smoke
(`runs/local-cleanup-smoke-fKLScE`): exact `OK`, 16 input / 2 output tokens and a
consumption receipt. Five worker fixtures, nine report fixtures and Ruby
transport fixtures passed. The renamed report reproduces the successful
historical run's score, usage and consumption records.

Runner preparation alone (no model or trial) verified 780 frozen file hashes,
the official Dockerfile/task layout and unchanged official environment/verifier
configuration: `runs/local-evaluation-85PNVk/prepare-check.json`.

All six official oracle/nop controls passed again under the retained validator:
1.0/0.0 for each of the three tasks, completed with zero model tokens.
Evidence: `runs/benchmark-validation-QPkplX`.
