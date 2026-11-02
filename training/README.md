# Training tasks

Small Rails exercises for post-training, written from public Rails docs. None
of them comes from the benchmark, and none is training data until training is
separately approved.

The 27B's main gap on the benchmark is fixes that pass the tests without using
the Rails API the task is about, which the benchmark scores at 0.1. These tasks
score the same way, so a working hand-rolled fix is worth less than the Rails
way.

## Task format

Each folder in `tasks/` holds:

- `request.md`: what the user asks for. It never names the API to use.
- `starter.rb`: the broken code the model starts from.
- `reference.rb`: the Rails way. Full credit.
- `handrolled.rb`: works, but skips the intended API. Partial credit.
- `broken.rb`: a plausible fix that is wrong. No credit.
- `behaviour_test.rb`: does the code work?
- `api_check_test.rb`: did it use the intended Rails API? It asks Rails what is
  declared (validators, enum types, nested-attribute options) instead of
  searching the source text.
- `setup.rb`: the in-memory schema and the answer under test, shared by both tests.
- `provenance.json`: sources, and which files may become training input,
  target or rejected answer.

Credit is 0 if the behaviour tests fail, 0.1 if they pass but the API check
fails, and 1 otherwise. A task with no API check gives 1 for passing.

## Check the tasks

```sh
bash training/check-tasks.sh              # all tasks
bash training/check-tasks.sh reservation-dates
```

It runs in a pinned Ruby 3.4 / Rails 8.1.3 image and fails if any answer
scores differently from its role: reference 1, hand-rolled 0.1, starter and
broken 0.
