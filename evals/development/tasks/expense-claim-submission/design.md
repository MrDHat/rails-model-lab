# Expense claim submission — evaluation design

Status: starter, grader, and reference fix implemented. Local validation recorded
in `docs/development-eval-validation-2026-10-19.md` at the repository root.
No model has attempted this task yet.

This is the first independently authored development evaluation. Its prompt,
starter app, grader, eventual reference solution, and model attempts must stay
out of training data. It is not an official Rails benchmark task and must not
be included in an official benchmark score.

## What we want to learn

Can the model implement a small conditional business rule while preserving
draft saving and existing HTTP behavior? Can it handle updates as well as
creation, including leaving persisted data intact after a rejected update?

The request describes user-visible behavior. It does not name a validator,
callback, service object, file to edit, or preferred implementation. Tests will
use HTTP requests and persisted records, not inspect source code.

## Starting app

A minimal Rails JSON app with SQLite and one `ExpenseClaim` resource. No login,
external services, approval workflow, or frontend is needed for this task.

The existing schema and API are context available to the model in the app;
they are not additional implementation instructions:

| Field | Existing meaning |
| --- | --- |
| `merchant` | Nullable string |
| `amount_cents` | Nullable integer; money is represented in cents |
| `incurred_on` | Nullable date |
| `status` | `draft` or `submitted`, defaults to `draft` |

Existing routes: `POST /expense_claims`, `PATCH /expense_claims/:id`, and
`GET /expense_claims/:id`. Request fields are nested under `expense_claim`.
Successful creation returns 201; successful editing and retrieval return 200.
Success responses include the claim's ID and four fields. Validation failures
return 422 and a JSON `errors` object with at least one nonempty message.
Exact error wording is not part of the contract.

The starter already rejects statuses outside `draft` and `submitted`, handles
not-found records with 404, and uses normal date/integer columns. Its defect is
that it saves submitted claims without checking the three required fields.
Baseline tests demonstrate the routes and response conventions. The model
can run those tests. The additional grading tests are supplied only after its
attempt, so it must work from the feature request and application context.

## Grading cases

Each case runs against a clean database. The grader checks HTTP status, response
shape, and database state. Related examples below become separate assertions
or parameterized cases so a failure identifies the broken behavior.

| Case | Action | Expected behavior |
| --- | --- | --- |
| Empty draft | Create a claim with only `status: draft` | 201; draft saved with missing details |
| Partial draft | Create a draft with just a merchant, then add an amount | Both saves succeed; omitted details remain absent |
| Valid submission | Create a submitted claim with merchant, amount 1250, date 2026-01-12 | 201; submitted claim persisted with those values |
| Minimum positive amount | Create a complete submitted claim with amount 1 | 201; one cent is accepted |
| Missing merchant | Create an otherwise valid submitted claim with merchant absent, empty, or whitespace-only | Each returns 422 with errors; no record created |
| Invalid amount | Create an otherwise valid submitted claim with amount absent, zero, or negative | Each returns 422 with errors; no record created |
| Missing date | Create an otherwise valid submitted claim without a date | 422 with errors; no record created |
| Submit incomplete draft | Create an empty draft, then patch only its status to submitted | 422 with errors; original draft unchanged |
| Complete and submit together | Create an empty draft, then patch all details and status to submitted | 200; all new values persisted |
| Submit completed draft | Create a complete draft, then patch only its status | 200; existing details retained; status submitted |
| Damage submitted claim | Patch a valid submitted claim to remove merchant, remove date, or make amount absent, zero, or negative | Each returns 422 with errors; all prior fields unchanged |
| Edit submitted claim | Patch a valid submitted claim with a different valid merchant and amount | 200; changes persisted |
| Atomic rejection | Patch a submitted claim with a new merchant and amount zero together | 422; neither field is changed in the database |
| Existing API behavior | Read a claim; edit a missing ID; try an unknown status | Existing success, 404, and 422 behavior preserved |

The grader must fetch persisted state again after a failed update. Inspecting
only the response or an in-memory object could miss an accidental database
write. Invalid creation cases must also assert the record count is unchanged.

## Boundaries and scoring

We do not grade future dates, currency conversion, merchant normalization,
whether an incomplete draft can contain zero or negative amounts, moving a
submitted claim back to draft, or concurrent updates. The request does not
define those policies. Avoid hidden requirements disguised as edge cases.

Primary task score: 1 only if every required behavior and regression check
passes, otherwise 0. Keep per-case outcomes for diagnosis, not as a second
headline score. A single task is a debugging aid, not evidence of broad Rails
ability. Multiple attempts would estimate reliability on this task, not expand
its coverage.

Before evaluating a model, run the grader against the unchanged starter
(expected task score 0) and a reference fix (expected task score 1). Also check
that it catches plausible incomplete fixes: validating all drafts, checking
creation only, accepting whitespace merchants, accepting zero, and writing
some fields before rejecting an update. A broken container, failed dependency
install, or grader crash is an infrastructure failure, not a model score of 0.

## Harness integration

The task uses the pinned lemans 1.5.2 harness. `bin/validate-development` runs
its oracle and nop agents and checks both outcomes and scores. The default
agent is nop, and `validation-only` is required harness metadata, not a model.
Future model attempts must explicitly configure miniswen and the real model
endpoint, limits, and inference settings before running. This suite remains
separate from the official benchmark checkout and score reports.

`bin/validate-development-mutations` checks five deliberately flawed fixes in
fresh containers as well as the reference and unchanged app. The unchanged
app passes its three visible baseline tests. Hidden grading has 27 tests.
Baseline regressions stop grading early. Database setup failures, missing
results, and test exceptions produce exit 2 for investigation; assertion
failures produce exit 1. This conservative distinction requires human review
of exceptions, which can also be caused by model edits.

The container pins Ruby by image digest and Rails to 8.0.4. Its Gemfile.lock
records resolved dependencies for the validated Linux ARM64 environment.
Minitest is constrained to version 5 because Rails 8.0.4 failed with version 6.
System packages are installed from Debian repositories; the full image is not
a bit-for-bit reproducible build. The harness records the environment digest.

The grader source lives in this repository for our review; the model's task
workspace must contain only the starter, its baseline tests, and the prompt.
The eventual reference solution must also remain outside that workspace.
