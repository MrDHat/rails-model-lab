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

## Outcome

The fresh attempt is **unscored**. Request 18 exceeded the fixed 8,192-token
input guard after two consecutive responses reached the output cap without
completing a tool call. The error traveled through the normal relay and the
harness exited 1 with `agent_error`, `scored: false`, and
`Colab AssertionError: Pilot input budget exceeded`. No submission or hidden
grading occurred. This supplies an end-to-end example of runtime error
propagation; the separate local error-injection check remains unrun.

| Measure | Observed |
| --- | --- |
| Repository at launch | `7a6a2f8492f0b7f399a634f1b732a94272674111`, clean |
| Trial | `expense-claim-submission__5nMrFCs` |
| Successful model responses / total requests | 17 / 18 |
| Accepted input / output tokens | 64,716 / 4,450 |
| Accepted generation time | 420.91 seconds |
| Operator-inclusive harness duration | 788.8 seconds |
| Maximum reported allocated GPU memory | 11.29 GiB |
| Visible baseline | 3 tests, 11 assertions, zero failures/errors |
| Hidden reward | None; grader not run |
| API price accounting | $0 local-provider rate; excludes Colab GPU cost |

Every successful response records eager attention, chunk size 1024, EOS 248046,
and the pinned model revision. Unlike the earlier attempt, request 15 at 6,188
input tokens completed and executed `bundle exec rails test`. Responses 16 and
17 each used all 1,024 output tokens writing an oversized edge-case script.
Neither had a complete native tool call, so neither script was executed.
Miniswen requested a concise response after each truncation. Request 18 then
hit the guard before generation; it has no generation usage measurement.

The agent added conditional model validations and reran its five-scenario
reproduction script before the baseline. The harness preserved the patch,
trajectory, agent result, and trial result despite the error. Passing visible
checks does not establish a hidden score or successful task completion.

Raw evidence is ignored under `runs/qwen-development-ZxW2Rq/`: 18 exact request
and response pairs, runtime settings, source snapshots, evaluation hashes,
`trials/Qwen3.5-4B/expense-claim-submission__5nMrFCs/`, and final Colab DOM and
screenshot. No hidden material or prior model solution was sent to Colab.

Chunking addressed the observed eager-attention memory failure for this
trajectory, but does not establish that every context up to the guard fits.
The next inference experiment needs a separately fixed output/context budget
or agent-history policy. Increasing the turn allowance alone is insufficient.
