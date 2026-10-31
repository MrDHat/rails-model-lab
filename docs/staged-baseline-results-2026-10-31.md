# First staged Qwen baseline: incomplete outcomes

The authorized stage ended at its disk-admission boundary. It does not establish a full Rails benchmark score or leaderboard position. The original 135-attempt manifest, historical experiments and failed setup attempts remain separate and unchanged.

| Coverage | Count |
| --- | ---: |
| Planned identities | 135 |
| Consumed ledger identities | 112 |
| Original harness result files | 108 |
| Scored results | 2 |
| Unscored original results | 106 |
| Earlier consumed identities without original results | 4 |
| Still unstarted | 23 |

## Exact scored outcomes

| Task | Manifest attempt | Original outcome | Reward | Credit | Duration (s) |
| --- | ---: | --- | ---: | ---: | ---: |
| at-archive-book-access | 2 | agent_timeout | 0.0 | 0.0 | 5466.2 |
| at-archive-book-access | 3 | agent_timeout | 0.0 | 0.0 | 5529.7 |

All 106 unscored results retain their original absent/null reward and credit; none is converted to zero. The four earlier CLI failures have no original result object. The original-results report preserves every available reward, credit, outcome, duration and usage object. The complete equal-task headline is suppressed. Two zero-credit timeouts on one task are not a benchmark-wide 0% estimate.

## Infrastructure failures

| Classified original outcome/detail | Count |
| --- | ---: |
| agent timeout | 2 |
| remote inference read timeout | 2 |
| remote call cancelled | 1 |
| remote auth expired | 13 |
| remote function stopped | 39 |
| environment command timeout | 34 |
| environment error | 14 |
| sandbox jail pidfd unavailable | 3 |

These are diagnostic groupings of retained outcomes, not regrading. Model-call errors include read timeouts, expired remote authentication and stopped remote functions. Environment failures include installation/build timeouts and other setup errors; three jailed agents reported unavailable pidfd support. All 108 original records identify lemans 1.5.1.

The direct app lifecycle is stopped. Its original local log records a client disconnect; the service stopped before the controller finished admitting later waves. The exact reason for that disconnect is not established. The controller checked for missing result files but treated unscored result files as sufficient to continue, so shared infrastructure failures consumed later identities. This was a control failure, not evidence that Qwen attempted and failed every coding task.

A prospective guard now stops later admission when retained bridge errors show a shared provider fault or an original result reports an environment error. The current wave is allowed to settle; already-started identities are preserved. Six simulated lifecycle tests pass, including both new stop conditions; independent unscored agent outcomes still do not alone trigger a global stop. Tests now provide their own free-disk fixture. These changes have not launched compute or changed any original result.

## Shutdown, provenance and budget

The exact app was verified stopped through its direct lifecycle API, after it had aged out of the recent-app list. Docker had no remaining containers. All 12 original model-file hashes, remote provider/helper source hashes, frozen launch authorization/configuration, pinned clean benchmark and input-file hashes verified. All 108 original result files were hashed locally. The consumed ledger is unchanged, and original executed controller sources were copied locally before the prospective guard change.

At verification, free disk was about 10.8 GiB, below the existing 12 GiB admission threshold. No evidence was deleted. The dashboard showed $8.25 total cycle usage, $21.75 remaining credit, zero net spend, the unchanged $25 usage ceiling and $0 spend limit. The separate ephemeral estimate was $8.27. These are workspace estimates, not an attributable per-batch invoice or a promise of remaining compute time.

No rerun, regrading, next-cycle launch, paid spending or training occurred. The 23 unstarted identities remain paused. Continuing requires adequate disk, repair/validation of connection and sandbox reliability, and a freshly checked same-cycle allowance or separately authorized later stage. Under the current no-rerun policy, the consumed unscored/missing outcomes prevent 135-scored-run completion of this fixed experiment. A different prospective invalid-run policy would require an explicit user decision and must not silently replace this evidence.

Raw traces, private deployment identifiers, operational logs, detailed manifests and hidden evidence stay local and out of training. Public reporting contains only aggregate counts, the two scored outcomes and configuration/limitations.
