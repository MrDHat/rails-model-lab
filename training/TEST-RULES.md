# Test split rules

These rules are written down before any model has been run on the test split, so the result can't be argued into shape afterwards. Change them only by adding a dated line to the log at the bottom, saying what changed and why, before the run it affects.

## Why

RL3 shows what goes wrong without rules. On validation it beat the untrained model by +0.30 in mean credit, with a 95% range of +0.10 to +0.49, a clear win by the numbers. On the official benchmark it scored 12.5 against 12.0, no real gain. Validation shares apps and task styles with training and was used to pick models, so it rewarded fitting our own tasks. The test split is there to catch that.

## What the test split is

32 app tasks on two apps no train task uses (Mender and Gazette), listed under `test` in `app-splits.json`. Each task is about one Rails API, listed in `test-targets.json`:

- **novel** (16 tasks): the API appears nowhere in training material. These measure general Rails skill.
- **transfer** (16 tasks): a train task teaches the API, and the test asks for it again in an unfamiliar, larger app. These measure whether what we trained carries over.

`bin/check-test-overlap` keeps this honest: it fails when a task's group stops matching the data, when a test request is a near-copy of a train request, or when any test file changed since it was frozen. `run-bench.sh test` won't start while it fails.

## Rules

1. **Never train or tune on it.** No test prompts, answers, tests, trajectories, patches or scores in any training data, and no reading test trajectories to decide what to train next. Training choices come from the train and validation splits and from attempt health only.
2. **Two looks.** The test split is run twice: once for the untrained Qwen 27B, and once for the final model. The final model is picked before its test run, on validation credit and attempt health. Each look goes in the log below. Any extra look, including a rerun with new harness settings, is logged with its reason before it runs.
3. **Same settings.** Both runs use the same harness, agent, limits, output-token cap and attempts (3 per task). Only infrastructure failures are rerun, as `run-bench.sh` already does.
4. **Frozen tasks.** No test task or test app changes after the first look. If one turns out to be broken, fix it, log it, and rerun both models on the fixed split.
5. **One score.** Mean credit per task, then the mean over tasks, from `bin/compare-runs` (`compare.txt`).
6. **The win rule.** The final model counts as better only if the whole paired 95% range for the difference over all 32 tasks is above 0. Otherwise the result is "no clear difference" (or "worse"), whatever the headline number says. With 32 tasks and 3 attempts the range is likely to be around ±0.15, so a smaller real gain won't show up as a win; that's the price of a small test set, not a reason to bend the rule.
7. **Report everything.** The novel and transfer lines are reported alongside the overall one, whether they flatter us or not. A gain only on transfer tasks means training taught specific APIs, not general skill, and the write-up says so. Attempt health (`health.txt`) is reported too.
8. **The official benchmark decides.** After the test run, the final model goes through the official benchmark once, with 5 attempts per task, and the result is published whatever it is.

## Known weaknesses

- The same author (Claude) wrote the train and test tasks, so they share habits in wording and in how graders check answers, even with no API overlap. A small set written by someone who never sees the training work would be a stronger test.
- The repository is public, so future base models may have seen these tasks. That doesn't affect Qwen 3.5, which was released before they were written.
- 32 tasks is small. The range in rule 6 is the honest measure of how much it can tell us.

## Looks log

| Date | Model | Why | Result |
|---|---|---|---|
| 2026-11-25 | none | Rules written and test split frozen (`frozen` in `test-targets.json`) | — |
