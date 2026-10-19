# Colab pilot

The first Qwen development attempt uses the unchanged smoke-test checkpoint in
the existing Colab GPU runtime. Local Docker holds the starter Rails app;
lemans 1.5.2 and miniswen run locally. Only model requests and responses cross
the browser connection. No public inference endpoint is opened.

## Run

1. Load the model as in `qwen-colab-smoke.py`, using revision
   `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`.
2. Execute `colab-agent-inference.py` in that same runtime.
3. Locally run `bash bin/run-colab-development` with Docker running.
4. For each new `*.request.json` in the printed relay directory, execute
   `colab_complete(request_json_string)` in Colab. Transfer the request exactly,
   using proper string escaping. Save the resulting JSON unchanged to the
   corresponding `*.response.json` locally. Write to a temporary file first,
   then rename it atomically so Ruby never reads a partial response.
5. Repeat until miniswen submits, reaches a limit, or fails. Inspect the final
   result outcome, score, grader logs, patch, and trajectory.

The default budget remains twelve turns. Set `COLAB_STEP_LIMIT` to a positive
integer before launching a fresh attempt to override it; the generated bench
configuration preserves the chosen value. The follow-up protocol uses
`COLAB_STEP_LIMIT=32 bash bin/run-colab-development`.
Set `COLAB_PREFILL_CHUNK_SIZE=1024` to request chunked prefill explicitly.
The default zero sends `null`, disabling chunking for that request regardless
of prior notebook generation settings. Load the current Python helper first.

This is an interactive transport: the operator relays bytes, without editing
the model's answer or choosing its commands. The model receives miniswen's
standard system and task prompts plus its bash tool schema. The helper uses
the checkpoint's own chat template and parses its native XML tool calls into
the OpenAI-compatible response shape expected by RubyLLM. It never translates
prose into commands or repairs malformed tool calls. The raw generation is
saved alongside the parsed response. Unsupported parameter markup is rejected.

The `ollama/` model prefix selects RubyLLM's local, OpenAI-compatible provider
and zero API-token pricing; Ollama itself is not running. An opt-in Ruby
extension substitutes the file transport and skips remote pricing-registry
refresh. Miniswen's agent logic and the hidden grader are unchanged. Treat
this transport, the limits below, and the runtime as experimental settings
when comparing results. Zero API-token pricing does not mean GPU time is free.

## Limits and evidence

- One expense-claim attempt; concurrency one.
- Twelve model turns; 30-minute agent deadline; 60-second command timeout.
- Up to 1,024 output tokens per turn, greedy generation, thinking disabled.
- Explicit tokenizer end-of-turn token `248046`. The observed model generation
  config used `248044`; leaving that default allowed generation to continue
  into fabricated conversation turns. A diagnostic generation was preserved
  and discarded before any command execution, then the same initial request
  was retried with this stopping correction.
- At most 8,192 input tokens per turn. The helper refuses longer requests;
  exceeding this is a pilot infrastructure limit, not a model score.
- Ten-minute relay-response timeout per turn. Operator latency counts against
  the agent deadline, so elapsed time is not pure model execution time.
- No training, answer hints, hidden-test feedback, or reference patch enter
  the model's request stream. Visible starter tests and their output may enter.

The run directory includes the generated configuration, repository revision,
tracked working-tree diff, transport source snapshots, Gemfile.lock, exact
requests/responses, and lemans outputs. Evaluation files remain local and out
of training. Do not use the attempt logs as training examples.

Generate a local JSON checkpoint summary without starting Docker or Colab:

```sh
python3 bin/report-colab-run runs/qwen-development-XXXXXX
PYTHONDONTWRITEBYTECODE=1 python3 experiments/test-colab-report.py
```

The report keeps accepted generation usage separate from trial outcome and
submission. It lists pending requests, relayed runtime errors, truncations,
observed runtime settings, and allocated GPU peaks. Only a scored harness
result supplies a reward. Missing trial results stay absent, and missing
historical runtime settings appear as `null`; neither proves completion.
External diagnostics saved outside the relay are excluded. Request/response
identity or prefill-setting mismatches fail the report instead of being counted.

## Runtime diagnostics and failures

The inference helper prints an identity-tagged `error` response when model
execution or a context guard fails. Relay that JSON exactly as a response;
the Ruby adapter raises `Miniswen::InfrastructureError` before parsing any
model answer. Do not turn failures into empty completions or zero rewards.
Local protocol fixtures run without Colab or Docker:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 experiments/test-colab-inference.py
bundle exec ruby experiments/test-colab-file-provider.rb
```

The 32-turn eager-attention attempt ran out of GPU memory at 6,188 input tokens.
`colab-sdpa-probe.py` and `colab-prefill-probe.py` are separate diagnostic
configurations. Load the current inference helper first, execute one probe
script in the loaded runtime, then pass the exact failed request string to
`probe_request`. Preserve its output outside the scored run's relay directory;
never execute the generated commands or resume the interrupted attempt.

The SDPA probe changes the attention backend and requires the memory-efficient
kernel explicitly. The prefill probe restores eager attention and sets
`model.generation_config.prefill_chunk_size = 1024`; it preserves the full
unpadded, single-request history and output cap. Both change runtime settings.
After probing, reload the model or explicitly reset attention and
`prefill_chunk_size` before a future protocol. Do not assume the old defaults
remain in the live runtime. Record runtime settings alongside each result.

Input and output budgets are also explicit per request. Defaults remain
8,192 input tokens and 1,024 output tokens. Set `COLAB_INPUT_TOKEN_LIMIT` and
`COLAB_OUTPUT_TOKEN_LIMIT` before launch to change them; the local runner and
helper enforce ceilings of 16,384 and 4,096 respectively. Those ceilings are
safety bounds, not a claim that every permitted configuration fits the T4.
Load the current helper, which records the effective limits in each response.
The [budget protocol](../docs/qwen-budget-pilot-2026-10-19.md) first checks
12,288 input / 2,048 output with a separate synthetic allocation test and a
replay diagnostic before launching a fresh coding attempt.

The parser follows the pinned checkpoint's
[native chat template](https://huggingface.co/Qwen/Qwen3.5-4B/blob/851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a/chat_template.jinja).
