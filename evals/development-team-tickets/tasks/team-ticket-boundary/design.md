# Team ticket boundary — evaluation design

This second independent development task measures association scoping and
ownership protection through HTTP behavior. It is separate from the expense
claim suite and the official Rails benchmark. Its prompts, hidden tests,
reference fix and model attempts must stay out of training datasets.
No model has attempted this task yet.

## Starting app and contract

A Rails 8.0.4 JSON app has teams and tickets. A trusted development gateway
supplies X-Team-ID. The existing current_team helper returns that team and
rejects missing or unknown identities with 401. Authentication is explicitly
outside this task; the header is a fixture, not a proposed production scheme.

Teams have many tickets. Tickets belong to one team, require a title, and have
open/closed status. The API exposes GET /tickets, GET /tickets/:id and PATCH
/tickets/:id. Successful responses are 200; lists are arrays ordered by ID;
individual responses include id, team_id, title and status. Edits nest fields
under ticket. Invalid edits return 422 with field errors. Missing IDs return
404. The starter accidentally queries tickets globally and permits team_id.

The model sees only the starter, three regression tests, and the user request.
The request specifies team isolation and ignored ownership edits without
naming a Rails method or preferred implementation. No hidden tests or
reference patch are present in the task workspace.

## Grading behavior

The hidden grader has 18 HTTP integration tests:

| Case | Required behavior |
| --- | --- |
| Lists for two teams | Each gets only its own IDs, in ascending order |
| Empty team | An empty array |
| Caller supplies team_id in list query | Existing identity still determines the list |
| Own show | All existing public fields remain readable |
| Foreign or missing show | 404; saved data unchanged |
| Foreign show with owner query | Still 404 |
| Foreign edits | 404, regardless of valid or invalid attributes; all records unchanged |
| Foreign edit attempts ownership transfer | 404; cannot steal a ticket |
| Reverse direction | The second team also cannot read or edit the first team's ticket |
| Own valid edits | Title/status update, owner and unrelated records unchanged |
| team_id is another team, null, or a nonexistent team | Ignore the ownership field while applying valid editable fields |
| Invalid own edit with ownership field | 422 and field errors; no partial writes |
| Missing or unknown identity | Preserve 401 for list, show and update; no writes |
| Missing update ID | Preserve 404; no writes |

The grader reloads records and compares persisted state after rejected edits.
It asserts outputs, not controller source or a particular association method.
The baseline tests continue to run first; grading cannot silently discard an
existing API regression. Exact error wording and the shape of 404 bodies are
not graded; foreign ticket titles must not appear in rejected read responses. There is no task requirement for ticket creation, pagination,
new identity mechanisms, timing equality, or concurrent ownership changes.

## Validity and scoring

The primary task score is binary: all required behavior and baseline checks
pass for 1, otherwise 0. Keep individual failures for diagnosis. No model
score exists until a model attempt completes with a valid harness outcome.
Infrastructure exceptions remain unscored and need investigation.

Run the no-model harness checks:

```sh
bash bin/validate-development evals/development-team-tickets team-ticket-boundary
python3 bin/validate-team-ticket-mutations
```

Oracle should complete at 1.0 and nop at 0.0 with zero model tokens. Mutation
checks also reject six incomplete fixes: list-only, unscoped update,
writable ownership, unscoped list, unscoped show, and caller-selected list
team. Every variant runs in a fresh network-disabled container.

The environment uses the same pinned Ruby image and Rails dependency lock as
the first development suite, but a separate starter app and benchmark root.
Changes here do not change the expense-claim model workspace. As before,
Debian package downloads prevent a bit-for-bit build claim. The harness
records its environment digest. Tests and config are restored for grading.
