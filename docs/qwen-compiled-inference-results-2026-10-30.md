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

The unmodified host adapter still passes its two-call fake-provider Docker integration after adding optional real-provider support. A separate, bounded real-Qwen host-adapter preflight has now been launched using the same repaired compiler/runtime discovery and compiled/graph engine configuration. It must verify packaged source and the original model hashes before running one invented host-agent task. It keeps a one-GPU maximum, an independent six-hundred-second remote lifetime bound, a nine-hundred-second local deadline and direct completion delivery. Its outcome is pending; it is not part of the throughput table above.

No scored benchmark or training task has launched. The prospective comparison remains 135 distinct unstarted attempts over 46 tasks, with the original per-task allowances and three/two repetition schedule. Real host-route completion, final provenance and adequate free compute remain launch gates. Raw run evidence, private deployment identifiers and detailed operational records stay local and out of model inputs/training.
