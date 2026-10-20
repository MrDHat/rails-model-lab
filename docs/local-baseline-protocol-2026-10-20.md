# Local quantized baseline protocol

This prospective scope is recorded before any official task model attempt.
It measures the separate community MLX variant documented in
[the backend record](local-mlx-2026-10-20.md), not the Colab float16 checkpoint.

## Fixed scope and settings

Run one fresh attempt per official task, in this order:

1. `at-announce-once`
2. `at-compact-positions`
3. `at-tenant-isolation`

The official checkout must be clean at
`f587d5a44897f3467af2a48c0503aef4eb6acf55`. Oracle/nop validation has already
completed at 1.0/0.0 with zero model tokens for each task. The three tasks are a
small explicit subset; do not present them as the whole official benchmark or
extrapolate a leaderboard score.

Use `bash bin/run-mlx-development vendor/ai-evals TASK`, sequentially, with the
unchanged miniswen agent from lemans 1.5.2. The pinned model is
`mlx-community/Qwen3.5-4B-4bit` at
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`, with downloaded file hashes and the
exact local dependency lock recorded per run. Its upstream base revision is
unknown. There are no adapters or training updates.

Each attempt uses 32 steps, 16,384 input / 2,048 output tokens per generation,
greedy decoding, thinking disabled, EOS 248046, prefill steps of 1,024, no
history truncation or sliding cache, a 30-minute agent deadline, 600-second
response deadline, and 60-second command timeout. Freeze starter/task inputs
before execution. Do not change model answers, repair tool calls, give hints,
or relay hidden feedback during the attempt. All inference stays on the Mac.

## Reporting and failure handling

Preserve every planned attempt, including failures. Report harness outcome,
reward only when scored, agent status, explicit submission, input/output
tokens, generation time, total elapsed time, and peak unified-memory allocation.
Step-limit grading and explicit submission are different observations.
Infrastructure failures remain unscored and must not become zeros, passes,
or silently removed rows. Report the scored denominator and infrastructure
failure count alongside any average. A single attempt is not a variance estimate.

An infrastructure rerun, if necessary, must start from a fresh starter and be
labelled as a new attempt with its reason and any changed configuration. Never
resume, rescore, or replace an ended attempt, or select the best observed score.
Stop further model launches if local resources cannot sustain bounded runs;
retain the declared scope and mark remaining tasks as not run.

The independent team-ticket attempt is a separate development result and is
not included in the official subset average. Evaluation prompts, reference
solutions, graders, generated patches and run logs stay out of training data.
No training experiment is part of this protocol.
