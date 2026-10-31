# Staged baseline: CLI setup failure and continuation

The second batch started its private inference engine and verified all 12 original model-file hashes and the frozen provider/helper source hashes. Its four harness processes then rejected `--require`, which is not an option in lemans 1.5.1. They exited before constructing tasks, making inference requests or writing original result files. This is a harness invocation failure, not a Qwen coding-quality result.

| Coverage before the next continuation | Count |
| --- | ---: |
| Planned identities | 135 |
| Persisted started identities, retained as consumed | 4 |
| Original scored results | 0 |
| Consumed identities without original harness results | 4 |
| Still unstarted identities | 131 |

The consumed identities are at-announce-once attempts 1–3 and at-archive-book-access attempt 1. Their original CLI logs and ledger remain local and unchanged. No reward or credit exists; neither is zero. No complete benchmark percentage is available. These four identities will not be retried or silently replaced, so this fixed manifest cannot yield 135 scored results under the existing no-rerun policy. The earlier image-construction failure remains separately preserved with zero consumed identities.

The exact app was verified stopped with zero active tasks and Docker had no remaining containers. Original controller source matches the frozen snapshot. The pinned benchmark file hashes and current source/configuration freeze validate. The dashboard still showed zero net spend and unchanged $25 usage/$0 spend limits; estimated usage is not a reconciled per-batch invoice.

The correction invokes a small Ruby wrapper which loads the provider transport and then calls the unchanged upstream CLI. It supplies no unsupported `--require` flag and no global agent override. An execution-based smoke test runs the exact pinned CLI parser and configuration loader, intercepting immediately before harness execution: it verifies the selected adapter, original task limits, model, output cap, attempts and concurrency, with zero compute calls and zero harness runs. Four simulated controller lifecycle checks also pass after the change.

Under the user's existing explicit first-stage approval, a same-credit-cycle continuation was launched with fresh conservative billing verification, unchanged model/generation/task settings and all four consumed identities excluded. Only the 131 still-unstarted identities are eligible. Outcome remains pending; no score or additional coverage is claimed for this launch. It retains independent GPU shutdown and direct completion delivery, with no scheduled polling, training, paid spending or automatic next-cycle launch. Raw evidence and private deployment identifiers remain local and out of training.
