# Qwen compiled/graph inference results

The separately disclosed library-path repair probe completed all 12 planned synthetic cases and 40 requests with no case errors. Both modes passed the real bash-tool parsing check. All four frozen source hashes matched their archived snapshots, remote provider source matched, and all 12 original model-file hashes were recomputed remotely and matched. The exact app was verified stopped with zero active tasks. Earlier graph-startup failures, the CPU-only linker failure and successful eager-only measurements remain separate and unchanged.

## Serving measurements

Qwen3.5-4B at the frozen model revision, BF16, one A10, vLLM 0.32.0, native context limit 262,144 tokens and four maximum sequences. Each invented request forced exactly 128 output tokens; these were reasoning tokens with a length finish reason, not completed coding answers.

| Approximate input size | Concurrency | Requests per mode | Compiled/graph output tokens/s | Eager output tokens/s | Throughput ratio |
| --- | ---: | ---: | ---: | ---: | ---: |
| 8K | 1 | 4 | 33.90 | 22.88 | 1.48× |
| 8K | 4 | 4 | 41.13 | 32.62 | 1.26× |
| 32K | 1 | 4 | 15.35 | 12.18 | 1.26× |
| 32K | 4 | 4 | 19.16 | 16.95 | 1.13× |
| 64K | 1 | 2 | 7.71 | 6.68 | 1.15× |
| 64K | 2 | 2 | 8.09 | 7.30 | 1.11× |

The compiled mode used the engine's default compilation configuration and logged successful full and piecewise CUDA graph capture. Enforced eager mode disables torch compilation, CUDA graphs and JIT warmup together. These are mode-wide serving comparisons; the table does not isolate CUDA graphs as the sole cause of the improvement.

Compiled startup took about 238 seconds to readiness versus 110 seconds for eager. Its extra cold-start work must be amortized over later requests. Within compiled mode, batching improved aggregate throughput by approximately 1.21× at 8K, 1.25× at 32K and 1.05× at 64K, while increasing per-request latency. The previous 3.01× batching gain used a different output length and cannot be applied as a universal cost reduction.

## Limits and cost interpretation

This was a single sequential pass with compiled mode first. Mode-specific unique prefixes prevented full cross-case prefix reuse and caused small prompt-token-count differences. There was no randomized ordering, repeated sampling or uncertainty estimate. Inputs were invented, outputs deliberately short, and the largest inputs were 64K rather than the native maximum. The result neither measures Rails coding quality nor proves maximum-context concurrency or full-baseline affordability.

Rate-based compute for the remote function was approximately $0.26, covering both engine startups and their measurements. That excludes the separate CPU compilation gate, image/platform overhead and any billing reconciliation; it is not a verified invoice charge or account balance. Free credits only, the existing workspace usage ceiling and zero paid spending remain required.

## Continued preparation

The separate real-Qwen host-adapter preflight passed. The unmodified upstream host agent executed the invented isolation-marker command, received its successful tool observation, then submitted in two steps. Both requests reached one GPU container, with no provider errors. The subsequent request contains the first tool observation. The fixture verified that inference environment variables were absent inside task commands and that no ports were published. It used 2,462 input tokens and 331 output tokens; the harness's zero local-provider cost is not a claim of zero GPU billing.

All five archived source hashes matched, remote provider/helper hashes matched, and all 12 original model hashes matched. The exact Modal app was verified stopped with zero tasks; Docker had no remaining containers. This check validates short synthetic host connectivity and tool execution, not Rails coding quality, maximum-context capacity or a benchmark score. The previous installed-route concurrency check and all earlier failed probes remain separate.

No scored benchmark or training task has launched. The prospective comparison remains 135 distinct unstarted attempts over 46 tasks, with the original per-task allowances and three/two repetition schedule. Final benchmark environment/provenance, a declared infrastructure-failure policy, sufficient free compute and explicit scored-launch authorization remain gates. Raw run evidence, private deployment identifiers and detailed operational records stay local and out of model inputs/training.

## Proposed free-credit staging policy — awaiting a scope decision

The complete 135-attempt manifest was rechecked unchanged: 46 tasks, 43 with three attempts, the specified three multistep tasks with two, all unstarted, with 42 installed and four host task adapters. This audit does not freeze future task images or authorize a launch.

A free-only staged run would retain that complete manifest, the original task/session allowances and one declared model/serving configuration across batches. It would admit only unstarted attempts whose full remaining lifetime can be covered by reserved free compute, including setup, verification, concurrent active work and shutdown margin. It must pause admission before the allowance is exhausted rather than shorten a running attempt. A later batch would revalidate settings, source/model/environment hashes and current free allowance before continuing. Any environment change must be disclosed; monthly spacing is not proof of byte-identical historical reproduction.

The workspace usage ceiling and zero net-spend limit remain unchanged. Dashboard estimates lag; a launcher needs its own conservative resource-time reservation and independent shutdown, not just a balance check or a future Codex response. The six-hundred-second synthetic watchdog is intentionally unsuitable for full benchmark task allowances and must not be reused unchanged for scored attempts.

All attempted outcomes, including unscored infrastructure failures, must remain recorded. Do not replace them or infer a complete scored headline from incomplete coverage. Inference billing remains separate from the harness's local-provider zero cost. No scored launch, new probe or training is activated by this proposed policy. The pending choice is staged free-credit coverage, waiting for additional donated/free capacity, or explicitly reduced partial coverage.
