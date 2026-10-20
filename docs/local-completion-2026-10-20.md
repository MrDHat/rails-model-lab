# Completed local Qwen development attempt

Fresh run `runs/mlx-development-tPLUuK`, trial
`team-ticket-boundary__2YVMQfD`, completed with reward **1.0** and agent status
`submitted`. The completion sentinel was issued at step 24; the harness stores
an empty submission body. Restored starter tests passed 3 tests / 12 assertions;
hidden verification passed 18 tests / 74 assertions. This is one development
task result, separate from the official benchmark and from Colab float16.

## Frozen configuration and evidence

Source revision: `5b80a89`, with an empty working-tree diff. All 28 frozen
benchmark file hashes were verified after the run. The model remains
`mlx-community/Qwen3.5-4B-4bit` revision
`0e7ffd5c629ef7719d4cbc04069232580bfa9d9c`, with the existing model-file hash
manifest and pinned local dependency lock. Its upstream base revision is
unknown. There were no adapters or training updates.

Settings were unchanged: 32 steps, 16,384 input / 2,048 output tokens per
request, prefill 1,024, greedy decoding, thinking disabled, EOS 248046,
30-minute agent limit, 600-second response limit and 60-second command timeout.
The new process-scoped idle-sleep assertion was observed while running and
was absent after exit. It does not prevent lid-closed sleep.

All 24 requests generated responses and consumption receipts. Usage:
101,101 input / 3,713 output tokens, 767.26 generation seconds, 797.5 seconds
harness duration, peak unified memory allocation 3.652 GiB. There were no
expired, late, truncated or runtime-error responses. All inference ran on the
Mac. Hidden graders and reference solutions were not provided to the model.
No operator code corrections, hints or tool-call repairs were applied.

The model scoped ticket lists, checked ownership before reads and updates, and
removed ownership from permitted update parameters. It also spent steps on
extra test scripts with incorrect `/testbed` paths. Preserve the complete
trajectory, generated patch (including incidental test log changes), final
checks and result under the run directory; these are not training data.

## Interpretation and next step

This establishes a complete scored local development attempt through the
existing lemans 1.5.2 harness and miniswen agent. It does not establish broad
model quality, a training improvement, or Colab transport reliability. Keep
all previous failed attempts and their original outcomes, including the fresh
sleep-interrupted attempt recorded separately.

Stop expanding development infrastructure. Next, execute the previously frozen
three-task official baseline protocol using the existing harness, official
graders and local inference adapter. No additional development tasks, harness
replacement, Colab repair or training phase is needed for that step. All three
official model tasks remain not run at this checkpoint.
