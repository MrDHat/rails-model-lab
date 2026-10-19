# Fresh coding pilot with chunked prefill

## Protocol fixed before starting

Start from a fresh expense-claim container and empty miniswen history. Use the
unchanged Qwen3.5-4B revision `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`
in the existing Colab T4 runtime. Keep float16, eager attention, greedy decoding,
thinking disabled, tokenizer EOS 248046, 32 model turns, a 30-minute deadline,
60-second command timeout, 1,024 output tokens per turn, and an 8,192-token
input guard. Run one attempt; no training.

Compared with the interrupted 32-turn attempt, set
`model.generation_config.prefill_chunk_size = 1024` before the first request.
Use the current inference helper, which reports that setting and explicit
runtime errors. All input history is preserved. No prior solution, model
trajectory, hidden grading output, or reference patch is supplied to the new
agent. Diagnostic generations are never used as agent responses.

Launch: `COLAB_STEP_LIMIT=32 COLAB_PREFILL_CHUNK_SIZE=1024 bash bin/run-colab-development`. Copy the prefill
setup script into the ignored run evidence and retain exact requests/responses.
Verify every successful response records eager attention, chunk size 1024,
the pinned revision, and EOS 248046. If a runtime error occurs, relay it exactly
and report the resulting infrastructure outcome rather than a model score.

Measure agent submission, visible test execution, hidden reward, token use,
generation time, and operator-inclusive elapsed time separately. The earlier
memory probe covers one 6,188-token context, not the full input allowance. A
fresh failure must remain visible rather than trigger a mid-attempt limit change.

The runner validates `COLAB_PREFILL_CHUNK_SIZE` and puts it in every request;
the current Python helper passes it directly to `generate` and records it in
each successful response. Zero disables chunking explicitly. This prevents
prior notebook state from silently choosing the generation setting.
