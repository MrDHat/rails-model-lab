# Qwen graph and context probe

Status: the CPU compilation gate passed and the bounded synthetic GPU comparison has been launched; throughput results are pending. No scored Rails attempts or training are part of this probe.

The previous graph startup failure was caused by compiler discovery: CPU inspection found the CUDA compiler already installed in the image, outside the process search path. The new probe exposes that installation and requires a CPU-only CUDA compilation check before requesting a GPU. The first inspection failed because serialization required matching Python versions; it ran no GPU inference and remains recorded separately. The corrected inspection succeeded without installing another toolkit.

The frozen probe compares graph execution and eager execution sequentially on one A10 with Qwen3.5-4B in BF16. Both modes retain the native 262,144-token context limit and the same tool and reasoning parsers. Invented inputs target 8K, 32K and 64K tokens: concurrency one and four at the first two sizes, then one and two at 64K. Each request forces 128 output tokens to measure serving performance. Exact token usage, failures and partial cases are retained locally.

This is a single-pass diagnostic with graphs first, not a randomized comparison or a coding-quality measurement. It does not test four simultaneous maximum-length conversations or prove the full benchmark fits the remaining free credit. Synthetic output limits do not change the planned benchmark limits.

The controller refuses to reuse its run directory. A CPU compiler gate, source/model hash checks, a remote engine watchdog, a remote function timeout and an independent local deadline bound execution. The app exits before a direct completion callback is sent; no scheduled polling is installed. Existing free credit and zero paid spending remain required. Raw logs, private deployment identities and detailed operational evidence remain local.

The public concurrent-provider template also forwards its required image configuration into the remote import environment. This repairs the published template after deployment values were removed; the previously completed run and its frozen source remain unchanged.
