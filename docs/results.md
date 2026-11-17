# Results

Benchmark: [rails/ai-evals](https://github.com/rails/ai-evals) at
`f587d5a4`, harness lemans 1.5.2, agent miniswen-installed, official limits
(90 minutes, 400 steps, 300 s per command). Headline metric is the
leaderboard's: mean over tasks of mean credit per task.

## Qwen atomic baselines

Both runs: BF16, vLLM 0.32.0, thinking on, temperature 0.6, top-p 0.95,
top-k 20, seed 42, 32,768 output tokens per call, 262,144-token context. One
attempt per task. Harness on a GCP CPU VM; inference on Modal.

| Model | GPU | Scored | Passed | Credit | Mean time |
|---|---|---|---|---|---|
| Qwen3.5-27B (`fc05daec`) | H200 | 19 / 19 | 5 (26%) | **7.4** | 9m 25s |
| Qwen3.5-4B (`851bf6e8`), stopped early | A10 | 13 / 19 | 2 (15%) | 1.5 | 14m 14s |

The 4B run was stopped after 13 scored tasks once it was clear it would stay
near zero. Its six unrun tasks have no result.

**27B, 2026-11-01.** Solved `at-archive-book-access` for full credit, and
passed the tests on `at-log-to-terminal`, `at-release-recap`,
`at-throttle-search` and `at-error-page-flake` for 0.1 credit each. Each
atomic task targets a specific Rails API; a fix that passes the tests without
using it earns 0.1, the rest goes to fixes that do. One trial ran past the
262,144-token context, was marked invalid, and scored 0 on its rerun. About
$9 of Modal credit.

**4B, 2026-11-01.** Passed the tests on `at-compact-positions` and
`at-log-to-terminal` (0.1 each). Main failure mode: thinking loops, where the
model repeats one sentence until the 32,768-token cap, about 16 minutes per
call. Two tasks hit the 90-minute limit and one the 400-step limit.

Infrastructure failures during these runs, all rerun as invalid: a Docker
build race on the first launch (fixed with BuildKit), and three Modal GPU
preemptions in four minutes.

## Post-trained model against the untrained one, 3 attempts

Both on one spot A100 80GB on GCP, vLLM, the settings above, 3 attempts per
task (`MODE=benchmark V=rl3|base bash training/drive-spot.sh`), 15–17 Nov.

| Model | Scored | Credit | Credit on the 17 tasks both have | Tasks with a full-credit fix |
|---|---|---|---|---|
| Qwen3.5-27B + RL round 3 | 42 / 57 | **12.5** | 13.9 | 3 |
| Qwen3.5-27B, untrained | 53 / 57 | **12.0** | 13.4 | 2 |

Post-training does not move the benchmark. It took validation on our own
tasks from 23 to 40 of 51 attempts fully solved (see
[training/README.md](../training/README.md)), but on these 19 tasks the two
models are within noise: the untrained model alone scored 7.4 in the earlier
1-attempt run and 12.0 here. RL3 trades tasks rather than adding them. It
gains full credit on `at-legacy-conversions` (2/3) and
`at-enqueue-after-commit` (1/3), and loses it on `at-tenant-isolation` (2/3
to 0/3). Its tests pass on 7 tasks against 11 for the untrained model.

RL3's failed attempts also run much longer: 278 to 400 steps on three tasks,
against 39 to 125 for the untrained model. The unscored trials are the
longest ones. A single model reply took longer than the transport's
26-minute limit, so the trial was marked invalid and retried, and the last
retries were stopped. RL3 has no scored trial on `at-scoped-broadcast` or
`at-variant-processed-once`, which count as 0 in the 12.5.

Spot preemptions, often every 40 to 60 minutes, stretched about 6 GPU hours
of work over 34 hours. Three fixes keep a run going across them:
- containers and networks left by killed trials are pruned before each
  pass;
- SSH calls have a keepalive;
- a trained model's merged weights are downloaded on restart instead of
  rebuilt.

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
