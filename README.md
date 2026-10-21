# Rails model lab

Measure a small open-weight model on the official Agents on Rails benchmark
before considering training. Use **lemans 1.5.2**, its **miniswen agent**, and the
unchanged official tasks and graders. This repository adds a local inference
adapter, a runner that freezes inputs, and an evidence report.

Restricted-budget exploratory runs now cover all nineteen official atomic tasks:
three initial attempts plus sixteen in the expansion. The eight additional
development tasks scored 0/8; across the eleven inspected development tasks,
one solved task received credit 0.10. Eight held-out results remain sealed.
The coordinator recorded no infrastructure failures in the expansion. No
training has run. See [results](docs/results.md).

**This is not the baseline under the official evaluation limits.** These runs
used 30 minutes / 32 steps / 60 seconds per command; the pinned official profile
uses 90 minutes / 400 steps / 300 seconds per command. The official-limit run
has not started. Local context/output caps and provider choices also require
explicit disclosure before claiming an official-profile baseline.

## Reproduce the restricted-budget exploratory profile

Requirements: Ruby 3.4+, Bundler, Docker, and the existing Apple Silicon MLX
runtime. Keep the Mac lid open; the runner prevents idle sleep only while active.

```sh
bash bin/setup-benchmark
bash bin/validate-benchmark at-announce-once at-compact-positions at-tenant-isolation
bash bin/run-local-evaluation at-announce-once
python3 bin/report-local-run runs/local-evaluation-RUN_ID
```

The initial three-task [protocol](docs/local-baseline-protocol-2026-10-20.md)
and sixteen-task [expansion](docs/atomic-baseline-expansion-2026-10-20.md) are
complete; preserve those attempts without rerunning them to select a better
score. The command above documents the restricted profile. The runner requires
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
