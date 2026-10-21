# Evaluation evidence and retained history

## Current checkpoint: restricted-budget exploratory runs

The sixteen-task expansion finished on 2026-10-21 at 04:19:09 UTC. All sixteen
planned attempts ran once: eight development attempts completed with scored
outcomes, and eight held-out attempts completed with evidence sealed locally.
The coordinator recorded no infrastructure failures; all oracle/nop controls
passed before their model attempt. No training has run.

**These are restricted-budget exploratory results on official tasks, not the
baseline under the official evaluation profile.** The local runner used a
30-minute agent deadline, 32 steps and 60 seconds per command. The pinned
official profile specifies 90 minutes, 400 steps and 300 seconds respectively.
The local 16,384-input / 2,048-output token caps and other model settings also
remain distinct from the hosted profile. Keep the original labels and evidence;
do not present these outcomes as results under the official limits.

After the user clarified that the goal was the actual benchmark baseline, the
assistant said it would stop scheduling restricted attempts. That action was
not implemented: no stop marker was installed, and the original coordinator
completed its declared sixteen-task scope. The separate official-limit run
never started. This completion checkpoint records the actual execution; it
does not authorize or launch a replacement attempt.

### Eight additional development attempts

| Official task | Harness outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| `at-archive-book-access` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 23 | 2012.1 |
| `at-bulk-access-grants` | `step_limit_reached` / `step_limit` | 0.0 | 0.0 | 32 | 1479.9 |
| `at-deep-link-return` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 26 | 1869.0 |
| `at-error-page-flake` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 22 | 1938.5 |
| `at-legacy-conversions` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 23 | 2052.1 |
| `at-log-to-terminal` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 20 | 1964.2 |
| `at-purge-embedded-images` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 22 | 1869.0 |
| `at-scoped-broadcast` | `agent_timeout` / `time_limit` | 0.0 | 0.0 | 24 | 1854.1 |

All eight outcomes are scored: **0 solved / 8 scored**, mean reward 0.0 and
mean credit 0.0. Seven reached the agent deadline and one reached the step
limit; all eight exhausted a restricted cap. Do not attribute these results
solely to Rails knowledge or extrapolate them to the official budget. Preserve
actual durations, including cooperative timeout overruns. None explicitly
submitted. The earlier three-task subset remains unchanged: together the
eleven inspected development attempts have one solved task, with that task
awarded credit 0.10. This is not a nineteen-task aggregate.

| Task | Local evidence | Trial | Input / output tokens | Generation seconds | Peak unified GiB |
| --- | --- | --- | --- | --- | --- |
| `at-archive-book-access` | `runs/local-evaluation-F6dQDG` | `at-archive-book-access__pETOdvT` | 119338 / 1986 | 1950.06 | 3.748 |
| `at-bulk-access-grants` | `runs/local-evaluation-R6Snum` | `at-bulk-access-grants__GPucuUH` | 130391 / 1771 | 1434.31 | 3.569 |
| `at-deep-link-return` | `runs/local-evaluation-hdqslM` | `at-deep-link-return__nshHi3t` | 152269 / 3050 | 1815.17 | 3.739 |
| `at-error-page-flake` | `runs/local-evaluation-zZMcyB` | `at-error-page-flake__T2g43Vz` | 108753 / 2924 | 1888.05 | 3.702 |
| `at-legacy-conversions` | `runs/local-evaluation-Ztq0rC` | `at-legacy-conversions__caeoKUZ` | 114475 / 2158 | 1998.81 | 3.888 |
| `at-log-to-terminal` | `runs/local-evaluation-SQ4WQX` | `at-log-to-terminal__hzBEHjh` | 108012 / 1960 | 1915.80 | 3.780 |
| `at-purge-embedded-images` | `runs/local-evaluation-47Ug77` | `at-purge-embedded-images__v8buNTQ` | 109634 / 1038 | 1818.30 | 3.959 |
| `at-scoped-broadcast` | `runs/local-evaluation-laNI31` | `at-scoped-broadcast__JBENz5y` | 105276 / 1540 | 1795.28 | 3.647 |

All 192 development responses were generated and consumed, with no pending,
expired, late, runtime-error or truncated responses. Development totals:
948148 input / 16427 output tokens, 14615.78 generation seconds and 15038.9
harness wall seconds; peak unified allocation 3.959 GiB. Reports were generated
with the existing `bin/report-local-run`; raw evidence remains ignored locally.

### Held-out completion only

| Official task | Status |
| --- | --- |
| `at-release-recap` | Completed; sealed hashes verified |
| `at-resumable-cleanup` | Completed; sealed hashes verified |
| `at-throttle-search` | Completed; sealed hashes verified |
| `at-audit-sweep` | Completed; sealed hashes verified |
| `at-enqueue-after-commit` | Completed; sealed hashes verified |
| `at-toc-cache-per-role` | Completed; sealed hashes verified |
| `at-variant-processed-once` | Completed; sealed hashes verified |
| `at-erase-account` | Completed; sealed hashes verified |

No held-out reward, credit, patch, trajectory or verifier output was inspected
or published while handling this event. No combined nineteen-task score is
published. The holdout remains unavailable for training/checkpoint selection.

### Verification and continuation

