# Fresh Qwen attempt with a 32-turn budget

## Protocol fixed before starting

Repeat the expense-claim development task from a fresh starter container and
empty agent history. Use the same unchanged Qwen3.5-4B revision, package/runtime
versions, miniswen prompts, native tool parser, explicit EOS, greedy decoding,
1,024-token output limit, 8,192-token input limit, and local hidden grader as
the first pilot. Change only the turn limit from 12 to **32**. Keep the
30-minute deadline and 60-second command timeout. Run one attempt.

Command: `COLAB_STEP_LIMIT=32 bash bin/run-colab-development`.

Record submission outcome separately from grader reward, visible-test execution,
token use, generation time, and operator-inclusive wall time. Retain raw relay
requests/responses and grading evidence locally. Do not feed the earlier patch,
trajectory, hidden-test output, or reference solution into the model. No training.

The first attempt scored 1.0 but exhausted its 12 turns before submitting. This
follow-up tests workflow completion with a larger budget; it is a development
comparison, not an independent benchmark sample or a training-benefit estimate.

## Outcome: infrastructure failure, unscored

The fresh run completed 14 model calls. On request 15, the T4 raised CUDA
`OutOfMemoryError` in eager attention's float32 softmax. The request contained
6,188 input tokens, below the helper's 8,192-token input guard. The traceback
reported a 1.14 GiB allocation with only 1.13 GiB free. The nominal context
guard therefore does not establish that this runtime can serve every allowed
request.

The operator preserved the failure and interrupted the waiting local harness.
It exited 130 and reported zero scored trials. No submission, hidden grading,
reward, completed result JSON, or harness trajectory was produced. This is
neither a zero reward nor a successful coding evaluation.

Before the failure, Qwen inspected the app, wrote a five-scenario reproduction
script, recovered from using the nonexistent `/testbed` path, reproduced two
invalid-save cases, added conditional model validations, and reran its script.
All five scenarios then printed their expected outcomes. This script uses
printed checks rather than assertions and is not a substitute for the grader.
The model had not run the existing baseline suite or submitted.

The 14 accepted responses consumed 44,795 input and 2,347 output tokens,
taking 237.99 seconds of generation with peak allocation 13.21 GiB. These
totals exclude the failed request's unreturned generation and operator latency.
No model weights, prompts, tool semantics, or grading rules were changed during
the attempt. The fresh environment's observations include new timestamps; the
trajectory diverged from the first pilot, so this is not a replay of identical
request bytes and cannot isolate the effect of a turn-budget increase.

Local evidence is in ignored `runs/qwen-development-AIGYqt/`: 15 requests,
14 responses, source/config snapshots, evaluation-file digests,
`infrastructure-failure.json`, and `colab-failure-dom.txt` plus the failure
screenshot. The empty `trials/` directory must not be treated as a saved result.

Next: make runtime failures reach the harness as explicit infrastructure errors,
then validate a memory-efficient attention configuration on long context before
starting another fresh scored attempt. Any attention change is a new runtime
configuration and must be recorded separately.
