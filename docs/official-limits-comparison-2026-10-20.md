# Qwen baseline with the official time and step allowance

The user requested a second baseline with the pinned official agent time,
step and command limits, without interference with the restricted baseline.
This is a separate first attempt per task under a new budget, not a replacement
or best-of selection for the restricted results. No training is authorized.

## Scope

Use all nineteen official atomic tasks once each, preserving the existing
development/holdout assignment. Run in this order:

| Order | Task | Group |
| --- | --- | --- |
| 1 | at-announce-once | Development |
| 2 | at-compact-positions | Development |
| 3 | at-tenant-isolation | Development |
| 4 | at-archive-book-access | Development |
| 5 | at-bulk-access-grants | Development |
| 6 | at-deep-link-return | Development |
| 7 | at-error-page-flake | Development |
| 8 | at-legacy-conversions | Development |
| 9 | at-log-to-terminal | Development |
| 10 | at-purge-embedded-images | Development |
| 11 | at-scoped-broadcast | Development |
| 12 | at-release-recap | Held out |
| 13 | at-resumable-cleanup | Held out |
| 14 | at-throttle-search | Held out |
| 15 | at-audit-sweep | Held out |
| 16 | at-enqueue-after-commit | Held out |
| 17 | at-toc-cache-per-role | Held out |
| 18 | at-variant-processed-once | Held out |
| 19 | at-erase-account | Held out |

## Budget and comparability

Set `LOCAL_EVAL_PROFILE=official-limits` when invoking the existing runner.
Read these three fields from the pinned upstream `bench.yml`: agent timeout
90 minutes, step limit 400, command timeout 300 seconds. The default profile
remains restricted: 30 minutes, 32 steps and 60 seconds respectively.

