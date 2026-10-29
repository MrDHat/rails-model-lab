# Modal Qwen baseline progress — 2026-10-29

The full 46-task baseline is incomplete. At the first batch callback, two tasks had attempted and terminated: one scored and one unscored. The remaining 44 were unstarted. These two attempts are retained permanently and will not be rerun or regraded.

| Task | Original outcome | Scored | Reward | Credit | Duration | Steps |
| --- | --- | --- | --- | --- | --- | --- |
| at-announce-once | completed | yes | 0.0 | 0.0 | 5407.1 s | 59 |
| at-archive-book-access | agent_error | no | absent/null | absent/null | 6258.2 s | unavailable |

The first attempt reports 546,117 input tokens and 149,957 output tokens. The second result has no usage object and no verifier phase. Its reward and credit are absent in the original artifact; they must not be converted to zero. This coverage cannot establish a full-corpus model score or leaderboard position. Historical MLX outcomes remain separate.

## Interruption and continuation

Modal's system log at 2026-10-28 22:54:13 UTC states: `Stopping app - local client disconnected.` The local harness later recorded the model call failing because its Modal function was stopped. This establishes a transport interruption, not its underlying network or host cause. The Modal app was confirmed stopped with zero running tasks and zero live containers. The dashboard subsequently showed $25.98 credits remaining; this is an observed balance, not a reconciled invoice or this batch's exact cost.

The non-detached Modal app lifecycle stopped GPU work on client disconnection as intended. Continuation retains that lifecycle and the 120-second idle scale-down. The detached local launcher now also inhibits idle system and disk sleep; this does not guarantee survival of a lid closure or network outage. No inference request is retried.

A separate local continuation controller was launched for only the 44 unstarted tasks, skipping both finished attempts. It retains the original batch's start-based 16-hour wall deadline rather than resetting the budget. It reuses the passed synthetic gates, verifies remote model/source metadata on startup, preserves the frozen model, generation settings, task limits and harness, and classifies only newly occurring provider errors. Original controller, configuration, logs and state were archived locally before continuation. No task's allowance is shortened to fit the remaining credit window. Full 46-task coverage is still not guaranteed within this free-credit cycle.

## Verification and boundaries

All 723 benchmark-input hashes and five frozen source hashes matched at callback handling. The recorded remote inference source matches the frozen local source; all 12 model-file hashes match the successful preflight. The two original result objects match the state ledger exactly for outcome, reward and credit. The benchmark checkout remains pinned to `f587d5a44897f3467af2a48c0503aef4eb6acf55`.

The full protocol and original source hashes are recorded in [the launch checkpoint](modal-full-baseline-2026-10-28.md), originally PR #32. That PR was already merged when this callback was handled, so this progress record is a new checkpoint PR. No merge was performed by this continuation.

Workspace controls remain $25 usage ceiling, $0 net spending and free credits only. Harness token API fees of zero are separate from actual Modal compute consumption. No persistent volumes or public endpoints are created. No training, hints, regrading, purchases or access changes are authorized. Hidden graders, reference solutions and raw evidence remain local, and all benchmark material remains excluded from training. Completion/failure delivery remains a direct controller callback without scheduled or in-context polling.
