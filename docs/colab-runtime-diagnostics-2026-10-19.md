# Colab inference failure handling and memory diagnostics

The fresh 32-turn pilot was interrupted after eager attention ran out of memory
on request 15. The original attempt remains unscored. These later diagnostics
never execute generated commands and never become responses in that run's relay.

## Transport fix

The Python helper now catches execution exceptions and prints a structured error
with the request identity and loaded checkpoint revision. The Ruby transport
checks those fields, then raises `Miniswen::InfrastructureError` before parsing
an answer. Successful responses also record attention and prefill configuration.
This prevents a runtime failure from being represented as an empty model answer.

Local fixtures cover preserving commands and token accounting, explicit runtime
errors, revision mismatches, multiline tool calls, malformed parameters, and
successful Python response output. Python, Ruby, and shell syntax/whitespace
checks pass. The live SDPA diagnostics also returned structured errors.

A proposed full-harness local error-injection check was not run: automatic
approval review rejected the normal runner because it did not itself guarantee
local-only execution. The passing local transport fixtures do not establish an
end-to-end harness outcome. No full-harness failure-handling result is claimed.

## Same failed request, separate runtime probes

All probes used the loaded Qwen3.5-4B checkpoint from the original runtime,
float16, the full 6,188-token history, greedy decoding, tokenizer EOS 248046,
and the original 1,024-token output cap. Notebook exception references and
unused cached GPU allocations were cleared before probing; the model was not
reloaded. These are diagnostic observations, not controlled performance tests.

| Configuration | Observed result |
| --- | --- |
| Default SDPA | CUDA OOM attempting a 2.28 GiB allocation |
| SDPA requiring memory-efficient kernel | No available kernel; runtime warned that query heads (16) and key/value heads (4) differ |
| Eager, prefill chunks of 1,024 tokens | Succeeded: 55 output tokens, 11.37 seconds, peak GPU allocation 11.12 GiB |

The successful probe generated a visible Rails-test command. That command was
not executed. The operator did not shorten history, raise output limits, apply
patches, or resume the interrupted attempt. This validates one previously
failing context, not the entire 8,192-token input allowance or arbitrary Rails
repositories. Chunked prefill changes inference execution and may change
floating-point results; a future coding attempt must start fresh and record it.

Scripts: `experiments/colab-sdpa-probe.py` and
`experiments/colab-prefill-probe.py`, after loading the current inference helper.
Evidence is under ignored `runs/qwen-development-AIGYqt/` as
`sdpa-default-diagnostic.txt`, `sdpa-efficient-diagnostic.txt`,
`chunked-prefill-diagnostic.json`, and screenshots. The scored relay contains
only the original 14 accepted responses. Its failed request still has no
response file.

The runtime currently has eager attention and `prefill_chunk_size=1024`.
Reset or explicitly record these settings before any new run. Keep all task
content and generated patches out of training data.

The [Transformers attention interface](https://huggingface.co/docs/transformers/attention_interface)
documents runtime backend switching. The
[generation implementation](https://github.com/huggingface/transformers/blob/main/src/transformers/generation/utils.py)
describes `prefill_chunk_size` and cache-based prompt chunking. The live probe
used installed Transformers 5.20.1; upstream `main` is background documentation,
not a pin for reproducing that package.
