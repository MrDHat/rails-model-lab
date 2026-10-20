# Completed overnight attempts

Neither attempt below supplies a scored reward or an explicit submission.
No training or official model baseline was completed.

## Colab expense attempt with 16K input budget

Source `7ba39b7`; run `runs/qwen-development-XDxo2u`; trial
`expense-claim-submission__ZnGYW6R`. A separate synthetic diagnostic completed
16,384 input / 2,048 output tokens in 197.01 seconds with 11.33 GiB peak CUDA
allocation (`runs/qwen-ceiling-diagnostic`, including its exact source).

The fresh expense attempt fixed 32 steps, 16,384 input / 2,048 output tokens,
eager attention and 1,024-token prefill chunks, retaining the existing model,
agent and deadlines. Sixteen generations were delivered and consumed through
the corrected relay with zero DOM fallbacks: 50,970 input / 2,695 output tokens,
248.50 generation seconds, 9.59 GiB peak allocation. None was truncated.

Colab then showed Reconnect and stopped exposing request 17's output. Automatic
approval review rejected reconnecting because it could discard executing
notebook/model state; a specific approval request remains pending. No reload,
rerun or alternative reconnection was attempted. The provider's unchanged
600-second deadline expired. The harness recorded `agent_error`, unscored,
after 1,229.1 seconds. The expired request was never consumed or executed.
Screenshot and DOM evidence are saved in the run directory.

The model's own reproduction incorrectly treated saving an incomplete draft
as a failure, despite the task allowing that behavior. This is an observation
from the visible trajectory, not a hidden-test finding. Transport reliability
for a whole Colab task remains unresolved.

## Local quantized team-ticket attempt

Source `f63e494`; run `runs/mlx-development-esBb0Q`; trial
`team-ticket-boundary__RSJZSdW`. Model and fixed settings are in the
[local backend record](local-mlx-2026-10-20.md). Starter/task hashes match the
frozen manifest. Eleven model files have recorded hashes; the weight digest is
`5fb9acd0246866381cf8c5c354c6db1019f6498eec4ccb4f5edcc71ffeacb2db`.

All 22 generations were delivered and consumed locally: 88,156 input / 2,970
output tokens, 1,867.34 generation seconds, peak unified-memory allocation
3.636 GiB. There were no truncated, expired or quarantined responses and no
runtime errors. No browser relay or task-time inference network was involved.
The agent reached `time_limit` without submitting. Wall time was 1,890.0 seconds;
the agent checks its time limit between generations, so an in-flight request
can extend beyond the nominal 30 minutes.

The final patch introduced `TicketsController::NotFoundError`, an undefined
constant. The restored starter suite ran three tests and raised three errors,
each pointing to the model-edited controller. The existing development
verification script treats test exceptions as exit 2, writes no reward, and
therefore yielded `verifier_error`, unscored. Do not relabel this historical
attempt as zero or rerun its patch to create a replacement score.

This exposes a grader classification problem: exceptions caused by broken
agent application code must be distinguished from failures to start or execute
the verification infrastructure. Oracle/nop and earlier incomplete-fix mutants
did not cover this case. Next, add a broken-application mutation fixture and
validate an explicit grading policy before a fresh model attempt. Preserve
this original verifier result and all failed-attempt evidence.

## Remaining work

The prospective [three-task official protocol](local-baseline-protocol-2026-10-20.md)
was frozen at `5269e76`. None of those official model attempts was launched.
First repair and validate development grading, then establish a scored local
end-to-end attempt. Restore Colab only with the pending reconnect approval.
The autonomous goal reached `usageLimited` during the overnight follow-up;
no further model evaluations were launched after observing that limit.
Checkpoint PRs remain open and unmerged. Evaluation material remains excluded
from training and hidden material remains outside inference inputs.
