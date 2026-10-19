# First unchanged-Qwen development attempt

On 19 October 2026, Qwen3.5-4B produced a patch for the independently authored
expense-claim task. The patch passed all three baseline tests and all 27 hidden
tests (158 hidden assertions), earning reward **1.0**. The agent outcome was
**step_limit_reached**, not completed: it used all 12 permitted turns without
issuing the submission command.

This is one development-task pilot. It is neither an official Agents on Rails
score nor sufficient evidence of general Rails ability or a training benefit.
No training occurred.

## Configuration

| Setting | Value |
| --- | --- |
| Model | Qwen/Qwen3.5-4B |
| Checkpoint | 851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a |
| GPU / precision | Colab Tesla T4 / float16 |
| Runtime | Same package versions as the inference smoke-test record |
| Harness / agent | lemans 1.5.2 / bundled miniswen |
| Model transport | Interactive file relay via the Colab browser |
| Provider label | ollama/Qwen/Qwen3.5-4B; Ollama itself was not used |
| Agent budget | 12 turns, 30 minutes, 60 seconds per command |
| Generation | Greedy, thinking disabled, eager attention |
| Per-turn output / input limit | 1,024 / 8,192 tokens |
| End-of-turn token | Explicit tokenizer EOS 248046 |
| Attempt count / concurrency | 1 / 1 |
| App runtime | Local Linux ARM64 Docker, Rails 8.0.4, SQLite |
| Profile / task digest | f77b45f6c014c1ca / 0ba1e25bf1e97e05 |

The operator relayed the exact requests and responses without changing the
model's commands or giving hints. The user explicitly authorized sending the
task prompt, model-visible app content, and command/test output to the existing
Google Colab runtime. Hidden tests, reference solution, and evaluation design
were not sent. The hidden grader ran locally after the agent stopped.

## What the model did

The first eight turns inspected the app. Turn nine added conditional model
validations for submitted claims; turn ten reread that file. Turn eleven tried
to run visible tests from `/testbed`, which does not exist in this app container.
Turn twelve ran `pwd && ls -la`. The agent then exhausted its budget.

The grader restored protected starter files, ran the baseline suite, and ran
the hidden tests against the model's patch. Both suites passed without errors.
The correct patch and the incomplete agent workflow are separate observations.
The hidden-test result was not fed back into the model.

The harness recorded 30,050 input tokens and 774 output tokens across 12 calls.
Accepted generations took 106.78 seconds in total, with peak GPU allocation
of 10.53 GiB.
Wall time was 518.7 seconds, including browser relay delays and an initial
generation diagnostic. API-token cost was recorded as $0 for local inference;
that excludes any Colab compute cost. This timing is not comparable to a fully
automated model-serving benchmark.

## Infrastructure findings

The loaded model's generation config had EOS 248044 while the tokenizer's
end-of-turn token was 248046. The first generation continued into fabricated
conversation turns and hit 1,024 tokens. Its output was preserved as a diagnostic
and never executed. The initial request was retried unchanged after explicitly
setting the tokenizer EOS; it then stopped normally after 40 tokens. The
diagnostic's 1,024 tokens and 75.36 seconds are outside the 12 accepted model
responses and their token totals, but inside the harness wall time.

A pricing-registry refresh stalled during an earlier startup before any model
request. The opt-in adapter now uses the bundled registry for this local provider.
The original startup directory is retained under `runs/qwen-development-9ezkJ3`.

After the successful grading report, the original shell wrapper exited 127
with `nd: command not found`. Editing that running wrapper to add source
snapshots shifted its file offsets. The saved result, patch, and verifier logs
had already been written; the error occurred after grading. The wrapper now
uses `exec` for its final harness command, and its shell syntax passes. The full
model run was not repeated merely to recheck that wrapper change.

## Evidence and next experiment

Local evidence is retained under ignored `runs/qwen-development-7BMmfG/`:

- `relay/`: exact request/response JSON, raw decoded generations, diagnostic
  generation, and the observed EOS configuration.
- `trials/Qwen3.5-4B/expense-claim-submission__Wwaafbu/`: result JSON, trajectory,
  agent patch, baseline and graded logs, checks, and verifier output.
- Generated bench configuration, transport source snapshots, Gemfile.lock,
  repository revision, and evaluation-file SHA-256 manifest.

The run started from commit `bf2987c` with uncommitted transport files; the
snapshots preserve the code used. The Python snapshot includes the EOS fix
applied before the first accepted response. Source changes made afterward are
described above. A synthetic Ruby transport fixture verified command and token
preservation; Python checks covered multiline commands, multiple calls,
truncation, wrong tools, prose, and extra parameters. Syntax and whitespace
checks passed.

The next experiment should set a larger turn budget in advance and repeat the
unchanged-model attempt, measuring submission and verification separately.
Do not increase this attempt's budget retroactively. Keep these task files,
patches, and logs out of training data.
