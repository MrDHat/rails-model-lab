# Evaluation evidence and retained history

## Completed nineteen-task baseline (2026-10-23)

All nineteen authorized tasks have been attempted once under this profile:
eleven development attempts are reported below and eight held-out attempts
are completed and sealed. The final event was emitted at 01:57:30 UTC
(02:57:30 Europe/Dublin) on 23 October. The first five attempts were retained;
independent unstarted tasks continued after the input-limit failure. No task
was rerun or regraded, and the configuration stayed fixed.

Development outcomes: **one pass, nine scored failures, one unscored error**.
Among the ten scored development attempts, mean reward is 0.10 and mean credit
is 0.01. The unscored attempt has no reward, credit or usage in its original
harness result and is excluded from those means. There is no nineteen-task
aggregate while held-out outcomes remain sealed.

| Development task | Original harness outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| at-announce-once | completed (scored) / format_error, no submission | 0.0 | 0.00 | 19 | 893.9 |
| at-compact-positions | completed (scored) / submitted | 1.0 | 0.10 | 32 | 1120.5 |
| at-tenant-isolation | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 52 | 5449.6 |
| at-archive-book-access | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 35 | 5683.3 |
| at-bulk-access-grants | agent_error (unscored) / error, no submission | absent | absent | absent from harness result | 3905.0 |
| at-deep-link-return | completed (scored) / format_error, no submission | 0.0 | 0.00 | 19 | 2485.3 |
| at-error-page-flake | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 35 | 5520.1 |
| at-legacy-conversions | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 43 | 5628.0 |
| at-log-to-terminal | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 35 | 5546.9 |
| at-purge-embedded-images | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 41 | 5617.5 |
| at-scoped-broadcast | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.00 | 47 | 5551.2 |

The two format errors each followed three consecutive responses without a valid
bash tool call. Seven scored attempts reached the agent time limit; none
reached 400 steps. Compaction submitted with an empty submission message;
its original verifier reward remains 1.0 and credit 0.10. Bulk-access-grants
is unscored because `17377 > 16384` exceeded the input budget. Its 28 requests
and 27 successful generations do not replace missing harness step/usage data.
All eleven development reports have zero pending, expired or quarantined late
responses; bulk-access-grants has the single explicit input-budget error.

| Held-out task | Published status |
| --- | --- |
| at-release-recap | Completed; sealed and hashes verified |
| at-resumable-cleanup | Completed; sealed and hashes verified |
| at-throttle-search | Completed; sealed and hashes verified |
| at-audit-sweep | Completed; sealed and hashes verified |
| at-enqueue-after-commit | Completed; sealed and hashes verified |
| at-toc-cache-per-role | Completed; sealed and hashes verified |
| at-variant-processed-once | Completed; sealed and hashes verified |
| at-erase-account | Completed; sealed and hashes verified |

Held-out outcomes, rewards, credits, patches, trajectories and verifier logs
were not inspected. Verification read seal manifests and hashed raw bytes;
no held-out report or grading command was run. Seal manifests and raw evidence
remain ignored and local.

