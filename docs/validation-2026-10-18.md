# Initial benchmark validation — 18 October 2026

The official `at-announce-once` task validated successfully on local Docker.
This is a setup check, not a model evaluation.

| Agent | Credit | Outcome | Model tokens | Model cost | Duration |
| --- | ---: | --- | ---: | ---: | ---: |
| Reference solution (`oracle`) | 1.0 | completed | 0 | $0 | 146.5 s |
| No changes (`nop`) | 0.0 | completed | 0 | $0 | 27.4 s |

The oracle passed all 11 hidden checks. The no-op failed five required
behaviour checks and the optional API-usage check. Both runs completed the
application suite with 179 tests, no failures or errors, and two upstream
skips. We did not investigate those skips or change upstream tests.

## Recorded environment

- Benchmark commit: `f587d5a44897f3467af2a48c0503aef4eb6acf55`; clean checkout.
- Harness: lemans 1.5.2, dependencies pinned in `Gemfile.lock`.
- Host Ruby: 3.4.2; Docker server: 29.1.3.
- Container architecture: arm64; container Ruby: 3.4.7.
- Image ID: `sha256:6dc49a91f02835934a9dc66a8210e14711cfe832775c3582c9ce265309baa71d`.
- Profile digest: `dd8dc7dd48d36db6`.
- Task digest: `c3228a785940b2a5`.
- Local Docker backend; one attempt per agent; official task and grading
  configuration unchanged. The oracle duration includes the first build.

The model label in the result files is inherited from upstream configuration.
It does not indicate a model call: oracle and nop bypass model inference.
No model endpoint, API credentials, GPU rental, or training was used.

## Raw evidence

- Oracle: `runs/validation-oracle/gpt-5.6-luna/at-announce-once__UhAaS4f/`
- No-op: `runs/validation-nop/gpt-5.6-luna/at-announce-once__mAiyssk/`

Each directory contains `result.json`, `checks.json`, and `verifier.log`.
They remain local and ignored by Git. Reproduce with
`bash bin/validate-benchmark` from the project root.

## What this establishes

The harness can build the app, apply the reference fix, and distinguish the
fixed and unchanged versions using the official grader on this machine.
It does not validate every benchmark task or establish leaderboard parity.
The image uses upstream dependency resolution; its recorded image ID matters
because a later rebuild can resolve different dependencies.

Next: agree on the initial model and hosting, verify its connection to
miniswen using a separate smoke task, then define the scope and budget for
an official baseline. Before comparing with published scores, check the
specific published run versions and settings, including hardware and limits.
