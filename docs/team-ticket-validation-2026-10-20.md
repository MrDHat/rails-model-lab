# Team ticket evaluation validation — 20 October 2026

The second independent development evaluation is runnable and validated.
It covers team-specific listing, reading, editing and immutable ownership
through HTTP behavior. Its separate starter does not alter the expense task.
This is grader validation without a model, not evidence of model ability.

The final no-model harness checks completed:

| Agent | Outcome | Reward | Model tokens |
| --- | --- | --- | --- |
| oracle | completed | 1.0 | 0 |
| nop | completed | 0.0 | 0 |

Evidence: `runs/development-validation-ZAkYuT`. The reference passes 18 hidden
tests with 74 assertions and three visible baseline tests with 12 assertions.

`bin/validate-team-ticket-mutations` also checked the unchanged app, reference
and six incomplete fixes in fresh containers with networking disabled. All
eight variants behaved as expected: only the reference passed. The grader
rejects list-only fixes, unscoped updates, writable ownership, unscoped lists,
unscoped shows and caller-selected list teams. Evidence and source hashes:
`runs/team-ticket-mutations/summary.json` and `source-sha256.json`.

The initial reference check failed because the GET query fixture did not reach
the intended route. The fixture now encodes the query in the URL. A fresh
oracle/nop run and the full mutation matrix passed after that correction.
The failed initial check remains in `runs/development-validation-xL3KBx`.

The first two build attempts stalled while the Docker Desktop credential helper
resolved a public base image. They were stopped after replacement runs began.
An isolated temporary Docker config with no account credentials pulled the
same pinned public Ruby digest and built successfully. The config points to
the existing local Docker socket and installed CLI plugins; the user's Docker
configuration and account credentials were not changed. The temporary config
is ignored under `runs/docker-public-registry-config`.

The user explicitly approved including the grader, reference patch, detailed
design and mutation validator in the GitHub checkpoint. These repository
review files remain excluded from the model starter and Colab request stream.
The validation command fails early if the grader or reference patch is absent.

Reproduce with:

```sh
bash bin/validate-development evals/development-team-tickets team-ticket-boundary
python3 bin/validate-team-ticket-mutations
```

If the credential helper stalls again, use the preserved isolated config via
DOCKER_CONFIG and the existing local socket via DOCKER_HOST. Do not copy
credentials into it. The committed Dockerfile still pins the original Ruby
image digest and dependency lock; it does not depend on a locally tagged image.

No model attempt, official benchmark score, or training run was added here.
The grader/reference remain outside the model's starter workspace. Evaluation
material and attempt evidence must not enter training data.