The fixed configuration was 90 minutes, 400 steps, 300-second commands,
16,384 input / 2,048 output tokens, greedy decoding, thinking disabled,
1,024-token prefill chunks and a 600-second response deadline. The model is
`mlx-community/Qwen3.5-4B-4bit` at
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`, running locally through MLX on
the M1 Mac; lemans 1.5.2/miniswen ran the unchanged official tasks/verifiers
at benchmark revision `f587d5a44897f3467af2a48c0503aef4eb6acf55`.
This uses the official time, step and command limits; the quantized model,
local inference speed and token caps differ from the hosted profile. The
cooperative time deadline can overrun. These results alone do not establish
performance under a faster runtime or larger context.

Final verification passed 14,820 frozen input hash checks, nineteen identical
model manifests against all eleven current model files, nineteen identical
frozen benchmark configurations, and all eight held-out seals including their
exact file sets and file hashes. All recorded working-tree patches are empty.
The first three attempts used source `e891e37`, the next two `351628f`, and the
last fourteen `e7082ea`; copied runner, provider, worker, Ruby/Python locks and
runtime metadata are byte-identical across all nineteen runs. The eleven
development reports were regenerated with `bin/report-local-run`, without
inference or grading. No benchmark inference process remained at final check.

All earlier interrupted and failed attempts remain in the historical records
below. The restricted-budget baseline remains a separate experiment. No
training ran; candidate evaluation PR review and explicit training authorization
are still required before any training. No further attempt was launched while
handling completion.

## Historical stop: input budget exceeded (2026-10-22)

The weights download completed and all eleven model files matched their
recorded hashes before continuation began. Archive-book-access then completed
with a scored timeout. Bulk-access-grants stopped with an unscored agent error,
and the controller stopped further launches at 01:16:35 Europe/Dublin
(00:16:35 UTC). The fixed local input guard rejected 17,377 tokens against the
16,384-token cap. No history truncation, retry, hint or regrading was applied.
This is the disclosed local context limitation, not a scored zero or a failure
to meet the benchmark's task requirements.

| Development task | Original harness outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| at-announce-once | completed (scored) / format_error, no submission | 0.0 | 0.0 | 19 | 893.9 |
| at-compact-positions | completed (scored) / submitted | 1.0 | 0.10 | 32 | 1120.5 |
| at-tenant-isolation | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.0 | 52 | 5449.6 |
| at-archive-book-access | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.0 | 35 | 5683.3 |
| at-bulk-access-grants | agent_error (unscored) / error, no submission | absent | absent | absent from harness result | 3905.0 |

Four scored attempts include one pass; the fifth is unscored and has no reward,
credit or usage fields in the original harness result. Do not fabricate those
fields, count it as a scored zero, or infer a full-benchmark score from this
partial prefix. Six development tasks and all eight held-out tasks remain
not run. No held-out outcome, patch, trajectory or verifier log was inspected;
there are no new held-out seals to verify.

Archive-book-access generated and consumed 35 responses, one output-truncated,
with no pending, expired, late or transport-error responses. Its agent phase
lasted about 94 minutes 3 seconds; the cooperative 90-minute deadline can
overrun. Bulk-access-grants had 28 requests, 27 successful generations, two
output-truncated responses and one explicit input-budget error. None remained
pending, expired or late. Generation counts do not substitute for missing
harness step/usage fields. Controls passed before both attempts; archive
controls were reused from the earlier successful validation without a rerun.

Verification regenerated all five development reports without grading, matched
3,900 frozen input hashes, five identical recorded model manifests against
all eleven current model files, and clean recorded source. The first three
attempts retain source `e891e37`; the new two use `351628f`. The restored weights
therefore match the earlier baseline bytes. Raw evidence and verification
records remain ignored and local. Controller, runner, worker and harness PIDs
had exited at diagnosis. No process was killed or restarted for this event.

No later task was launched, attempt rerun, model hint supplied, or training
performed while handling the event. The original 90m / 400-step / 300-second
profile and local token caps were unchanged. Any future change to context
handling must be explicit and recorded as a different configuration; preserve
this unscored result. This callback does not authorize new attempts or changes
to the frozen protocol.

## Historical stop: missing model weights (2026-10-21)

The controller emitted a failure at 22:21:22 Europe/Dublin (21:21:22 UTC):
`at-archive-book-access: missing unique evidence directory`. The underlying
runner log says `Expected the pinned local model snapshot`. Its preflight
refused to proceed before creating a model run directory or loading weights.
The snapshot directory exists, but its `model.safetensors` symlink points to
an absent cache blob. The other ten recorded model files still match their
hashes. When or why the weights became unavailable is not established.

Archive-book-access oracle and nop controls both completed with rewards
1.0 and 0.0 respectively, zero model tokens, and original harness outcomes
`completed`. This is a missing local artifact, not a failed control, scored
model failure or unscored harness trial. No fourth model trial exists.
The monitor's final task status says `running` because it was set before the
preflight command; it does not mean inference started. The controller and
runner PIDs have exited. No process was killed or restarted for this event.

The three completed model results remain unchanged: announcement reward /
credit 0.0 / 0.0 (format error, 19 steps, 893.9 seconds); compaction 1.0 / 0.10
(submitted, 32 steps, 1120.5 seconds); tenant isolation 0.0 / 0.0 (scored
agent timeout, 52 steps, 5449.6 seconds). All eight other development model
attempts and all eight held-out model attempts remain not run. No full-batch
score is reported, and no held-out scores or raw evidence were inspected.
There are no new held-out seals to verify.

Reverification matched 2,340 frozen input hashes, the three identical recorded
model manifests, empty recorded working-tree patches and original source
revision. Ten currently available model files match; the missing weights
cannot be reverified now. Earlier complete model-byte verification remains
historical evidence, not a claim that the file is still present. New controls
used source `770b57f`; no model trial used that revision. Raw controls, logs,
state and verification records remain local and ignored. Free space was
17 GiB at diagnosis; disk capacity is not the reported failure.

No weights were downloaded, no attempts rerun, no later tasks launched and no
training performed while handling this event. Before any future continuation,
restore the exact pinned weights and verify them against the recorded hash;
then retain the three completed model attempts and passed controls. This
callback does not authorize downloading or another launch.

## Continuation stopped before the fourth model attempt (2026-10-21)

The adopted tenant-isolation attempt finished with the original harness outcome
`agent_timeout` (scored), reward 0.0 and credit 0.0, agent status `time_limit`,
no submission, 52 steps and 5,449.6 wall seconds. Its agent phase lasted about
90 minutes 31 seconds; cooperative deadline checks can overrun 90 minutes.
All 52 responses were generated and consumed, with no pending, expired, late,
truncated or transport-error responses. This is a scored timeout, not an
unscored infrastructure failure. The original runner exit code is unavailable
because its parent exited; it is not inferred from the result.

| Development task | Original harness outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| at-announce-once | completed (scored) / format_error, no submission | 0.0 | 0.0 | 19 | 893.9 |
| at-compact-positions | completed (scored) / submitted | 1.0 | 0.10 | 32 | 1120.5 |
| at-tenant-isolation | agent_timeout (scored) / time_limit, no submission | 0.0 | 0.0 | 52 | 5449.6 |

At 21:36:21 Europe/Dublin (20:36:21 UTC), the continuation emitted a failure
before the next task's controls could run. Its launch environment selected
`/usr/bin/bundle` and macOS Ruby 2.6, which could not find Bundler 2.6.2. The
correct existing installation is Ruby 3.4.2 under
`/Users/mrdhat/.rbenv/versions/ruby-3.4.2/bin`, with Bundler 2.6.2 verified by
version-only commands. The continuation launcher failed to pin that runtime.
This is a launcher environment error, not an oracle failure or model result.
The validation directory contains only its scope record and no harness result.
No controls or attempts were retried while diagnosing it.

Three model attempts are now complete and scored; one passed. The other eight
development attempts and all eight held-out attempts remain not run. Do not
report this partial prefix as a full-benchmark result. No held-out scores,
patches, trajectories or verifier logs were inspected; no new held-out seals
exist. Earlier restricted-budget results remain separate.

Verification regenerated all three reports without grading, matched 2,340 frozen
input hashes, checked three identical model manifests against all eleven current
model files, and confirmed empty recorded working-tree patches and original
source revision `e891e37f3c6dc27756211c06b73c02c2a319fdb5` for all three attempts.
The continuation documentation revision is `0be6ffa`; it did not launch a model
attempt. All inspected benchmark/controller PIDs had exited. Free space was
3.7 GiB at diagnosis; disk pressure was not the reported failure this time.

The original low-disk event and continuation event remain preserved locally,
alongside raw reports and verification evidence. No process was killed or
restarted, no model attempt rerun, and no later model attempt launched. No
training ran or is authorized. A future continuation must explicitly select the
existing Ruby/Bundler runtime and preserve the three completed attempts; this
failure callback does not authorize a new launch or retry.

## Interruption (2026-10-21)

The coordinator emitted a failure at 19:51:20 UTC: free disk fell below
1 GiB (1,010,380,800 bytes observed). It exited without killing its active
child. A subsequent host check found only 145 MiB free; by 19:53:10 UTC this
had recovered to 5.5 GiB. The transient capacity drop's cause is not established.
macOS reported 12,473 MiB swap in use. The three run directories total about
40 MiB; Docker reported 1.85 GB images, 1.683 GB build cache and an active
11.27 MB container. These measurements do not establish which allocation
caused the event. Nothing was deleted or pruned.

| Development task | Harness outcome / agent status | Reward | Credit | Steps | Wall seconds |
| --- | --- | --- | --- | --- | --- |
| at-announce-once | completed (scored) / format_error; three consecutive responses without a valid bash tool call; no submission | 0.0 | 0.0 | 19 | 893.9 |
| at-compact-positions | completed (scored) / submitted | 1.0 | 0.10 | 32 | 1120.5 |
| at-tenant-isolation | active at diagnosis; no final score reported | pending | pending | pending | pending |

These attempts used 90 minutes / 400 steps / 300 seconds per command with
unchanged local token caps. Neither completed attempt exhausted the time or
step allowance. Announcement had three output-length-truncated responses;
compaction had none. No transport errors, expired, pending or late responses
were present in either completed report. Controls passed for all three started
tasks. Do not treat the incomplete batch as eleven development outcomes or a
nineteen-task aggregate.

The other eight development tasks and all eight held-out tasks remain not run.
There are no new held-out evidence seals to verify. No held-out scores,
trajectories, patches or verifier logs were inspected. Previous held-out results
remain sealed and separate.

Verification matched all 780 frozen input hashes per started run (2,340 checks),
all eleven model-file hashes per run, empty recorded working-tree patches and
source revision `e891e37f3c6dc27756211c06b73c02c2a319fdb5`. The existing report
command regenerated both completed development summaries without regrading.
Raw results and the verification record remain ignored and local.

At diagnosis, the tenant-isolation harness and MLX worker were still running;
the supervisor had exited. Its final outcome remains unresolved. No process
was killed or restarted, no task rerun, and no later task launched. The disk
recovery does not restart the batch. No training is authorized. Further action
requires reviewing capacity and the active attempt's eventual original result;
this checkpoint does not authorize restarting the coordinator or new attempts.

## Earlier three-task checkpoint

All three planned official model attempts finished on 2026-10-20, with one
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

The remaining task launched once with unchanged settings and clean source
`b9cc927`, in `runs/local-evaluation-Pi1SXX`, trial
`at-tenant-isolation__LOVpl49`. It is monitored by the detached
`bin/watch-local-evaluation` observer; no result is claimed yet. The observer
does not change the frozen run. Direct delivery through `codex queue` replaces
the paused event-delivery heartbeat: plain Python waits for the event and queues
one message to this existing chat. No model turns run while waiting. Do not rerun the
two completed attempts to improve the score.
The remaining task then launched once with unchanged settings. The detached
observer emitted its finished event at 18:52:39 UTC. A one-time notifier queued
a message to this existing chat through `codex queue` at 18:52:59 UTC; this chat
received it and recorded the result above. The scheduled heartbeat is paused.
The observer and notifier did not alter the frozen attempt. Delivery evidence
and acknowledgement are retained in the run's `monitor/` directory.

The declared baseline is now complete. Preserve these first-attempt results;
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
