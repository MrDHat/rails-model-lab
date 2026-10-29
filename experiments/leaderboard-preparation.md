# Prospective Rails leaderboard comparison

Preparation only: the prior single-attempt Modal batch is stopped. These files do not launch inference or a benchmark. See [the protocol audit](../docs/leaderboard-protocol-parity-2026-10-29.md) for the 135-attempt schedule, historical differences and unresolved free-compute requirement.

## Validate without a GPU

Use Ruby 3.4 and Bundler 2.6.2, with Docker running. From the repository root:

```sh
BUNDLE_GEMFILE=$PWD/experiments/leaderboard.Gemfile bundle install
python3 experiments/test-leaderboard-report.py
BUNDLE_GEMFILE=$PWD/experiments/leaderboard.Gemfile bundle exec ruby experiments/test-installed-modal-transport.rb
python3 experiments/test-concurrent-modal-transport.py
```

The Docker integration test uses an already cached `lemans-a437e71aa43bc751abd5bed6d6741ff8:latest` image and installs the official Miniswen gem in an ephemeral container. The image must exist locally; it is a test fixture, not a frozen benchmark environment. The test sends only synthetic instructions to a fake provider. It checks actual installed-agent tool calls, the jail, inference environment isolation and zero published ports, then removes its container. Gem installation needs the existing task setup network access; no GPU is called.

The concurrent integration starts four separate upstream installed agents and Docker sandboxes through `concurrent-modal-bridge.py`. A fake provider holds their first requests at a four-party barrier: a serial bridge cannot pass. Each agent writes and reads an identity marker at the same sandbox-relative filename; both provider observations and sandbox files must match that agent. Eight request/response evidence pairs must remain separate. Admission checks also verify authentication, frozen settings, an expired deadline and immediate overload rejection. This test passed with four overlapping provider calls, four isolated markers, eight completions, zero published ports and zero GPU calls. It uses the real installed adapter and host bridge, but replaces Modal RPC/model inference with a fake callable; it does not establish live Modal concurrency or long-context performance.

## Transport boundary

`installed-modal-transport.rb` prepends only the upstream installed adapter. A sandbox-loopback HTTP listener outside the command jail forwards JSON requests over `docker exec` stdio to the existing host-loopback bridge. Modal credentials remain on the host. The sandbox receives only a disposable relay token; task commands do not inherit inference environment variables. Original task command policies and network allowlists stay in place. The provider bootstrap disables retries and declares a 1560-second request timeout.

This adapter is not a new agent loop. Preserve each task's selected host/installed adapter and original limits; never globally override the agent. Real Modal/Qwen compatibility with this installed transport still needs a synthetic preflight before scored attempts. Loading the Ruby adapter alone does not provide a Modal bridge or launch controller.

`concurrent-modal-bridge.py` is a separate prospective bridge, leaving the original frozen serial bridge unchanged. It accepts an already-owned provider handle with `complete.remote(payload)`, binds only to host loopback and writes separate evidence files per request. It admits at most four inference calls and rejects overflow immediately, without retries or hidden queue time. Deadline admission does not cancel an in-flight provider call; independent provider/app shutdown limits remain required. Each agent's sandbox relay stays sequential because its own agent loop is sequential; separate relays overlap across agents. The live provider still needs concurrent Modal inputs, four vLLM sequences, an independent budget stop and real-provider validation before benchmark use.

## Bounded real-provider synthetic integration

The explicitly authorized `concurrent-qwen-preflight.py` was launched separately on 2026-10-29. It sends four invented two-command marker tasks through the actual installed adapters, independent Docker relays, concurrent host bridge and private Modal RPC to Qwen. The fixture permits at most four steps and 180 seconds per agent; these are synthetic diagnostic limits, not changes to Rails task limits. Generation settings retain thinking, temperature .6, top-p .95, top-k 20, seed 42 and the original 32,768 output cap. All source inputs/settings are frozen locally before the first call. The private provider recomputes the original model hashes and the client verifies its source/model manifest before starting agents.

The new provider enables four concurrent Modal inputs and four vLLM sequences on a single A10, using the previously validated eager image. No public endpoint, persistent volume or benchmark material is used. Independent bounds are a 600-second remote container watchdog, 210-second method timeout, 300-second startup timeout and 900-second local deadline, with zero configured retries. A long idle window avoids unintended cold starts between metadata validation and agent setup; the watchdog includes idle time and app-context exit stops the app. This single-use preflight is bounded to an operational allowance under $1 of free credit; the existing $0 paid-spend and $25 workspace ceiling remain mandatory.

Original per-agent results, HTTP request/response evidence, remote timing/container identities, model metadata and event delivery stay under `runs/concurrent-qwen-preflight-20261029/`. A direct callback reports completion or failure; no scheduled or in-context status polling is needed. A failed preflight is retained, never silently rerun. This launch is not a passing result or a scored-benchmark authorization.

### First live integration: import failure retained

The original attempt failed before model startup or agent creation. The source was uploaded as `/root/concurrent-qwen-provider.py`, but Modal imports `concurrent_qwen_provider`; `include_source=False` meant no importable module was supplied. Modal repeatedly failed container imports despite method retries being zero. The remote watchdog never started because its class entry hook was never reached. The independent 900-second local deadline stopped app `ap-rq5zqKbgCYDO09SNwk5EqV` at 2026-10-29 17:35:08 UTC. It was verified stopped with zero tasks; Docker was empty. No metadata, model-hash verification, inference response or per-agent outcome exists. This is an infrastructure failure, not a Qwen failure or passing integration. All seven frozen local source hashes matched; copies, logs and event remain in that original run directory. Actual billed usage has not been reconciled.

The explicitly disclosed corrected attempt uses a new `runs/concurrent-qwen-preflight-20261029-packaging-fix/` directory, never overwriting or reclassifying the first attempt. The module now has its correct Python filename and explicit `/root` import path. A CPU-only function must import that same module and return the expected source hash within a 60-second call wait before any GPU method is invoked. GPU startup metadata then has a separate 300-second call wait. Existing app lifetime/model/generation/agent limits and spending controls remain in place. These guards address the observed import crash loop; local import success alone is not remote validation.

## Reporting

```sh
python3 experiments/leaderboard-report.py /path/to/frozen-plan.json /path/to/new-trials > /path/to/report.json
```

The plan supplies `attempts`, a list of objects containing `task`, plus optional exact `model` validation. Use only a new experiment's original result files, with frozen configuration verified separately. The reporter rejects extra/duplicate trials and mixed model names; it cannot prove hashes or detect different settings under the same model name. It preserves reward and fractional credit separately, including absent values for unscored attempts. Complete headline accuracy is the equal-weight average of task mean credit. Missing or unscored attempts suppress that headline. Do not fold historical MLX or stopped host-only Modal results into the new configuration. Time/step/cost leaderboard summaries and actual GPU billing reconciliation remain separate work.

There is no launch authorization or claim of exact historical environment identity in this directory. The full run remains gated on enough free compute, real-provider validation and final frozen provenance. $0 paid spending remains mandatory.