All sixteen runs have clean recorded source
`df5712b2c126c0732e895131125a7d741f5d7d24`, the pinned benchmark/model revisions,
and unchanged runner/provider/worker/dependency snapshots. Verified all 780
frozen input hashes per run (12480 total), identical 11-file model manifests
across runs and the current cached model bytes. Verified each held-out seal
against its coordinator-recorded digest and every listed file hash (6925
sealed files total); no files were added to or removed from those sealed runs.

The finished event and one-time direct delivery are retained under
`runs/atomic-baseline-20261020/monitor/`; handling acknowledgement is written
after the checkpoint is pushed. No scheduled polling, rerun, regrading,
model hint, training or merge was performed for this completion.

The next baseline needs the official evaluation limits and an explicit audit
of remaining local model/provider differences. The prepared three-limit
profile alone is not the full official hosted configuration. No official-limit
controller or inference started, and no new attempt is launched by this event.

## Initial three-task restricted-budget subset

The initial three attempts on official tasks finished on 2026-10-20, with one
fresh attempt per task. No training run has occurred.

| Official task | Outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| `at-announce-once` | Completed / submitted | 0.0 | 0.0 | 30 | 1399.1 |
| `at-compact-positions` | Completed / submitted | 1.0 | 0.10 | 19 | 544.6 |
| `at-tenant-isolation` | Agent timeout / time_limit, no submission | 0.0 | 0.0 | 32 | 1925.5 |

Among all three scored attempts, one solved (33.3%), mean reward 0.3333 and mean
credit 0.0333; zero infrastructure failures. The timeout is scored by the
unchanged official harness and remains in the denominator. This small declared
subset is not a full-benchmark estimate or a variance estimate. The first two
agents explicitly submitted with empty submission bodies; the third did not.

Inference ran offline on the Mac GPU through MLX, with Docker executing the
official Rails tasks. The first two runs used clean source
`88ecc36c0d4fb7a2fab46956d4c21cf86c48110c`; the third used clean source
`b9cc9271e7192d42ac3616ec4eaafdea2b890473` (only result documentation changed).
All used the same pinned benchmark/model, lemans 1.5.2 and all settings in the
[frozen protocol](local-baseline-protocol-2026-10-20.md). No hints, repairs,
hidden feedback or configuration changes were supplied during any attempt.

| Evidence directory | Trial | Input / output tokens | Generation seconds | Peak unified GiB | Generated / consumed | Truncated |
| --- | --- | --- | --- | --- | --- | --- |
| `runs/local-evaluation-YyMIWG` | `at-announce-once__DrQJNzh` | 188916 / 5580 | 1360.33 | 4.037 | 30 / 30 | 1 |
| `runs/local-evaluation-W05Vqm` | `at-compact-positions__DQk0bSB` | 73718 / 1848 | 511.49 | 3.569 | 19 / 19 | 0 |
| `runs/local-evaluation-Pi1SXX` | `at-tenant-isolation__LOVpl49` | 242008 / 1738 | 1870.90 | 4.034 | 32 / 32 | 0 |

No run had pending, expired, late or runtime-error responses. Each directory
retains `summary.json`, frozen input/model hashes, runtime/source records,
the original patch, trajectory and unchanged harness/verifier outputs.
All 780 frozen input hashes per attempt were verified after execution, and
all three 11-file model manifests match. In total, 81 responses were generated
and consumed, using 504642 input / 9166 output tokens. Total generation time
was 3742.72 seconds and harness wall time was 3869.2 seconds. Peak unified
allocation across the subset was 4.037 GiB; one response was truncated.

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

Tenant isolation ended with harness outcome `agent_timeout`, scored true,
agent status `time_limit`, null submission and an empty repository patch.
The model explored the application and drafted migration files under `/tmp`
without implementing them in the repository. Existing tests remained green
(179 runs, 553 assertions, two skips), while official verification reported
11 runs, zero assertions and 11 errors because the required tenants table was
absent. The official harness awarded reward/credit 0.0; the errors are retained
as a scored task failure, not reclassified or regraded. The configured agent
limit was 30 minutes; actual agent phase was 1886.06 seconds and total harness
duration 1925.5 seconds. Preserve the measured overrun without claiming an exact
1800-second wall-time cutoff.

Free disk space was 3.9 GiB before launch, 2.8 GiB after the first task and
1.1 GiB after the second. Further model launches stopped under the protocol's
resource rule. The cause of the disk-space decrease has not been established.
No caches, run evidence or unrelated files were deleted.

On continuation, the benchmark checkout contained 8 GiB of upstream example
run logs outside the runner's inputs. Applying the setup script's intended
sparse checkout (`tasks docker apps`) removed those recoverable upstream files
from the working tree and restored free space to 9.8 GiB. The pinned checkout
remains clean; our own run evidence is untouched. This identifies reclaimable
space, not the cause of the earlier disk-space decrease.

The remaining task then launched once with unchanged settings. The detached
observer emitted its finished event at 18:52:39 UTC. A one-time notifier queued
a message to this existing chat through `codex queue` at 18:52:59 UTC; this chat
received it and recorded the result above. The scheduled heartbeat is paused.
The observer and notifier did not alter the frozen attempt. Delivery evidence
and acknowledgement are retained in the run's `monitor/` directory.

That initial restricted-budget subset is complete. Preserve its first-attempt results;
do not rerun them to select a better score. A future evaluation or training
phase requires a separately declared scope and keeps this baseline unchanged.

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
