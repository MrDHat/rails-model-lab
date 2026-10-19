# Independent expense-claim evaluation validation

Validated locally on 19 October 2026 with lemans 1.5.2, Docker Desktop,
Ruby 3.4.7, Rails 8.0.4, SQLite, and Linux ARM64 containers.

This validates our independently authored development task, not model quality
or performance on the official Rails benchmark. No model calls, GPU sessions,
or inference charges were involved.

## Full harness results

| Agent | Outcome | Task score | Hidden tests |
| --- | --- | --- | --- |
| oracle (supplied reference patch) | completed | 1.0 | 27 passed |
| nop (unchanged starter) | completed | 0.0 | 8 passed, 19 failed |

Both consumed zero input and output tokens and cost $0 in model usage. The
`validation-only` model label in results is placeholder harness metadata.
The unchanged starter passes its three visible baseline tests.

Evidence is saved locally under the ignored directory
`runs/development-validation-C6dK7i`, including each trial's result JSON,
checks, database log, baseline log, and graded log.

## Deliberately flawed fixes

Separate fresh, network-disabled containers exercised the same grader:

| Candidate | Result |
| --- | --- |
| Unchanged starter | Rejected; 19 hidden test failures |
| Reference behavior | Accepted; all 27 hidden tests pass |
| Requires complete drafts | Rejected by visible baseline regression tests |
| Validates creation only | Rejected; 9 hidden test failures |
| Accepts whitespace-only merchants | Rejected; 2 hidden test failures |
| Accepts zero amounts | Rejected; 3 hidden test failures |
| Persists merchant before validating an update | Rejected; 4 hidden test failures |

Evidence: `runs/development-mutations/summary.json` and per-candidate logs.
The mutation checks establish that the grader detects these specific defects;
they do not prove that every possible incorrect solution will be caught.

## Reproduce

From the repository root, with Docker running and the root bundle installed:

```sh
bash bin/validate-development
python3 bin/validate-development-mutations
```

The first command creates a new evidence directory and asserts completed
outcomes and expected scores. The second rebuilds the starter image, runs all
seven candidates, and checks their expected exit codes. It replaces prior
mutation evidence. Neither command calls a model.

Only `environment/app` enters the starter image. Hidden tests are uploaded by
lemans after an agent finishes; the solution patch is used by the oracle.
The grader, reference fix, and mutation definitions are outside the model's
starter workspace. All evaluation material and attempts stay out of training.

## Decisions and limits

- Task success is all-or-nothing; individual checks diagnose failures.
- HTTP requests and reloaded database records establish behavior without
  requiring a particular implementation or exact error message.
- Baseline assertion failures reject a candidate. Database setup failures,
  missing results, and test exceptions require investigation rather than
  silently receiving a zero. Model edits can also cause such exceptions.
- Rails is pinned to 8.0.4, Minitest to major version 5, gems are locked, and
  the Ruby base image is pinned by digest. An initial dependency resolution
  selected Minitest 6, which failed with Rails 8.0.4; this was fixed before
  validation. Debian package installation is not snapshot-pinned.
- This run validates Linux ARM64. A different platform needs its own build
  check and potentially additional lockfile platforms.
- Model agent settings, provider access, and inference limits are not configured
  yet. The safe default is nop. The next experiment is an unchanged-model
  attempt using miniswen after those settings are agreed and recorded.
