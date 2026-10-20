# Development grading after application exceptions

A completed Minitest suite that reports failures or errors now fails the task
(exit 1, harness reward 0). This includes application autoload exceptions raised
inside a test. Rails database preparation failures, missing test summaries,
zero executed tests, nonstandard process exits, and missing/incomplete hidden
check records remain infrastructure failures (exit 2, unscored).

The hidden suite must produce a complete summary and exactly one recorded check
per executed test, using only pass/fail/error/skip statuses. This policy applies
to the expense and team-ticket development tasks; it does not change the
vendored official benchmark. Hidden material remains outside model inputs.
Historical attempts retain their original unscored outcomes.

Validation used disposable containers with networking disabled:

- Team-ticket: all 13 cases passed, including baseline runtime exceptions,
  hidden-suite-only runtime exceptions, application autoload errors, missing
  verifier files, Rails setup failure, reference, nop, and six incomplete fixes.
  Evidence: `runs/team-ticket-grader-5gtr1h3a`.
- Expense: all 10 cases passed, including runtime/autoload errors, setup failure,
  reference, nop and existing incomplete fixes.
  Evidence: `runs/expense-grader-pku77rnu`.
- Real harness controls: oracle completed with reward 1; nop completed with
  reward 0, both with zero model tokens.
  Evidence: `runs/development-validation-X2Bbhp`.

The first fixture pass expected a missing superclass in application code to
cause a boot failure. Both suites instead completed tests with errors, correctly
returning 1 under this policy. Those failed validation expectations are retained
in `runs/team-ticket-grader-n3cjtc6z` and `runs/expense-grader-n8hkk2my`.
The corrected fixture distinguishes that case from removing Rails application
configuration in a disposable container, which prevents database preparation.

Next: one fresh local team-ticket attempt with the existing pinned MLX model,
32 steps, 16,384 input / 2,048 output tokens, 1,024 prefill chunk size, greedy
sampling, thinking disabled and unchanged deadlines. Preserve all outcomes.
