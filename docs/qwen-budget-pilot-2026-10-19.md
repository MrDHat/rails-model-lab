# Output and context budget validation

## Protocol fixed before diagnostics

Keep the pinned Qwen3.5-4B revision, existing float16 Colab T4 runtime, eager
attention, 1,024-token prefill chunks, greedy decoding, thinking disabled, and
explicit tokenizer EOS 248046. No training or agent-history changes.

Test a 12,288-token input guard and 2,048-token output cap. First run a separate
synthetic allocation diagnostic with exactly 12,288 repeated input tokens and
2,048 forced output tokens. This checks one allocation shape, not all inputs.
Then replay request `56d80846-301a-45ff-9a7d-ad7c3095dfd7` from the previous
attempt with only those two budget fields changed. Preserve the output outside
the old relay; never execute its generated commands or resume that attempt.

If both diagnostics succeed, start one fresh expense-claim container and empty
miniswen history with 32 turns, 30-minute deadline, and 60-second command timeout:

```sh
COLAB_STEP_LIMIT=32 COLAB_PREFILL_CHUNK_SIZE=1024 \
COLAB_INPUT_TOKEN_LIMIT=12288 COLAB_OUTPUT_TOKEN_LIMIT=2048 \
bash bin/run-colab-development
```

Keep the settings fixed throughout. Preserve exact requests/responses and
runtime settings. A failure stays unscored; passing visible tests alone does
not imply submission or a hidden reward. Diagnostics and previous trajectories
are never included in the fresh agent's history. Hidden tests and reference
solutions stay local and all evaluation evidence stays out of training.
