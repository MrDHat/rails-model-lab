# Overnight progress — 20 October 2026

## Starting point

No official model baseline or training run exists yet. The initial independent
expense-claim pilot passed all hidden checks at a step limit without submitting.
Later attempts were unscored infrastructure failures. The latest fresh run
missed the relay deadline on response 17; its late command was not executed.
See the budget pilot record for the exact accounting and limitations.

## Transport checkpoint

The local provider previously checked for a response file before checking its
deadline. A file that appeared after the deadline while the provider slept could
therefore be accepted. Protocol 3 checks the monotonic deadline first, adds
request expiry timestamps, and preserves an expiry marker on timeout. The
600-second response budget is unchanged.

A new browser-relay module separates the filesystem exchange from browser
interaction. The exchange checks request identity, model settings and response
revision, records observation/write times, and quarantines late responses as
diagnostics. Filesystem fixtures exercise exact bytes, late responses, stale
requests, runtime mismatches and runtime errors. The browser layer is still
experimental and has not passed a live end-to-end check.

Validation: five JavaScript filesystem fixtures, Ruby provider fixtures
(including a late-arrival timeout race), eight report fixtures and five Python
inference fixtures passed. No model score is associated with these tests.

## Runtime access

The old Colab runtime disconnected after inactivity and reconnected to a T4.
The Mac then locked, preventing native browser control. After the user unlocked
it, Chrome's evaluation page remained blank and its browser automation debugger
was unattached. A native Chrome reload restored a blank scratchpad connected to
a T4. A simple `RUNTIME_CHECK` cell executed successfully. Package versions,
model load and full delivery remain to be checked. Historical notebook output
and run evidence were already preserved locally before reload.

## Next checkpoints

1. Verify packages and reload the exact pinned checkpoint and inference helper.
2. Validate live relay delivery plus provider consumption on a non-task fixture.
3. Run a fresh expense-claim attempt with 32 steps, 12,288 input / 2,048 output,
   eager attention, prefill chunks of 1,024, and existing deadlines.
4. Require explicit submission and preserved harness results before claiming
   completion; distinguish model failures from invalid infrastructure trials.
5. Broaden independent development coverage before any training experiment.

All evaluation prompts, reference patches, hidden graders and run evidence
remain excluded from training data. Hidden material stays local. Checkpoint
PRs remain reviewable and are not automatically merged.

## Independent evaluation coverage checkpoint

A second starter and task now cover team ticket boundaries. The finalized
reference passes 18 hidden tests / 74 assertions plus three baseline tests /
12 assertions. Oracle completed at 1.0, nop at 0.0, with zero model tokens.
All six incomplete fixes were rejected by the mutation matrix. The
[validation record](team-ticket-validation-2026-10-20.md) preserves the initial
fixture correction, Docker credential stall, successful rerun and evidence paths.
No model attempt or training run has been added.

Chrome's extension now reports an expired session. An attempt to restore that
session was rejected by automatic approval review as an account sign-in
outside the Colab authorization; explicit approval is pending. Local Docker
work continued through an isolated anonymous public-registry configuration.

The attempted full task publication was also rejected by automatic approval
review because hidden tests/reference files were required to remain local.
The public checkpoint therefore excludes the new hidden grader, reference,
detailed design and mutation validator through explicit ignore rules. They
remain intact in this workspace. Publishing them requires explicit approval;
the starter, task request and outcome record can be reviewed independently.

The user subsequently approved restoring the existing Chrome extension session
and including the new hidden grader, reference and mutation fixtures in the
GitHub PR. The temporary ignore rules were removed before publication.
That approval does not put hidden material in model workspaces or inference
requests; those isolation boundaries remain in place.

## Live relay recovery checkpoint

Published the approved team-ticket files in PR #10, commit `0d3f084`.
The approved extension sign-in briefly succeeded but returned to expired.
Existing claimed tabs remained unattached; a fresh automation tab opened the
scratchpad through Colab's recent-notebook link and successfully executed a
runtime check on the T4. No credentials were entered by the agent.

