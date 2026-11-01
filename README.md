# Rails model lab

Measure an open-weight model on the official
[Agents on Rails](https://github.com/rails/ai-evals) benchmark, then
post-train it and measure again. Everything uses the unchanged official tasks,
graders and limits through [lemans](https://github.com/rails/lemans) 1.5.2 and
its miniswen agent.

Current status and numbers: [docs/results.md](docs/results.md).

## Layout

- `bin/setup-benchmark` clones the benchmark at the revision in
  `benchmark-revision.txt` into `vendor/ai-evals` and installs the harness.
- `baseline/` runs a baseline on a GCP CPU VM with inference on a Modal GPU.
  See [baseline/README.md](baseline/README.md).
- `runs/` (ignored) holds run output.

## Rules

- Benchmark prompts, graders, reference solutions, generated patches and run
  logs never enter training data.
- Infrastructure failures are rerun; scored model failures are not.
- Training waits for explicit approval.

Earlier routes (MLX on the laptop, Colab, staged Modal) are in git history
before the cleanup commit.
