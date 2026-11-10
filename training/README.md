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

## App tasks

The tasks above are each one file. The benchmark's are changes to whole
Rails apps, so `app-tasks/` holds 35 harder ones, each a change to one of two
small apps with their own test suites:

- [Toolshed](apps/toolshed), a makerspace's tool lending (members, tools,
  categories, loans, a mailer and a nightly job), 16 tasks.
- [Crumb](apps/crumb), a Paris bakery's orders: a JSON API for its mobile
  app, HTML admin pages, a mailer and an SMS job, 19 tasks.

A fix usually touches several files: a migration, a model, a controller, a
view, a mailer, a job.

Each folder in `app-tasks/` holds:

- `request.md`: what the user asks for.
- `task.json`: which app it runs on, its area and a title.
- `reference/`, `handrolled/`, `broken/`: answers, as the files they add or
  change in the app. Scored 1, 0.1 and 0, like the one-file tasks; the
  untouched app scores 0.
- `tests/behaviour_test.rb`: hidden tests, run with `bin/rails test`.
- `tests/api_check_test.rb`: did the answer use the intended Rails API? It
  asks Rails where it can, and otherwise reads `AnswerCalls.names`, the
  methods the answer's changed files called while the hidden tests ran.

[`bin/grade-app`](bin/grade-app) grades an answer. The app's own suite must
still pass and the hidden tests must pass, or the credit is 0; the API check
then decides 1 or 0.1.

```sh
bash training/check-app-tasks.sh             # every answer scores as its role expects
bash training/check-app-tasks.sh --schema    # first regenerate db/schema.rb for answers that add migrations
```

[`app-splits.json`](app-splits.json) fixes 21 training, 7 validation and 7
sealed app tasks, with at most one task per area in each held-out set. The
apps share one `Gemfile.lock`, so one image runs them all.

`bin/build-bench` adds them to the agentic bench, where the agent gets the
whole app in `/app`, and `run-bench.sh apps` runs them.

## SFT: train on the model's own successes

The first training stage is rejection sampling: the model attempts the train
tasks, the tests and the API check pick out its full-credit attempts, and a
LoRA learns from those transcripts. No other model writes the data, and no
benchmark prompt, grader, reference answer or run log goes near it.

1. **Collect.** `run-bench.sh train` runs every train task (one-file and app)
   6 times with sampling unseeded (`SAMPLING_SEED=none`), so the attempts differ.
2. **Build.** [`sft/build_dataset.py`](sft/build_dataset.py) keeps attempts
   with reward 1.0, at most 4 per task (the fewest steps), as chat transcripts.
   It refuses held-out tasks.
3. **Train.** [`sft/train.py`](sft/train.py) trains a rank-32 LoRA on every
   linear layer of the language model, loss on the assistant turns only
   (reasoning, text and bash calls). It fits a 32K-token transcript on one
   A100 80GB beside the bf16 weights by checkpointing layers, MLP chunks and
   loss chunks, and moving saved activations to CPU. It checkpoints every 2
   steps and resumes, for spot VMs.
4. **Merge.** [`sft/merge.py`](sft/merge.py) folds the adapter into full
   weights that vLLM serves like the base model.

On the GPU VM, [`sft/run.sh`](sft/run.sh) does steps 2 to 4 and is safe to
rerun after a preemption. Then serve and evaluate:

```sh
bash training/run-bench.sh train                        # step 1, with SAMPLING_SEED=none when serving
bash training/sft/run.sh                                # build, train, merge
QWEN=qwen3.5-27b-sft bash baseline/serve-qwen.sh
QWEN=qwen3.5-27b-sft bash training/run-bench.sh validation
```

First run (Qwen3.5-27B, 123 transcripts from 36 of 61 train tasks, 2 epochs,
30 steps on one spot A100): training loss fell from 0.13 to 0.09, but the
validation stage didn't move. Both models fully solved 23 of 51 attempts
(mean credit 0.494 each), on the same serving setup and seed. The model
already writes these transcripts, so there is little left to learn from
them. Most held-out misses score 0.1: the tests pass but the answer skips the
intended Rails API, and training only on successes never shows that contrast.

## DPO: prefer the full-credit attempt over the near miss

The second stage shows the model that contrast. For each train task where the
collected attempts include both a full-credit one and a miss, a pair puts
them side by side, and DPO raises the probability of the full-credit
transcript relative to the miss, measured against the untrained model so
nothing else drifts.

1. **Pairs.** [`dpo/build_pairs.py`](dpo/build_pairs.py) uses the same train
   collection as SFT: at most 6 pairs per task, misses at 0.1 first (the
   commonest held-out mistake), spread so one transcript doesn't fill every
   pair. Held-out tasks and unscored attempts are refused.
2. **Train.** [`dpo/train.py`](dpo/train.py) reuses the SFT LoRA and memory
   tricks. The reference model is the base with the LoRA off, scored once.
   Each pair's two transcripts are backpropagated one at a time, so a 30K-token
   pair fits on one A100.
3. **Merge** as for SFT.

```sh
bash training/dpo/run.sh                                # pairs, train, merge
QWEN=qwen3.5-27b-dpo bash baseline/serve-qwen.sh
QWEN=qwen3.5-27b-dpo bash training/run-bench.sh validation
```

First run (Qwen3.5-27B, 125 pairs from 24 train tasks, beta 0.1, 1 epoch, 32
steps of 4 pairs, about 2.3 hours on one spot A100): by the end the model
ranked the full-credit attempt above the miss in most pairs. On validation it
fully solved 27 of 51 attempts against 23 for the base model (mean credit
0.569 against 0.494, zero-credit attempts 4 against 6, pass@3 unchanged at
10/17), on the same serving setup and seed. The gain is concentrated in three
tasks that went from one full-credit attempt or none to two or three; one task
lost one. With 51 attempts that is a promising but not yet conclusive margin.
