# Rails model lab

Learn post-training by measuring a small open-weight model on the official
Agents on Rails benchmark before and after training.

The imported chat is background, not a finalized experiment specification. The model,
GPU host, training method, and budget remain provisional.

Qwen3.5-4B runs on the existing Colab T4, but an explicit end-to-end coding
submission is still unresolved. No official model baseline or training run has
been completed. Current inference settings are pinned in the
[workflow](experiments/README.md).

| Development attempt | Preserved outcome |
| --- | --- |
| [First 12-step pilot](docs/qwen-development-pilot-2026-10-19.md) | Reward 1.0 / all 27 hidden tests passed, but step limit and no submission |
| [32-step eager pilot](docs/qwen-32-turn-pilot-2026-10-19.md) | GPU memory error; unscored |
| [Chunked-prefill pilot](docs/qwen-chunked-pilot-2026-10-19.md) | Two truncated responses then input guard; unscored |
| [Larger-budget pilot](docs/qwen-budget-pilot-2026-10-19.md) | No truncation, but relay deadline missed; unscored |
| [Recovered-relay pilot](docs/qwen-relay-attempt-2026-10-20.md) | 30 consumed generations; repeated faulty edits then input guard; unscored, no submission |
| [16K-context Colab attempt](docs/qwen-local-results-2026-10-20.md) | 16 consumed generations without fallback, then disconnection and timeout; unscored |
| [Local quantized team-ticket attempt](docs/qwen-local-results-2026-10-20.md) | 22 consumed generations, time limit, then verifier error on broken model code; unscored |

The recovered attempt needed 12 recorded DOM delivery fallbacks. The subsequent
output-text relay correction passed a fresh short live probe and local
regression checks; a full task completion with that correction remains to be
validated. Short probes and synthetic allocation checks are not task scores.
See the [overnight progress record](docs/overnight-progress-2026-10-20.md).

Next: validate grading for broken application code before a fresh team-ticket
attempt. Sending its visible prompt, starter, and command output to Colab is
awaiting explicit approval; its grader and reference stay outside inference requests.

A separate [local MLX variant](docs/local-mlx-2026-10-20.md) passed non-task
generation, tool-parser and provider-consumption checks on the Mac. Its pinned
community 4-bit weights have an unknown upstream base commit, so its future
results are reported separately from Colab float16. Its team-ticket attempt
kept all task data on the Mac and required no Colab transfer.

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

A second independent task covers [team ticket data boundaries](evals/development-team-tickets/tasks/team-ticket-boundary/instruction.md),
using a separate starter app. Its [validation](docs/team-ticket-validation-2026-10-20.md)
passed oracle/nop and six incomplete-fix checks. It tests scoped lists,
cross-team reads/edits, and immutable ownership through the existing API.
The first local quantized model attempt ended unscored: the patch introduced an
undefined exception class and exposed the grader's test-error classification.
See the [attempt record](docs/qwen-local-results-2026-10-20.md).
The grader and reference fixtures are included for repository review. They
remain outside the model's starter workspace and inference requests.

```sh
bash bin/validate-development evals/development-team-tickets team-ticket-boundary
python3 bin/validate-team-ticket-mutations
```

## First milestone: validate the evaluation environment

**Completed on three official tasks:** reference solutions scored 1.0 and
unchanged apps scored 0.0, with completed outcomes and zero model tokens.
See the [original validation](docs/validation-2026-10-18.md) and
[broader validation](docs/benchmark-validation-2026-10-20.md).

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

Validation defaults to the official `at-announce-once` task. Pass task names to
validate a different explicit scope: `bash bin/validate-benchmark at-compact-positions at-tenant-isolation`.
Each invocation gets a fresh evidence directory with a recorded scope and checks
completed outcomes and zero model usage:

- `oracle` applies the supplied solution; expect full credit.
- `nop` leaves the starting code alone; expect zero credit.

Neither agent calls a model. Docker downloads and builds the Rails runtime.
Results and verifier logs are written under ignored `runs/benchmark-validation-*`.
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
