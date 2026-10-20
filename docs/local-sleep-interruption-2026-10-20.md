# Local attempt interrupted by host sleep

Fresh attempt `runs/mlx-development-BMwrom`, trial
`team-ticket-boundary__O6MFMcm`, used clean revision `733b673` and the validated
new development grader. All 28 frozen benchmark file hashes still match.
Six responses were generated and consumed: 10,501 input / 266 output tokens,
70.83 generation seconds, peak unified memory allocation 3.277 GiB. There were
no recorded truncations or model runtime exceptions.

Request 7 was created at 16:50:47.951973 UTC and expired at 17:00:47.951973 UTC.
The macOS power log records maintenance sleep at 17:50:49 Dublin (16:50:49 UTC),
then a brief lid wake at 17:55:05, clamshell sleep at 17:55:10, and a lid wake at
18:02:31. Sleep therefore overlapped the request and its deadline. The harness
ended `agent_error`, unscored, after 781.6 seconds. No hidden grading or submission
occurred; no late result was consumed. Preserve this attempt unchanged.
Evidence: `summary.json`, `worker.log`, expired request marker, result and
`power-events.txt` within the run directory.

The macOS runner now uses `caffeinate -i` for its own process tree, releasing the
idle-sleep assertion when it exits. This changes no system power settings and
cannot prevent lid-closed sleep. Further local evaluations need the lid open.
No inference budgets, deadlines, model pins or grading settings change.
