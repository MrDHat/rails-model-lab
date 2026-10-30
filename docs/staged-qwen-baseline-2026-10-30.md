# Free-credit staged Qwen baseline

The user selected staging the full benchmark across free-credit cycles while preserving task limits. This approves preparation, not scored execution. No launch authorization file exists and no prospective scored attempt has started.

## Scope and serving configuration

Retain the immutable 135-attempt manifest over 46 tasks: three attempts on 43 tasks and two on the three specified multistep tasks. Preserve task-selected adapters (42 installed, four host), all sessions, original time/step/command limits and original verifiers. Keep all historical experiments separate. Retain every persisted started identity regardless of score, interruption or infrastructure failure; never retry or regrade it automatically. A missing/unscored attempt prevents a complete scored headline.

Use Qwen3.5-4B at the previously verified model revision, BF16, the repaired immutable inference image, vLLM 0.32.0 compiled mode, native 262,144-token context, thinking enabled, temperature .6, top-p .95, top-k 20, seed 42, presence penalty zero, repetition penalty one and 32,768 output cap. These are declared Qwen settings, not a claim that every historical leaderboard provider used them. The full generation configuration and original model-file hashes are frozen locally.

## Batch execution

`experiments/run-staged-baseline.py` requires explicit scored-launch approval tied to the exact prepared manifest hash. It also requires a fresh, manually verified billing snapshot for each batch: free credit, current usage, the unchanged $25 workspace usage ceiling and $0 spend limit, zero net spend and the credit-cycle end. A snapshot older than five minutes is rejected. Approval must not be inferred from the staging choice.

One private A10 serves up to four independent upstream harness processes per wave. Waves do not overlap. There is no global agent override. Each attempt has its own original harness logs/results and trial directory. All wave identities are persisted before process creation. Earlier attempted identities cannot be admitted again, including ambiguous crashes before generation. The controller lock prevents overlapping instances for that staged experiment.

Admission reserves the entire maximum wave duration: the longest whole attempt, including its build, every session's agent/command/verifier allowances, per-session overhead and shutdown margin. Multistep attempts never split across credit cycles. Resource-time allowance uses $1.50/hour, above the configured A10/two-core/16-GiB resource rate, plus a $1 overhead reserve. The controller's stopwatch includes startup, idle time, builds and verification. It reclaims unused time only after a wave finishes. Actual bill reconciliation remains separate.

The GPU provider has an independent absolute batch deadline including idle time. A remote restart cannot reset that deadline. The client stops admitting work when a full wave no longer fits, and app-context exit stops the app after the active wave completes. The budget deadline is conservatively placed before the current credit-cycle end; a new cycle never automatically increases an active batch's allowance. The six-hundred-second synthetic watchdog is not used for scored attempts. No public endpoint or persistent volume is created.

An unscored result is preserved and does not alone stop independent tasks. A harness process with no result stops later admission as a possible environment failure. A direct completion callback requests inspection of shutdown, original outcomes, hashes, remaining allowance and coverage. There is no scheduled polling, automatic next-cycle launch or training.

## Planning results and limits

At the observed $19.31 ceiling headroom, the conservative dry run reserves 16 attempts in four waves. This is neither a guaranteed score count nor a forecast: faster completions can admit more; environment failures and billing lag can admit fewer. Future free credits are not assumed available until verified in that cycle. Monthly spacing and the original allowances may make completion slow; no completion date is promised.

All 46 effective task limits and the unchanged 135 identities were rechecked locally. The pinned clean benchmark and its original file-hash manifest validate. Model hashes and the host/installed routes have passed earlier real-Qwen synthetic checks. The new controller itself has only simulated compute/harness validation: six budget tests and four lifecycle tests passed, plus Python/Ruby syntax checks. The lifecycle checks cover refused unauthorized/stale/paid-control launches, unscored completion, no duplicate attempts and stopping later work after missing harness results.

Long-context four-agent performance and full cost are not established by the short synthetic checks. Local task builds are prospective environments, not reconstructed historical image digests. Each trial must retain its original environment provenance; later batches must verify frozen inputs/dependencies and disclose any environment drift. Budget controls cannot guarantee that unrelated workspace activity will not consume credits; that can interrupt an attempt and must remain an unscored infrastructure outcome rather than trigger a retry.

Raw evidence, private image/app identifiers, local billing snapshots, authorization records and detailed manifests remain local. Public reports contain configuration, aggregate outcomes and honest coverage. No benchmark material enters training.
