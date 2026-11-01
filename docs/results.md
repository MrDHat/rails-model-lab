# Results

Benchmark: [rails/ai-evals](https://github.com/rails/ai-evals) at
`f587d5a4`, harness lemans 1.5.2, agent miniswen-installed, official limits
(90 minutes, 400 steps, 300 s per command). Headline metric is the
leaderboard's: mean over tasks of mean credit per task.

## Qwen3.5-4B, atomic tasks (in progress)

BF16, revision `851bf6e8`, vLLM 0.32.0, thinking on, temperature 0.6,
top-p 0.95, top-k 20, seed 42, 32,768 output tokens per call. One attempt per
task. Run started 2026-11-01 on a GCP CPU VM with a Modal A10.

As of 21:28 UTC: 1 of 9 scored tasks passed (`at-compact-positions`, credit
0.1). Two failed on the 90-minute limit, one on the 400-step limit, and the
rest outright. Four trials were invalid (a Docker build race and Modal GPU
preemptions) and are being rerun. The final number replaces this paragraph.

Main failure mode: thinking loops. The model repeats one sentence until it hits
the 32,768-token cap, and each such call takes about 16 minutes of the task's
budget.

## Published atomic scores for comparison

From the benchmark's own `runs/2026-10-06-atomic-tasks-revamped/`:

| Model | Credit | Passed |
|---|---|---|
| grok-4.7-high | 77.1 | 100% |
| deepseek-v4.1-flash-max | 73.2 | 93% |
| gpt-6.1-sol-xhigh | 72.4 | 100% |
| kimi-k3-max | 71.8 | 95% |
| gpt-6-astra-xhigh | 70.8 | 100% |
| gpt-6-luna-max | 70.6 | 98% |
| claude-opus-5.5-xhigh | 69.2 | 100% |
| glm-5.3-flash-max | 68.3 | 91% |
| gpt-6-astra-medium | 66.1 | 100% |
| muse-spark-1.3-max | 65.5 | 95% |
| claude-opus-5.5-medium | 62.7 | 98% |

## Earlier attempts (not comparable)

- **October 20–24, MLX on the laptop.** 4-bit weights, greedy decoding,
  thinking off, and restricted limits (30 minutes, 32 steps, 60 s per command).
  1 of 11 development tasks solved (credit 0.1).
- **October 26–31, staged Modal routes.** Several attempts to run official
  limits with the harness on the laptop and inference on Modal. All stopped on
  infrastructure problems before producing a scored batch: x86 task images
  failing under ARM emulation, the laptop sleeping mid-run, low disk, and
  CUDA toolchain and Modal packaging errors.

The code and write-ups for both are in git history before the cleanup commit.

Benchmark prompts, graders, reference solutions, generated patches and run
logs must never enter training data.
