# Qwen graph and context probe

The synthetic probe finished with a **partial/failed** overall outcome: all six eager cases passed (20 requests), while CUDA graph mode failed before serving any requests. No graph throughput or speedup was measured. No scored Rails attempt or training ran.

## Measured eager throughput

Qwen3.5-4B, BF16, one A10, vLLM 0.32.0; native context limit 262,144 tokens. Each invented request forced exactly 128 output tokens, all reported as reasoning tokens with a length finish reason.

| Approximate context | Actual prompt tokens | Concurrent requests | Total requests | Aggregate output tokens/s | Mean request latency |
| --- | ---: | ---: | ---: | ---: | ---: |
| 8K | 8,223 | 1 | 4 | 22.68 | 5.64s |
| 8K | 8,223 | 4 | 4 | 32.78 | 15.38s |
| 32K | 32,800 | 1 | 4 | 12.13 | 10.55s |
| 32K | 32,800 | 4 | 4 | 16.72 | 29.57s |
| 64K | 65,568 | 1 | 2 | 6.62 | 19.33s |
| 64K | 65,568 | 2 | 2 | 7.20 | 34.86s |

Within each input size, batching improved aggregate throughput by 1.45×, 1.38× and 1.09× respectively, while increasing individual request latency. This is less than the earlier 3.01× gain from the separate 8K/512-output-token sweep. The output length differs, so these are workload-dependent observations, not contradictory measurements or a controlled cross-probe speed comparison. Long inputs and short outputs leave less benefit from batching; the evidence does not isolate every source of that effect.

## Graph failure

Compiler discovery was repaired without downloading another toolkit. The CPU-only trivial-kernel compilation gate passed. Graph engine startup then failed when FlashInfer sampling compilation rejected incompatible CUDA compiler and toolkit headers. The retained diagnostic explicitly reports that incompatibility; the installed compiler reports CUDA 13.4 while the image's PyTorch reports CUDA 13.0. This does not establish which package change would repair the environment. The graph mode failed before readiness, so graph capture itself was not validated.

The simple compiler gate was insufficient: it did not compile against FlashInfer's bundled compatibility header. A separate CPU-only diagnostic is now prepared to exercise that header before another GPU probe. Its syntax is checked locally; execution in the inference image and a compatible package selection remain unvalidated. It does not allocate a GPU, install packages or launch inference. No replacement probe or silent rerun was started, and the executed source snapshots remain unchanged.

## Verification and limits

Both frozen controller/provider source hashes match the working sources and archived snapshots at verification. The CPU and remote source hashes match; all 12 original model-file hashes were recomputed remotely and matched the original manifest. The exact app was verified stopped with zero active tasks. Automatic shutdown and the direct completion callback worked without scheduled polling.

Rate-based compute for the measured remote function was approximately $0.18, including the failed startup and successful eager work. This excludes separate CPU/image/platform overhead and is not a verified invoice charge or current account balance. The existing free-credit-only constraint, workspace usage ceiling and zero paid-spending limit remain unchanged.

This single-pass synthetic diagnostic used unique prefixes, graphs first, and short forced outputs. It is not a coding-quality result, a randomized graph/eager comparison, a maximum-context capacity test, or proof that the complete Rails baseline fits available free credit. Previous failed and successful probes remain separate; raw logs, private deployment identifiers and detailed operational records remain local.

Remaining preparation includes compiler/header compatibility validation on CPU, a separately bounded graph startup test only after that passes, validation of the host-adapter route, and a final compute/provenance check. Scored benchmark and training launches remain blocked pending their required decisions and authorization.
