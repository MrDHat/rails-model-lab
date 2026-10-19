# Rails model lab

Learn post-training by measuring a small open-weight model on the official
Agents on Rails benchmark before and after training.

The imported chat is background, not a finalized experiment specification. The model,
GPU host, training method, and budget remain provisional.

Qwen3.5-4B now passes a short Colab T4 inference smoke test. See the
[runtime and result record](docs/qwen-colab-smoke-2026-10-19.md) and
[reusable script](experiments/qwen-colab-smoke.py).

The first unchanged-model development attempt scored **1.0**, passing all 27
hidden tests, but reached its 12-turn limit before submitting. See the
[pilot result and limits](docs/qwen-development-pilot-2026-10-19.md) and
[interactive Colab workflow](experiments/README.md). This is one development
task, not an official benchmark result.

A fresh [32-turn follow-up](docs/qwen-32-turn-pilot-2026-10-19.md) hit a Colab
GPU memory error on request 15 and is **unscored**. Longer-context runtime
validation is required before another scored attempt.
The [runtime diagnostics](docs/colab-runtime-diagnostics-2026-10-19.md) record
explicit error propagation and a successful separate chunked-prefill probe on
the previously failing request.

## Development evaluations

Our first independent task is runnable:
[expense claim submission](evals/development/tasks/expense-claim-submission/instruction.md).
Its [evaluation design](evals/development/tasks/expense-claim-submission/design.md)
defines the starting app, test cases, and scoring. Run its no-model checks:

```sh
bash bin/validate-development
python3 bin/validate-development-mutations
```

See the [validation record](docs/development-eval-validation-2026-10-19.md).
Development evaluation material stays out of training data and its scores
are reported separately from the official benchmark.

## First milestone: validate the evaluation environment

**Completed on one task:** reference solution scored 1.0; unchanged app
scored 0.0; both runs completed without model calls.
See [the validation record](docs/validation-2026-10-18.md).

Use the official tasks, graders, lemans harness, and (for model runs)
miniswen agent. Training will use separate, independently authored material;
official benchmark prompts, solutions, tests, and run logs must not enter
training datasets.

Requirements: Ruby 3.4+, Bundler, Git, and a running Docker daemon.

```sh
bash bin/setup-benchmark
bash bin/validate-benchmark
```

The setup script checks out the revision in `benchmark-revision.txt` and
installs the harness version in `Gemfile.lock`. The benchmark lives under
ignored `vendor/ai-evals`; sparse checkout excludes published run logs.

Validation runs only the official `at-announce-once` task:

- `oracle` applies the supplied solution; expect full credit.
- `nop` leaves the starting code alone; expect zero credit.

Neither agent calls a model. Docker downloads and builds the Rails runtime.
Results and verifier logs are written under ignored `runs/validation-*`.
Inspect result outcomes as well as scores: infrastructure errors are not
model failures, and a successful command alone does not establish validity.

This milestone is an infrastructure check, not a model baseline or a
leaderboard result. Later comparisons must record task scope, repetitions,
model and adapter revisions, agent version, inference settings, resource
limits, and runtime differences from the published runs. Hosting the model
on Colab or another GPU service remains to be evaluated.

Sources: [benchmark](https://github.com/rails/ai-evals),
[methodology](https://github.com/rails/ai-evals/blob/main/methodology.md),
[harness](https://github.com/rails/lemans).
