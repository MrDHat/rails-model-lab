# Baseline infrastructure diagnosis

The baseline remains incomplete. No new scored task, inference call, regrading or training was launched during this diagnosis. Original results and the 135-identity manifest remain unchanged.

## Confirmed namespace incompatibility

An offline disposable container reproduced the retained `unshare: pidfd_open failed: Function not implemented` error using the namespace command from lemans 1.5.1. The failing task image is amd64; this Docker host is ARM64. An existing ARM64 image passes the identical command. Both images use util-linux 2.41, which rules out a version difference between these two probes.

This establishes a compatibility failure on the emulated-image path. It does not establish that all setup failures have that cause. The pinned SaaS task base image cannot simply be replaced with an unrelated ARM image: that would change the benchmark environment. A compatible native x86 environment or a separately validated runtime repair is still needed for that image.

`experiments/check-local-jail.py` repeats this narrow probe using existing images only, with no network and no model or task inputs. It is not a full agent-jail or verifier validation.

## Local sleep and remote lifecycle

The local power log records clamshell sleep at 01:20:35 UTC despite an active caffeinate assertion. The remote log records cancellation at 01:22:37 and says the local client disconnected. The first subsequent local heartbeat failure was logged at 01:34:18, shortly after a dark wake.

This timing strongly supports laptop suspension interrupting the client heartbeat. It is not a reproduction of Modal's server-side disconnect decision. [Modal documents](https://modal.com/docs/guide/apps) that an attached ephemeral app stops when the client disconnects; [detached runs](https://modal.com/docs/cli/latest/run) survive client disconnection. Detaching inference alone would not keep a local benchmark harness executing while its host sleeps.

The prospective controller now requests detached mode and explicitly stops its exact app after started trials settle, recording the stop command's outcome and flagging any stop failure in the completion event. The existing independent remote absolute deadline remains unchanged. Simulated lifecycle tests cover detached selection, explicit shutdown after a shared fault, and reporting a failed shutdown. These prove controller behavior, not long-lived remote reliability: no remote disconnect/shutdown validation has run for this change. Local harness suspension remains unresolved.

## Disk admission fix

The controller previously checked free disk only after remote startup. It now requires the existing 12 GiB minimum before importing remote compute, while retaining the per-wave check. A regression test failed before this fix by reaching the compute-import seam, then passed. All nine controller lifecycle tests and six budget tests pass. Test disk availability is supplied explicitly, independent of the developer laptop.

At diagnosis the laptop had about 2.1 GiB free. Unrelated Docker workloads are active and were left untouched. This remains a launch blocker.

## Replacement policy and remaining work

The user explicitly authorized replacing infrastructure-invalid attempts after validation. Every original record must remain available; replacements must be reported separately and linked to the original identity. Scored model failures must never be retried. Classification and replacement selection must be based on infrastructure evidence, not model performance. No replacement has been launched or silently selected by this change.

Next gates are sufficient disk, compatible sandbox execution, a transport lifecycle that survives the intended host behavior, synthetic validation of that complete path, and fresh verification of free-credit allowance. The $0 paid-spending constraint and $25 workspace usage ceiling remain unchanged. Full baseline completion and a leaderboard score remain unproven.
