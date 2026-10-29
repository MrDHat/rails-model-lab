# Qwen inference cost options — 2026-10-29

The approximately $268 scenario describes the old serial deployment, not an optimized cost floor. Several avoidable serialization points exist. Initial research used source inspection and public documentation. A subsequently authorized synthetic GPU probe measured a batching speedup, recorded below; it does not establish that the complete 135-attempt baseline fits the remaining free credit. No scored benchmark attempt or hidden evidence was used in this cost probe.

## Concrete starting point

The preserved local `runs/full-baseline-20261026/modal_inference.py` specifies A10, two physical CPU cores, 16 GiB RAM, one container, a 120-second scale-down window, BF16 Qwen3.5-4B at revision `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`, vLLM 0.32.0, native 262,144 context, `--max-num-seqs 1`, prefix caching, language-model-only mode, and `--enforce-eager`. There is no `@modal.concurrent` decorator. These are observed configuration facts, not measured utilization.

## What the saved timing actually says

The coordinating analysis read numeric timing/usage metadata only for the one scored attempt: 59 inference responses totaled 5104.17 seconds of a 5407.1-second attempt, or **94.4%**. Reported output was 149,957 tokens and input 546,117 tokens; output divided by inference elapsed time is 29.38 tokens/second, including prefill overhead. Only about 5.6% of this task's wall time was outside those model calls, so eliminating tool-idle GPU time alone cannot explain an order-of-magnitude saving. This one task is not a representative workload sample. Reported cached tokens were zero; that does not prove the backend did no cache reuse. Original response artifacts stay local and unchanged.

## Priorities that preserve the model and task contract

| Priority | Change to investigate | Why it may save cost | What must be validated |
| --- | --- | --- | --- |
| 1 | Keep one GPU, run a small number of isolated task agents concurrently, and permit concurrent Modal calls plus multiple vLLM sequences | Different tasks can use the same resident weights and overlap model generation with other tasks' shell/test work | Throughput per billed dollar, memory/cache pressure, end-to-end request latency and task wall-clock limits; no shared files/conversations |
| 2 | Test CUDA graphs rather than forcing eager execution | Current flag disables a normal vLLM optimization | Startup/capture cost, memory headroom, kernels/tool parsing and long-context stability on this exact model/version/GPU |
| 3 | Measure prefix-cache hits and chunked-prefill behavior | Growing agent conversations repeat prefixes; mixed prefill/decode can improve utilization | Actual hit rate and prefill/decode times, not just the enabled flag |
| 4 | Compare A10 with L4 using identical synthetic workloads | L4 has a lower hourly rate | Completed useful tokens/second per dollar; lower price does not prove lower task cost |
| 5 | Right-size host CPU/RAM and idle window from telemetry | Avoid paying for unused requested resources or repeated cold starts | Peak host memory/CPU, startup count and idle gaps; do not starve tokenization/server handling |

### Batching needs the whole path

