# Why the local Qwen baseline failed

The development evidence confirms a severe inference bottleneck in this local
setup, alongside output/context limits and model repetition. It does not
establish that hardware alone caused the low score or that a faster machine
would solve the tasks. Preserve the original results and treat them as a
baseline for this specific model/runtime configuration.

This audit covers only the eleven development attempts in the completed
nineteen-task atomic scope. The eight held-out outcomes remain sealed. No
inference, benchmark rerun, grading, training or configuration change was
performed for this investigation.

## Time went into inference

Across the eleven development attempts, the original harness recorded
47,401.3 seconds of wall time; the worker recorded 45,975.44 seconds inside
`stream_generate`: **96.99% of total wall time**. That worker timer includes
prompt processing and decoding; it is not a measurement of output-token decode
speed. Generation accounted for 96.72% of wall time across the seven timeouts.

| Development timeout | Harness steps | Generation seconds | Generation / agent phase | Tracked patch bytes |
| --- | --- | --- | --- | --- |
| at-tenant-isolation | 52 | 5400.32 | 99.4% | 3856 |
| at-archive-book-access | 35 | 5620.00 | 99.6% | 0 |
| at-error-page-flake | 35 | 4629.47 | 84.3% | 0 |
| at-legacy-conversions | 43 | 5563.46 | 99.5% | 0 |
| at-log-to-terminal | 35 | 5476.83 | 99.4% | 0 |
| at-purge-embedded-images | 41 | 5555.10 | 99.5% | 0 |
| at-scoped-broadcast | 47 | 5471.69 | 99.4% | 0 |

The 400-step setting was a ceiling. The slow runtime allowed only 35–52 model
turns before the cooperative 90-minute deadline. The last generation can
finish after that deadline; miniswen then checks the deadline before executing
a tool call. None of these attempts exhausted the step allowance.

Six timeouts left no tracked repository patch; tenant-isolation left a partial
patch. Empty tracked patches do not imply that no temporary files were written.

The error-page-flake exception has two approximately 300-second gaps between
a consumed response and the next request, associated with model-issued test
commands. Its non-generation time therefore matters too. For the other six
timeouts, model calls consumed over 99% of the agent phase.

## The adapter reprocesses the entire conversation

In the frozen `experiments/mlx-file-worker.py`, `prepare` renders the full
conversation on every request. Every call to `stream_generate` receives those
full tokens, with no reused `prompt_cache`. The installed MLX-LM implementation
creates a fresh prompt cache when none is supplied. This provides attention
caching within a generation, but does not reuse an earlier turn's prefix.
The model weights stay loaded; weights are not reloaded every turn.

The eleven runs processed **2,696,504 input tokens** across successful
generations, including repeated history, versus **52,569 generated tokens**.
This is not 2.7 million unique task tokens.

Observed latency for successful generations with at most 200 output tokens:

| Input-token band | Responses | Median generation seconds | Median output tokens |
| --- | --- | --- | --- |
| Under 4,000 | 101 | 48.915 | 49 |
| 4,000–7,999 | 118 | 93.273 | 51.5 |
| 8,000–11,999 | 96 | 169.473 | 57 |
| 12,000–16,384 | 24 | 231.452 | 68.5 |

These are descriptive bins across tasks, not controlled speed experiments.
They show that even short replies became expensive with growing context.
Within tenant-isolation, the first quartile of short-output calls had median
5,317 input tokens and 31.4 seconds; the last quartile had 13,448 input tokens
and 240.2 seconds. Other tasks show the same direction of change.

Request/consumption receipts place round-trip times close to worker generation
times. For example, scoped-broadcast's median generation was 122.367 seconds
versus 122.689 seconds to the consumed receipt. The 0.25-second relay polling
interval cannot explain multi-minute calls. Development reports contain no
pending, expired or quarantined late responses. The single runtime error was
the preserved input-budget rejection.

## Hardware evidence and its limits

