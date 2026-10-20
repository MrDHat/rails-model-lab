# Fixed-budget expense attempt after relay recovery

Source: `29f0ecd468a9ee44dd32a6648da2bdf513c5995d`.
Run: `runs/qwen-development-zS0STA`.
Trial: `expense-claim-submission__89Cl98k`.

The unchanged Qwen checkpoint used 32 steps, input limit 12,288, output cap
2,048, eager attention, prefill chunks 1,024, and the existing 30-minute agent /
600-second response deadlines. Runtime versions match the earlier pilot and
are preserved in `runtime.json`; evaluation input hashes are preserved in
`evaluation-inputs.json`.

The harness ended after 1,079.1 seconds with `agent_error`, **unscored**, because
request 31 contained 12,321 input tokens. There was no submission or hidden
grade. Thirty generations were delivered and consumed: 197,452 input / 5,977
output tokens, 609.2 generation seconds, peak allocation 10.46 GiB. No response
was truncated, expired, or quarantined. The starter suite passed 3 tests /
11 assertions during the attempt.

The model's first implementation raised on a nil merchant in its own
reproduction. After revising it, its reproduction still printed whitespace
merchant failures. The model repeatedly explained that `present?` rejects
whitespace but kept writing the same ineffective conditional. Its reproduction
script prints outcomes rather than asserting them; a zero exit status is not
proof that those checks passed. The final patch and complete trajectory remain
in the trial directory. These observations are not a hidden-test result.

## Delivery limitation and follow-up

The UUID visibility locator missed complete output that was readable through
the output region's DOM text. Twelve responses used a recorded operator DOM
fallback, preserving the exact JSON through the same identity/deadline checks.
`browser-relay-events.jsonl` and `operator-dom-fallback.js` preserve this
assistance. This attempt does not establish fully automatic relay reliability.
No model setting, deadline, task input, or generated command was changed.

The next relay revision reads complete JSON from the output region before
relying on visibility matches, and rechecks the text after a visibility timeout.
Partial stdout fragments wait for complete JSON. A regression fixture covers
missing visible matches and fragmented output; all six relay fixtures pass.
Fresh live non-task request `f4d466ff-3aa8-46c0-a92e-4df64266efdd` returned OK
(17 input / 2 output tokens, 0.29 generation seconds), was delivered by the
revised helper and consumed by the provider without an operator fallback.

Next: use the independent team-ticket task with the same model and fixed
budgets. Do not extend or resume the ended expense attempt or count it as a
zero/pass. No training has occurred, and evaluation artifacts remain excluded
from training and model-visible workspaces.
