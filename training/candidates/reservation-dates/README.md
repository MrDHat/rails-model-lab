# Validate reservation dates on creation and update

**Pending user review. No training or dataset export is authorized.**

This is one independently authored candidate exercise, separate from the
official baseline and its held-out evaluations. It is a small model-level
exercise, not an end-to-end application or a claim about agent performance.

Read `request.md`, then compare `starter.rb` with `reference.rb`.
`verification_test.rb` checks observable behavior; `mutation.rb` is a plausible
incorrect fix that those checks must reject. The starter must fail and the
reference must pass. Tests and mutation are review material, not proposed
training targets or held-out evaluation material.

Validate presence first, guard missing typed dates, and check ordering on every validation. The update case rejects a create-only fix.

## Reproduce

In a Ruby environment with Active Record, Active Support, sqlite3 and minitest:

```sh
ruby verification_test.rb --seed 1
CANDIDATE_IMPLEMENTATION=starter.rb ruby verification_test.rb --seed 1
CANDIDATE_IMPLEMENTATION=mutation.rb ruby verification_test.rb --seed 1
```

The first command must pass. The other two must fail. The suite creates only
an in-memory SQLite database and does not boot a Rails application or use the
network. Local authoring validation uses the existing cached Rails runtime;
its exact image ID and outputs are retained locally. Only that runtime is
validated; no compatibility with every Rails release is implied.

If the user later approves this candidate and explicitly authorizes training,
the proposed pair is request + starter as input and reference implementation
as target. There is no export or training entry point in this PR. Reviewers
should assess realism, requirement coverage and whether the correction teaches
a reusable behavior rather than a benchmark-specific answer.

## Provenance

The scenario, tests and code were newly authored using these public API
references; documentation examples were not imported as dataset records:

- https://guides.rubyonrails.org/active_record_validations.html

No official benchmark content or run outputs are included. See
`provenance.json` for the proposed data boundary and contamination limitations.

## Authoring validation

Reference: 7 tests, 12 assertions, no failures, errors or skips.
The broken starter and the plausible mutation both failed the same suite.
Seed: 1. Full runtime identity and counts are recorded in `provenance.json`.
