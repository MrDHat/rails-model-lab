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

## Separate diagnostics

Both prescribed checks passed in the existing runtime:

| Diagnostic | Input / output tokens | Seconds | Peak allocated GPU GiB |
| --- | --- | --- | --- |
| Synthetic boundary, forced full generation | 12,288 / 2,048 | 192.78 | 12.16 |
| Previously truncated request, larger cap | 6,355 / 1,200 | 98.14 | 11.12 |

The replay ended with one complete native tool call instead of a truncated
response. Its generated command was not executed. The synthetic test validates
one repeated-token input shape; it does not guarantee every input fits.
Raw requests, outputs, source snapshots, and a screenshot are ignored under
`runs/qwen-budget-diagnostics/`.

## Fresh attempt outcome

The attempt is **unscored**: the seventeenth response reached the local file
relay after its ten-minute deadline. The harness recorded `agent_error` with
`Colab response timed out for 34ed9c65-3b18-4e82-9757-ab2477c8a127`, exited 1,
and ran no hidden grader. There was no submission. Do not resume this trial
with the late response.

| Measure | Observed |
| --- | --- |
| Launch revision | `4aac46f`, clean |
| Trial | `expense-claim-submission__Ty1yTVP` |
| Consumed responses | 16 |
| Consumed input / output tokens | 57,188 / 3,344 |
| Generation seconds for consumed responses | 314.26 |
| Preserved generated responses, including late answer | 17 |
| All generated input / output tokens | 64,734 / 3,999 |
| All generated seconds | 379.02 |
| Maximum reported allocated GPU GiB | 11.29 |
| Harness duration including operator latency | 1,382.7 seconds |
| Submission / hidden reward | None / unscored |

All 17 generated responses recorded the prescribed limits and pinned runtime
settings. None was truncated or failed due to memory or context length.
The model's reproduction script passed its five printed scenarios, the Rails
baseline passed 3 tests / 11 assertions, and an eight-scenario edge-case script
printed all passes. These printed scripts are agent checks, not hidden grading.

The fresh trajectory diverged from the previous one: its edge-case script
used 964 tokens and completed within even the former output cap. The separate
replay establishes that a larger cap completed the previously truncated
response; the fresh attempt alone does not establish that causal comparison.

The late answer generated an API test script in 655 tokens / 64.76 seconds.
It was written to the local response file approximately 641.7 seconds after
the request appeared, beyond the 600-second transport allowance. The API
command was **not executed**. Model generation time and operator/browser
delivery latency must be reported separately. The preserved agent result
ends after the edge-case check and confirms only 16 consumed responses.

Evidence is ignored under `runs/qwen-development-h6jWTq/`: exact relay files,
source snapshots, runtime settings, evaluation hashes, trial and agent results,
patch, trajectory, and final browser evidence. The current reporting tool's
`accepted_*` totals actually count response files, including a late unconsumed
answer; use the agent result for consumed usage until that reporting issue is
fixed. No score, completion, or API execution is inferred from a response file.

The budget diagnostics are successful, but reliable end-to-end completion
remains unproven. The next infrastructure checkpoint should record response
consumption and correct the summary labels before another model attempt.

The follow-up reporting change now names file totals `generated_*` and records
protocol 2 consumption receipts for future requests. Historical files remain
unchanged, and this trial still has no receipts: its agent result remains the
source for consumed usage. These changes improve accounting; they do not fix
the browser relay's delivery latency or make this trial scored.
