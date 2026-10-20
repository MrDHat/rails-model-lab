# Official-limit comparison: declared scope

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
