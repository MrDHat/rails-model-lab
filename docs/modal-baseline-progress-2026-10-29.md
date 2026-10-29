# Modal Qwen baseline progress — 2026-10-29

The preliminary single-attempt experiment is **stopped by the user's request**. It does not establish a full baseline score or leaderboard position. The continuation attempted one additional task before the stop: final coverage is one scored result, one unscored provider error, one user-interrupted attempt and 43 unstarted tasks. Historical MLX outcomes remain separate.

| Task | Original outcome | Scored | Reward | Credit | Duration | Steps |
| --- | --- | --- | --- | --- | --- | --- |
| at-announce-once | completed | yes | 0.0 | 0.0 | 5407.1 s | 59 |
| at-archive-book-access | agent_error | no | absent/null | absent/null | 6258.2 s | unavailable |
| at-audit-sweep | interrupted_by_user | no completed result | absent | absent | partial evidence retained | not reported |

The first attempt reports 546,117 input tokens and 149,957 output tokens. The second result has no usage object or verifier phase. Its absent reward and credit must not be converted to zero. No result was fabricated for the interrupted attempt. Original results, partial traces, patches and RPC evidence remain local and unchanged. No attempted task was rerun or regraded.

## Interruption and user stop

Modal's system log at 2026-10-28 22:54:13 UTC states: `Stopping app - local client disconnected.` The harness later recorded the model call failing because its Modal function was stopped. This establishes a transport interruption, not its underlying network or host cause. A separate continuation skipped both finished attempts and retained the original settings/deadline. The user subsequently stopped it after asking for the published benchmark protocol instead.

The continuation process group and its exact Modal app were stopped. Final verification found app `ap-UxejDTGf5GeaR8I7UqnBjz` stopped with zero tasks, and no running Docker containers. Automatic continuation is disabled. The earlier dashboard balance of $25.98 is stale, not a current balance or a reconciled invoice.

## Next comparison preparation

The [protocol audit](leaderboard-protocol-parity-2026-10-29.md) establishes 135 attempts across 46 tasks, preserving task-selected agent placement and original limits. The headline is equal task weighting of fractional credit. Historical versions/profiles vary, so exact historical environment identity is not established. The separate [preparation files](../experiments/leaderboard-preparation.md) pin lemans 1.5.1 and pass a real installed-agent/jail integration with a fake provider, two tool calls, zero published ports and zero GPU calls. Six synthetic reporter tests pass. No new scored attempt or GPU preflight was launched.

The one scored attempt's pace extrapolated over 135 runs gives a scenario of 202.77 GPU-hours, about $268.42 at the configured resource-rate ceiling. This is not a forecast or minimum; it does not support promising completion on remaining free credit. The run remains stopped pending sufficient free compute, real-provider synthetic validation and final frozen provenance.

## Verification and boundaries

At callback handling, all 723 benchmark-input hashes and five original source hashes matched; remote metadata matched the source and all 12 model-file hashes from preflight. Original outcomes matched the ledger. The original benchmark checkout remains pinned to `f587d5a44897f3467af2a48c0503aef4eb6acf55`. Launch provenance remains in [the original checkpoint](modal-full-baseline-2026-10-28.md). New preparation files do not alter the frozen original controller or evidence.

Workspace controls remain a $25 usage ceiling, $0 net spending and free credits only. Zero harness token API fees do not mean free GPU compute. No training, hints, purchases, merging, access changes, persistent volumes or public endpoints. Raw/hidden evidence remains local and all benchmark material stays out of training. No scheduled polling or automatic restart is installed by this checkpoint.