All other local choices stay fixed: lemans 1.5.2/miniswen, local MLX community
4-bit Qwen checkpoint, 16,384 input / 2,048 output tokens, greedy decoding,
thinking disabled, prefill 1,024, response deadline 600 seconds, no history
truncation or sliding cache. Benchmark revision:
`f587d5a44897f3467af2a48c0503aef4eb6acf55`; model revision:
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`.

This adopts three official limits, not the whole hosted benchmark profile.
The model, quantization, inference speed, context cap, output cap and provider
differ from that profile; local inference has no applicable dollar-cost cap.
If the unchanged input cap is exceeded, preserve the harness's classification;
do not add truncation or reclassify an infrastructure failure as a scored zero.
Changing three limits together measures their combined effect, not the causal
contribution of each limit. Deterministic decoding does not imply a variance
estimate or guarantee identical prefixes across differently timed executions.

## Isolation and launch gate

Prepare a separate checkout and keep it clean at its recorded comparison
commit. The restricted checkout, source revision, running process, relay and
configuration are not changed. Read the same pinned model files; use distinct
run directories, relay directories, worker processes and fresh Docker task
containers. Never resume another attempt's working directory or conversation.

Two inference workers on the same Mac cannot be assumed to have independent
wall-clock budgets. Queue the comparison controller now, but do not start
controls, load weights or start inference until the original sixteen-task
coordinator has emitted a finished event and exited. If it emits a failure
event, notify and leave this comparison unstarted. Require no existing MLX
worker or lemans run process, then a five-minute idle interval, before launch.
The second run is therefore queued, not simultaneous GPU inference.

Acquire a comparison lock and check for foreign evaluation processes before
each command and while running. If overlap is observed, stop further launches
and notify without killing either attempt; retain the overlap evidence and do
not claim that result is uncontaminated. Process checks reduce interference
risk; they cannot guarantee the absence of unrelated host GPU use or thermal
effects. Restrict preparation to file and configuration work while the first
batch is active. Record process snapshots and free space locally at boundaries.

## Controls, evidence and delivery

Run the existing oracle/nop controls before each task, then one fresh model
attempt. Preserve every scored/unscored outcome, original harness reward and
credit, source/model/input hashes and actual elapsed time. Existing timeouts
are checked cooperatively and may overrun; do not claim an exact wall cutoff.
No automatic reruns, hints, repairs, regrading or merging.

Stop new launches after a failed control, unscored result, source/hash drift,
less than 2 GiB free before an attempt, overlap or another monitor failure.
Detect low disk below 1 GiB and overdue commands without killing active work.
Allow up to 110 minutes for the agent plus official verifier and cleanup before
reporting overdue; leave the active attempt running for diagnosis.

Keep held-out reward, credit, patches, verifier output and trajectories sealed.
Only inspect scored status to distinguish infrastructure failures. Do not
publish combined scores while the holdout remains sealed. Report development
task pairs and budget separately from all previous attempts.

A one-off local coordinator queues one direct message to this chat at a gate
failure, actionable failure or batch completion. No scheduled model polling.
Reference solutions, hidden tests and all raw run evidence remain local and
excluded from inference/training. Candidate PR approval and explicit user
authorization remain prerequisites for any future training.

## Launch authorization (2026-10-21)

The user requested “lets give it full allowance” after the restricted batch
finished. Run the nineteen-task scope above under 90 minutes / 400 steps /
300 seconds per command. This is the Qwen baseline with those allowances,
not an experiment to compare budget settings. The local token caps and
provider/model differences above remain disclosed. The restricted results
remain separate; do not select the best attempt across budgets. All eight
held-out tasks remain sealed. The direct callback updates PR #31. No training
is authorized.

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

## Continuation authorization (2026-10-21)

The user cleared space, attributed the temporary pressure to other work, and
authorized continuation. Preflight found 8.0 GiB free and the original tenant
isolation attempt still running. A one-off detached continuation adopts that
attempt under its original deadline, waits for its harness and worker to exit,
and preserves its original result. It does not restart or rerun any task.
Only the sixteen unstarted tasks may launch afterward, under the same settings
and controls; an unscored adopted result stops continuation for diagnosis.

The original failure event, state and acknowledgment remain intact. Continuation
events use a separate local monitor directory and the existing direct callback.
The first three attempts retain source revision `e891e37`; subsequent attempts
record this documentation checkpoint's revision. Runner/provider/worker and
benchmark settings are unchanged. No held-out inspection or training is
authorized. No scheduled model polling is used.

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

## Remaining-task continuation authorization (2026-10-21)

The user authorized continuing after the Ruby launcher diagnosis. The next
one-off controller explicitly sets PATH to the existing Ruby 3.4.2/Bundler
2.6.2 and pinned Python runtime for itself and all children. Version selection
and `bundle check` passed before launch. Preflight found 15 GiB free.

Carry forward the three completed model attempts unchanged. Start with
archive-book-access controls, which previously failed to launch, then run
only the sixteen unstarted model attempts. Preserve that earlier launcher
failure evidence. All original limits, settings, isolation checks and stop
conditions remain in effect. A separate `remaining-monitor` retains new
events and delivers the existing direct chat callback. No scheduled polling,
model retries, held-out result inspection or training is authorized.

Docker was also found stopped with a hung backend during readiness checks.
Its VM and API were absent and no evaluation process was active. Graceful
termination did not close the remaining backend, so that single backend was
force-closed and the installed Docker app reopened. Docker 29.1.3 then passed
its API readiness check. No attempt or live task container was interrupted.
The pinned child PATH also includes Docker's existing `/usr/local/bin` path.
Frozen benchmark cleanliness and 90m / 400 / 300 limits passed preflight before
launch. No benchmark attempt was created by these service checks.

### Exact Ruby installation correction before inference

The first runtime correction selected rbenv Ruby 3.4.2, but the existing
native JSON gem links to mise Ruby 3.4.2. Loading lemans exposed this mismatch
before controls or any fourth model attempt ran. Version and `bundle check`
alone had not detected it. The corrected launcher pins the exact original
`/Users/mrdhat/.local/share/mise/installs/ruby/3.4.2/bin` installation; loading
lemans and the native JSON extension now succeeds. No gems were rebuilt.
The prelaunch failure event, state and native-extension error log are retained
locally and acknowledged. The earlier Ruby 2.6 control-log path was reused by
that failed correction, overwriting its raw log; its error remains documented
in the earlier checkpoint, event and validation scope. Further control/attempt
logs use a fresh isolated directory. Continuation events now use
`remaining-runtime-monitor`. The three completed attempts remain unchanged.

## Current stop: missing model weights (2026-10-21)

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

## Authorized weights restoration and continuation (2026-10-21)

The user authorized downloading the missing weights again and attributed the
missing artifact to laptop cleanup. Download only `model.safetensors` from
the same pinned community revision, using the existing local cache. Verify
all eleven model files against the recorded manifest before inference.
The download reached about 1.75 GiB before pausing; restoration is not yet
claimed complete at this checkpoint. A detached recovery gate waits up to
twenty additional minutes for that existing download, then verifies bytes
and starts only the sixteen unstarted model attempts. If unavailable or
mismatched, it delivers a failure event without launching inference.

Reuse the passed archive-book-access oracle/nop controls; subsequent tasks
still run their controls. Preserve all three completed model outcomes and
earlier failure evidence. Runtime/Docker and frozen benchmark preflight
checks passed. New logs and events use `restored-weights-logs` and
`restored-weights-monitor`; recovery status records whether verification
has actually finished. Direct callbacks replace context polling. No training
or held-out outcome inspection is authorized.

## Current stop: input budget exceeded (2026-10-22)

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