Modal assigns one input at a time per container by default. Its class-level `@modal.concurrent(max_inputs=...)` can forward simultaneous requests to a vLLM server, which performs continuous batching. The existing `max_containers=1` is useful to retain: increase work sharing within one GPU rather than accidentally renting several GPUs. The existing host bridge also uses `HTTPServer`, which handles requests serially. All four layers—harness concurrency, threaded/asynchronous bridge handling, Modal concurrent inputs, and the vLLM sequence limit—must permit overlap; changing only one setting cannot create batches. This is an implementation inference from the existing source and [Modal input-concurrency docs](https://modal.com/docs/guide/concurrent-inputs).

Start by measuring concurrency 1, 2 and 4 on synthetic agent-like prompts, not by assuming eight workers give eight times the throughput. Preserve each attempt's original clock, command limits, sandbox resources and separate environment. Queuing cannot be hidden by extending task timeouts. Excess cache pressure can force recomputation; vLLM recommends watching preemptions and tuning sequence/token budgets accordingly. Chunked prefill interleaves prompt processing and decoding but trades prompt latency against decode latency. These are scheduling options, not a reason to truncate the 262,144 context. [vLLM optimization guide](https://docs.vllm.ai/en/stable/configuration/optimization/)

### Eager mode and caching

`--enforce-eager` disables CUDA graph capture. Graphs can speed inference but consume additional GPU memory; restricted capture sizes may offer a middle ground. This is a strong candidate for a small synthetic performance test, not a verified speedup. The frozen old experiment must remain unchanged. [vLLM memory/graph documentation](https://docs.vllm.ai/en/stable/configuration/conserving_memory/)

Prefix caching is already enabled, so simply adding the flag is not a new saving. It reuses common prompt computation and does not accelerate generation of new output tokens. Long reasoning output can therefore remain expensive even with excellent cache hits. [vLLM automatic prefix caching](https://docs.vllm.ai/en/stable/features/automatic_prefix_caching/)

## Hardware arithmetic, not a performance prediction

[Modal's current price list](https://modal.com/pricing) gives A10 at $1.1016/hour and L4 at $0.7992/hour. The same requested two physical CPU cores and 16 GiB contribute $0.222192/hour. That gives a resource-rate ceiling of $1.323792/hour on A10 or $1.021392/hour on L4: about **22.8% less per hour**, before differences in runtime. A $25 usage ceiling would cover at most about 24.48 hours at the latter rate if entirely available for this workload, excluding build/other usage. Current remaining allowance has not been verified here.

A10 and L4 both have 24 GB memory, but NVIDIA specifies A10 memory bandwidth at 600 GB/s versus L4 at 300 GB/s. This matters for decode-heavy small-batch inference, so L4 could erase its price advantage by taking longer. It should be measured rather than chosen from price alone. [NVIDIA A10 datasheet](https://www.nvidia.com/content/dam/en-zz/Solutions/Data-Center/a10/pdf/a10-datasheet.pdf), [NVIDIA Ada/L4 specifications, appendix D](https://images.nvidia.cn/aem-dam/Solutions/geforce/ada/nvidia-ada-gpu-architecture.pdf)

The same NVIDIA comparison lists no BF16 tensor support on T4. Its cheaper list price is therefore not a drop-in route for this BF16 configuration. Converting to FP16 or quantized weights would be a separately declared configuration. Disabling thinking, cutting output/context allowance or shortening task budgets would likewise change the experiment, rather than demonstrate an efficiency gain for the existing baseline.

## Freeze after optimization, then compare

Batching and hardware changes preserve the intended weight/generation configuration, but do not promise identical sampled text. vLLM does not guarantee reproducibility by default, and even its stronger reproducibility settings are scoped to the same hardware and software version. Batch-invariance support is beta; Qwen3.5-4B is not explicitly listed among the tested models on the current documentation page. Do not enable an unsupported mode and claim numerical identity. Record chosen hardware, scheduler settings, versions and seed prospectively, then use the same serving setup for a later trained-model comparison. [vLLM reproducibility](https://docs.vllm.ai/en/stable/usage/reproducibility/), [batch invariance](https://docs.vllm.ai/en/stable/features/batch_invariance/)

The next useful experiment is a bounded synthetic throughput/latency sweep, with startup, idle gaps, prefill, output tokens, cache/preemption metrics and actual billed time captured. It must have an independent time/credit stop and keep $0 paid spending, the $25 workspace ceiling, no public endpoint and no persistent volume. This note does not launch that experiment. No speculative percentage saving is enough to authorize the full batch; choose the cheapest configuration that passes correctness and latency gates, then calculate a new feasibility range from measurements.

## Authorized synthetic probe

After user approval, `experiments/qwen_cost_probe.py` was launched as a separate private ephemeral Modal app. The original benchmark app remains stopped. Billing was checked before launch: $25.14 free credit, $4.86 workspace usage against the $25 ceiling, and $0 spend limit. These are point-in-time readings, not a final invoice.

The probe reuses the existing private vLLM 0.32.0 image and verifies all 12 original model-file hashes before inference. It uses one A10 with capped two physical CPU cores and 16 GiB host RAM, four maximum vLLM sequences, and the native context limit. It compares eager execution and CUDA graphs sequentially in one GPU function; each mode runs four synthetic requests at concurrency 1, 2 and 4. All measurement requests use approximately 8K tokens of invented code and force 512 output tokens solely to normalize throughput. These diagnostic caps are not benchmark generation limits. Each mode also has a native bash-tool parsing gate. Temperature, top-p, top-k, thinking and seed follow the original settings. No benchmark examples, graders, references, stored model conversations or task workspaces are sent.

An 840-second remote engine watchdog, 900-second Modal function timeout, zero configured retries, two-second idle scale-down and 1200-second local deadline bound the test independently of Codex. The known A10/CPU/RAM resource rate implies about $0.33 for 900 execution seconds, excluding startup/image overhead; the operational allowance is under $1 of free credit, not a paid purchase. App-context exit stops the ephemeral app, including on client disconnection. Completion/failure queues one direct callback; there is no scheduled status polling. Existing app records prevent a silent second invocation.

This measures the vLLM engine directly over sandbox loopback, so that requests can actually overlap. It does not claim to have validated simultaneous full Rails agents or the production bridge/Modal input path. A winning engine configuration still needs isolated harness integration and latency checks before any new scored attempt. Raw synthetic results, event status, model hashes and logs are retained in `runs/qwen-cost-probe-20261029/`; no cost reduction is claimed until those measurements return. L4 comparison is not included in this initial probe.

## Measured synthetic results

The probe finished with status `partial_or_failed`: all three eager-mode cases completed, while CUDA graph mode failed before readiness. Each case processed four requests with 8,222 prompt tokens and exactly 512 output tokens per request. The eager native bash-tool parsing gate passed. The returned source hash matches the launched source, and all 12 model hashes match the original manifest.

| Simultaneous requests | Aggregate output tokens/s | Four-request wall time | Mean request latency | Throughput vs serial | Compute/token reduction vs serial |
| --- | --- | --- | --- | --- | --- |
| 1 | 23.08 | 88.73 s | 22.18 s | 1.00× | — |
| 2 | 37.75 | 54.26 s | 27.09 s | 1.64× | 38.9% |
| 4 | 69.51 | 29.46 s | 29.18 s | 3.01× | 66.8% |

These savings apply to the measured inference intervals at the same resource rate. Four-way batching increased mean individual request latency by about 32%, even as aggregate throughput tripled. Each concurrency level was measured once over four requests; there are no confidence intervals, randomized order, long-context stress tests or coding-quality results. All measured outputs reached the forced length limit within reasoning; this is a throughput workload, not evidence of completed answers or successful Rails tasks. Real conversations, cache behavior, output lengths and agent tool gaps can change both throughput and task-time effects. The approximately $268 serial scenario cannot simply be divided by three and presented as a forecast.

CUDA graph mode failed in FlashInfer sampling warmup with `Could not find nvcc and default cuda_home='/usr/local/cuda' doesn't exist`. This is an image/toolchain failure, not a measured CUDA graph slowdown, model failure or demonstrated memory shortage. No graph throughput or graph tool-gate result exists. No retry was launched. A separately bounded follow-up would need the CUDA build toolchain or compatible prebuilt sampling kernels before comparing graph performance.

Total remote function elapsed time was 546.56 seconds, including both mode startups and the failed graph startup. At the declared resource rate this is approximately **$0.20**, excluding platform startup/teardown or other billing overhead; it is not a reconciled invoice. Modal app `ap-xm9WQWUcu3Vzcq9Imx6ReU` was verified `stopped`, with zero tasks, stopped at 2026-10-29 07:51:52 UTC. Existing $0 paid-spending and workspace budget controls were not changed. No scored benchmark task started.

Four-way eager batching is now a measured candidate. The next integration gate is simultaneous isolated synthetic agents through the actual installed-adapter/bridge/Modal route, retaining individual task clocks and model settings. Affordability of the complete 135-attempt comparison remains unproven.

## Concurrent harness transport checkpoint

A separate prospective threaded loopback bridge and four-agent Docker integration now pass locally. Four upstream installed Miniswen agents reached a fake provider simultaneously through their independent sandbox stdio relays. Each submitted after two calls, wrote/read its own sandbox marker, and retained separate request/response evidence: eight pairs, no crossed observations, no published ports and no GPU calls. Authentication, fixed generation-setting precedence, expired-deadline rejection and immediate concurrency-overflow rejection also passed. The original frozen serial bridge was not changed.

This closes the local bridge/installed-agent serialization check. The Modal RPC method is still a synthetic callable in this integration; live concurrent Modal inputs and actual Qwen tool calls through this complete path remain unvalidated. No GPU work, scored task or training starts from these files. The next useful gate is one bounded synthetic real-provider integration, not a full benchmark launch.
