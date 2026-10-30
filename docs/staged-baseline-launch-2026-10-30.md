# First staged Qwen baseline launch

The user explicitly approved the first scored stage of the fixed 135-attempt baseline. The detached controller was launched after checking the clean pinned benchmark, frozen source/configuration hashes, original task allowances and empty attempt ledger. No active Modal apps or Docker containers were present before launch.

The existing free-credit-only controls remain unchanged: $25 workspace usage ceiling and $0 net-spend limit. A conservative billing estimate, a $1 overhead reserve and a $1.50/hour resource reservation give this stage at most about 12.2 hours including startup, idle time and verification. The absolute GPU deadline is independent of a future agent response. Admission requires a complete wave to fit; task budgets are never shortened to fill remaining credit. No automatic next-cycle launch is authorized.

The controller's dynamic module loader now registers the provider in Python's module registry before execution, allowing remote import/serialization. This prelaunch correction changes no model settings or benchmark limits. All ten budget/controller tests passed after the correction, and the updated source was frozen before approval was recorded locally.

A detached supervisor waits for process exit and provides a direct fallback callback if the controller fails before delivering its own completion event. There is no scheduled or in-context status polling. Original results, raw inference traces, billing evidence and deployment identifiers stay local. No outcome or scored coverage is claimed yet. No training, purchases or merges were performed.

## First setup failure and disclosed continuation

The first batch failed during image construction: an environment-setting build step followed deferred local-file mounts, which Modal rejects. The CPU packaging gate, GPU startup and remote model-hash verification were not reached. The original attempt ledger remains empty: **0/135 attempted, zero scored and zero unscored trials**. Reward and credit are absent, not zero. This setup failure is not a model-quality result.

The exact app was verified stopped with zero active tasks; Docker had no remaining containers. The original source snapshot matches its frozen hash. Original preparation, approval, error and logs remain local. Billing still showed zero paid spend and unchanged budget controls; estimated setup overhead is not a reconciled invoice.

The image now applies all environment build settings before attaching local source files. Existing model settings, original task limits and the 135 identities are unchanged. Ten controller/budget checks pass. The setup failure is retained separately. Under the existing explicit launch approval, a same-credit-cycle continuation was launched with fresh billing verification and its own callback supervision. It starts only still-unstarted work; no trial has been rerun or regraded. The continuation outcome remains pending. No scheduled polling, training, paid spending or automatic next-cycle launch was added.
