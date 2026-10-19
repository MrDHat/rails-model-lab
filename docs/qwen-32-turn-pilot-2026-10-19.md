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
