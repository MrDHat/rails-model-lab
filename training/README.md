# Training tasks

Sixty small Rails exercises for post-training, written from public Rails docs.
None of them comes from the benchmark, and none is training data until
training is separately approved.

The 27B's main gap on the benchmark is fixes that pass the tests without using
the Rails API the task is about, which the benchmark scores at 0.1. These tasks
score the same way, so a working hand-rolled fix is worth less than the Rails
way.

## Areas

Five tasks in each of twelve areas, picked from the Rails guides as a whole
rather than from what the benchmark covers.

| Area | Tasks |
|---|---|
| Validations | `decimal-invoice-line`, `project-slug-uniqueness`, `reservation-dates`, `signup-email-format`, `terms-acceptance` |
| Attributes | `contact-email-normalization`, `legacy-email-alias`, `post-tags-json`, `ticket-priority-default`, `user-settings-store` |
| Enums | `account-two-states`, `payment-status-enum`, `shirt-size-codes`, `task-state-enum`, `ticket-urgency-order` |
| Nested forms and autosave | `order-billing-address`, `order-line-autosave`, `profile-update-only`, `route-nested-stops`, `survey-question-limit` |
| Associations | `article-tags-through`, `category-restrict-delete`, `latest-reply-has-one`, `post-comment-count`, `task-touches-project` |
| Record security and lifecycle | `invite-secure-token`, `password-reset-token`, `patient-encrypted-field`, `product-sku-readonly`, `user-secure-password` |
| Querying | `batched-export`, `book-list-preload`, `price-upsert`, `status-counts`, `unassigned-tickets` |
| Dates and times | `billing-next-month`, `elapsed-time-words`, `invoices-for-month`, `local-day-window`, `monday-week-range` |
| Active Job | `bulk-enqueue-emails`, `cleanup-job-discard`, `payment-job-give-up`, `report-job-queue`, `sync-job-retry` |
| Active Support helpers | `archivable-concern`, `exporter-columns-setting`, `invoice-customer-delegate`, `names-to-sentence`, `request-current-user` |
| Caching, instrumentation and errors | `checkout-instrumentation`, `price-widget-fallback`, `prices-fetch-multi`, `product-card-cache-key`, `rates-cache-fetch` |
| Transactions and bulk writes | `article-view-counter`, `contacts-insert-skip`, `doc-optimistic-lock`, `newsletter-create-or-find`, `wallet-transfer-transaction` |

## Splits

[`splits.json`](splits.json) fixes 40 training, 10 validation and 10 sealed
tasks, with at most one validation and one sealed task per area. Training uses
only the training tasks; validation is for choosing settings; sealed tasks are
scored only to check whether what the model learned carries over to tasks it
never saw. Never train or tune on them.

## Task format

Each folder in `tasks/` holds:

- `request.md`: what the user asks for. It never names the API to use.
- `starter.rb`: the broken code the model starts from.
- `reference.rb`: the Rails way. Full credit.
- `handrolled.rb`: works, but skips the intended API. Partial credit.
- `broken.rb`: a plausible fix that is wrong. No credit.
- `behaviour_test.rb`: does the code work?
- `api_check_test.rb`: did it use the intended Rails API? Where Rails can say
  what is declared (validators, enum types, association and nested-attribute
  options), the check asks Rails. Otherwise it records the methods the answer
  actually calls while the behaviour tests run
  ([`lib/answer_calls.rb`](lib/answer_calls.rb)), so calls in comments,
  strings or code that never runs don't count. Where Rails offers more than
  one right way, each is accepted.
- `setup.rb`: the in-memory schema and the answer under test, shared by both tests.
- `provenance.json`: area, sources, and which files may become training input,
  target or rejected answer.
- `attacks/` (some tasks): answers written by reviewers to get credit they
  shouldn't, each with its expected credit on the first line. They stay in
  the check so fixed holes stay fixed. They are never training data.

Credit is 0 if the behaviour tests fail, 0.1 if they pass but the API check
fails, and 1 otherwise. `local-day-window` has no single API to require, so it
has no API check and gives 1 for passing.

## Check the tasks

```sh
bash training/check-tasks.sh              # all tasks
bash training/check-tasks.sh reservation-dates
```

It runs in a pinned Ruby 3.4 / Rails 8.1.3 image and fails if any answer
scores differently from its role: reference 1, hand-rolled 0.1, starter and
broken 0, and each attack what its first line says.

An API check proves that the intended API ran, not that it did the work: an
answer that does the job by hand and also makes a pointless call to the right
method still gets full credit. Watch for that in sampled answers before
trusting the reward for reinforcement learning.

## Run the tasks as an agent

`bin/build-bench` turns the tasks into a lemans bench in `training/bench/`
(ignored by git), so a model works on them the way it works on the benchmark:
the same miniswen agent, model transport and limits (90 minutes, 400 steps,
300 s per command). The agent gets the request and a small project whose
`app.rb` holds the starter code. It never sees the tests or the API check:
lemans uploads them only to grade `app.rb`, with the same credit as above.

On the baseline VM, after `baseline/serve-qwen.sh`:

```sh
bash training/run-bench.sh proof                       # oracle 1.0 and no-op 0 on every task
QWEN=qwen3.5-27b bash training/run-bench.sh heldout    # validation + sealed, 3 attempts each
```