A metadata-only check on 24 October identifies **Apple M1, 16 GiB unified
memory**, with Metal available and the pinned runtime's current default device
`Device(gpu, 0)`. The frozen worker does not select a CPU device. This is
consistent with GPU inference, rather than an adapter explicitly forcing CPU;
per-attempt GPU utilization was not recorded, so the current check is not a
historical utilization measurement.

Recorded peak MLX allocation ranges from 3.689 to 4.191 GiB across these eleven
runs. This is allocator usage, not total host memory or a complete working-set
measurement. The host currently has about 6.77 GiB of swap in use. Earlier
baseline interruption notes also record substantial swap usage. Neither
snapshot proves active paging during a particular generation. No continuous
swap-in/out, GPU utilization, clocks or thermal telemetry was captured.

The existing worker discards MLX-LM's available `prompt_tps` and
`generation_tps` fields and stores only combined generation seconds. The
historical artifacts therefore cannot cleanly divide latency into prefill,
decode, paging, thermal throttling or competing host load. A hardware-only
causal claim would exceed the available evidence.

## Other confirmed failure causes

**Output truncation caused the two format stops.** Each ended after three
consecutive responses with zero parsed bash calls; all six responses hit the
2,048-token output limit. For announcement, the responses were repetitive
prose without tool-call tags, and the final two raw replies were byte-identical.
For deep-link-return, each began a native XML bash call but ended before its
closing tag, so there was no complete call to execute. This is not evidence
that the adapter rejected a complete valid call. Faster inference by itself
would not remove the same output-token ceiling.

**The input cap caused the unscored attempt.** Bulk-access-grants requested
17,377 input tokens against the fixed 16,384 cap. The worker rejected it before
generation. Its missing reward, credit and harness usage stay missing. This
was a configured software limit; there was no recorded out-of-memory exception.
A larger machine alone would not change that configured value.

**Model loops consumed substantial time.** Scoped-broadcast generated the same
raw reply 36 times, accounting for 4,886.993 seconds (81.45 minutes) of model
generation. Its trajectory contains 37 identical bash call commands. Archive
contains eight byte-identical raw replies taking 2,240.08 seconds (37.33
minutes), with nine identical command strings in the trajectory. These counts
refer to recorded generations/tool-call requests, not a claim that every final
call executed before timeout. More throughput could simply produce more of
the same loop; success is not established by removing the time bottleneck.

## What follows from the evidence

The baseline is strongly runtime-constrained and also exposes output/context
and model-behavior limitations. It should not be presented as an isolated
measurement of Qwen's Rails knowledge. It also does not justify claiming that
Qwen would score well on different hardware.

Before authorizing another quality evaluation, a small synthetic performance
probe should measure prompt and decode throughput separately at representative
context lengths, while recording host paging and GPU activity. It should use
non-benchmark prompts, one inference worker, and no grader/reference material.
This would distinguish slow prefill from decode and host pressure without
rerunning or contaminating the frozen benchmark attempts. Any caching, token
budget, decoding or hardware changes would need their own declared protocol;
validate exact token/history handling before reusing a prompt cache.

No new probe or evaluation was launched by this investigation. No existing
attempt or score was modified.

## Evidence and checks

The audit reads only original development `result.json`, `agent.result.json`,
`trajectory.json`, `agent.patch`, relay request/response/consumption records and
previously generated summaries. It does not read held-out results, patches,
trajectories or verifier logs, or use hidden graders/reference solutions.
Raw text and local machine snapshots remain outside tracked report content;
only aggregate timing, structural failure findings and non-sensitive hardware
configuration are reported here.

The ignored local audit script and its derived JSON are retained under
`runs/official-limits-batch/` in the official-limits source checkout. Original
run inputs, results and summaries were not edited. Generation totals match
all eleven summaries; timing fractions use the original harness durations and
agent phase timestamps. Raw reply equality uses SHA-256 of recorded generation
text. All original scored/unscored outcomes remain as published in
[results](results.md#completed-nineteen-task-baseline-2026-10-23).
