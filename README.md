# Rails model lab

Measure a small open-weight model on the official Agents on Rails benchmark
before considering training. Use **lemans 1.5.2**, its **miniswen agent**, and the
unchanged official tasks and graders. This repository adds a local inference
adapter, a runner that freezes inputs, and an evidence report.

The earlier three-task local community 4-bit Qwen baseline finished: one solved out
of three, with zero infrastructure failures. Announcement scored reward 0.0;
compaction scored reward 1.0 (credit 0.10); tenant isolation timed out without
submission and scored reward 0.0. Mean reward is 0.3333; mean credit is 0.0333.
No training run has occurred. See [results](docs/results.md).

## Full time and step allowance: completed

All nineteen authorized tasks have been attempted once: **one pass, nine scored
failures and one unscored input-limit error** across eleven development tasks;
**eight held-out attempts completed and remain sealed**. Compaction scored
reward 1.0 / credit 0.10. The other nine scored development attempts scored
0.0 / 0.0. Bulk-access-grants has no reward or credit because its 17,377-token
input exceeded the fixed 16,384-token cap. Among ten scored development
attempts, mean reward is 0.10 and mean credit is 0.01; no aggregate includes
the sealed held-out outcomes.

The 90-minute / 400-step / 300-second-command profile retained the local
16,384 input / 2,048 output token limits. All frozen inputs, model hashes and
held-out seals verified. No task was rerun or regraded, and no training ran.
See the [complete development results](docs/results.md#completed-nineteen-task-baseline-2026-10-23)
and [protocol and retained history](docs/official-limits-comparison-2026-10-20.md).
The [failure audit](docs/qwen-baseline-failure-analysis-2026-10-24.md) found
a severe inference bottleneck alongside token limits and model repetition.

## Run the official baseline

Requirements: Ruby 3.4+, Bundler, Docker, and the existing Apple Silicon MLX
runtime. Keep the Mac lid open; the runner prevents idle sleep only while active.

```sh
bash bin/setup-benchmark
bash bin/validate-benchmark at-announce-once at-compact-positions at-tenant-isolation
bash bin/run-local-evaluation at-announce-once
python3 bin/report-local-run runs/local-evaluation-RUN_ID
```

Run the three tasks sequentially, one fresh attempt each, in the
[frozen protocol](docs/local-baseline-protocol-2026-10-20.md). The runner requires
a clean official checkout at the revision in `benchmark-revision.txt`. It
copies official application/build/task files to a fresh ignored run directory,
records file hashes and model hashes, and invokes lemans with the local provider.
Official graders and reference solutions remain outside the model workspace.
Infrastructure failures stay unscored; preserve every attempt.

Fixed settings: 32 steps, 16,384 input / 2,048 output tokens per generation,
1,024 prefill chunks, greedy decoding, thinking disabled, EOS 248046, 30-minute
agent deadline, 600-second response deadline and 60-second command timeout.
The runner changes the model/agent configuration, not the official verifier.

## Local model

The existing runtime is `runs/mlx-runtime/venv` (Python 3.14.5). Its exact package
versions are in [mlx-requirements.txt](experiments/mlx-requirements.txt).
Model: `mlx-community/Qwen3.5-4B-4bit`, revision
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`. The upstream base commit is unknown;
report this variant separately from the original Colab float16 checkpoint.
The downloaded weights occupy about 3 GB; reuse the existing snapshot.

`runs/mlx-runtime/model-path.txt` contains the absolute snapshot directory,
whose final component is the revision above. `runs/mlx-runtime/requirements.lock`
records the installed packages. To recreate the environment, use Python 3.14.5,
install the pinned requirements into that venv, download that exact model
revision, and write its snapshot path to `model-path.txt`. The runner and worker
use offline inference, local files and no remote Python code.

The Ruby file provider reuses RubyLLM's Ollama message/tool serialization.
It never makes an Ollama HTTP request. The Python worker uses the model's native
tool template and parses complete bash calls without repairing generated output.
Lemans owns command execution, submission, verification and scoring.

## Checks and repository scope

```sh
bundle exec ruby experiments/test-local-file-provider.rb
python3 experiments/test-mlx-file-worker.py
python3 experiments/test-local-report.py
```

These checks need no model or Docker. Official oracle/nop controls above use
Docker and no model. Raw run artifacts remain under ignored `runs/`.

For an already-running attempt, `python3 bin/watch-local-evaluation RUN HARNESS_PID`
observes the existing lemans process every 30 seconds. Run it in a detached
process to survive chat interruptions. It writes one atomic `monitor/event.json`
on a harness result, process exit without a result, disk below 1 GiB, 12 minutes
without transport progress, or 40 minutes without a result. Monitor errors also
produce an event. It never edits, kills, restarts or regrades an attempt.
`monitor/state.json` records its PID; a file lock prevents duplicate observers.
For direct chat delivery, run `python3 bin/notify-local-evaluation RUN THREAD_UUID`
in a detached process alongside the observer. It waits for the event using only
local Python, then invokes `codex queue --thread ... --message ...` once. No
scheduled model turns are needed. `monitor/delivery.json` records the attempt
and outcome; ambiguous deliveries never auto-retry. The receiving chat writes
`monitor/ack.json` after handling the event. The previous scheduled heartbeat
is paused. The observer exits after one event and the notifier exits after
delivery (or after 90 minutes without an event). They never rerun the benchmark.
Check with `python3 experiments/test-local-watch.py` and
`python3 experiments/test-local-notify.py`.

The obsolete Colab automation, custom development tasks and their validators
are removed from the active route. Their exact code and detailed experiment
history remain on the preserved branches referenced by [results](docs/results.md).
No further infrastructure features or custom tasks are planned unless a concrete
failure blocks the official baseline. Benchmark prompts, graders, reference
solutions, generated patches and run logs must never enter training data.

Sources: [benchmark](https://github.com/rails/ai-evals),
[harness](https://github.com/rails/lemans).