The exact pinned model and unchanged inference helper were loaded. Rich model
loading output hit Colab's expired-login/third-party-cookie error. Automatic
approval review rejected a reload during execution; reload approval was
requested. Dismissing the error allowed work to continue without reloading:
subsequent plain-text helper and generation output was readable.

Live probe evidence is in `runs/colab-live-relay-check`. The first request
returned OK, but exposed a regex locator that missed visible JSON; its exact
response was preserved and delivered using the filesystem exchange, with the
failure explicitly logged. After switching detection to literal request UUID,
a second fresh request (`575b7ce1-08aa-41a2-8663-ceec34a1ba0e`) passed the
browser helper end to end: 17 input / 2 output tokens, 0.25 seconds generation,
response delivered and parsed by the Ruby provider, which exited successfully.
This is a non-task transport check, not a model evaluation score.

The runner now selects either suite and freezes/hash-records local inputs
before evaluation. Offline wiring checks for both tasks validated selected task,
all hashes, non-symlink snapshots, and absence of grader/reference files inside
the starter app. They did not start an agent or Docker and are not scored runs:
`runs/qwen-development-Az7Kdi` and `runs/qwen-development-pX1kA7`.

## Fixed-budget expense attempt and output-text correction

PR #11 publishes source `29f0ecd`. Its fresh expense attempt delivered and
consumed 30 generations without truncation, timeout, OOM, or late responses,
but ended unscored on request 31's input guard (12,321 > 12,288). The model
repeated a faulty validation conditional despite identifying it in prose.
Twelve deliveries needed an explicitly recorded DOM-text fallback because
visibility matching missed readable output. The [attempt record](qwen-relay-attempt-2026-10-20.md)
preserves the limits, usage, evidence, and distinction between model behavior
and transport assistance.

The relay now reads complete output text directly, with a regression fixture
for missing visible matches and fragmented JSON. All six fixtures pass. A fresh
live probe passed the revised helper/provider path without a fallback. The
pending reload request proved unnecessary: work continued without reloading
or changing account/cookie security settings. The next measured run will use
the independent team-ticket task with the same model and budgets.

## Further local validation while Colab scope approval is pending

Automatic approval review rejected the team-ticket model run because the
explicit Colab authorization covered only expense-claim content. A separate
approval request for its visible prompt, starter and command/test output is
pending; grader/reference/mutation fixtures remain excluded from inference.
No team-ticket model run was started.

Local oracle/nop validation completed on two additional official tasks:
compact positions and tenant isolation. All four runs completed at expected
1.0/0.0 rewards with zero model tokens. This brings cumulative official harness
validation to three tasks, not an official model baseline. The
[validation record](benchmark-validation-2026-10-20.md) preserves exact trials,
scope and evidence. The script now accepts explicit task lists and records a
fresh scope per invocation. The report exposes DOM fallback evidence directly;
nine report fixtures pass. README now summarizes the latest outcomes clearly.

A separate synthetic 16,384-input / 2,048-output allocation diagnostic is in
progress on the already authorized expense runtime. It contains no task or
grader content and cannot establish a task score. Its result will determine
whether a future separately recorded expense protocol can reach the fixed
step limit without hitting the smaller context guard.

## Final observed checkpoint

The synthetic 16K-input / 2K-output diagnostic passed. The fresh Colab attempt
consumed 16 generations without a DOM fallback, then disconnected and timed
out unscored. Reconnect approval remains pending after automatic approval review
rejected the possible loss of executing notebook/model state.

PR #14 adds a separately pinned offline MLX community 4-bit variant. Its short
smoke, native-tool parser and Ruby provider-consumption checks passed. A fresh
team-ticket attempt consumed all 22 generations locally, reached the time
limit, and ended unscored because the model introduced an undefined exception
class that the current verifier classified as infrastructure failure. This
requires a future grading-policy fix and broken-app mutation coverage; the
original attempt must remain unscored.

The [complete result record](qwen-local-results-2026-10-20.md) preserves exact
usage, outcomes and next steps. No official model tasks or training runs were
launched. The three-task prospective protocol is committed for later work.
The active autonomous goal reports `usageLimited`; further evaluations stopped
after observing that limit. All checkpoint PRs remain unmerged.
