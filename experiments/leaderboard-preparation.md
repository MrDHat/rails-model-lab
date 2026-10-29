# Prospective Rails leaderboard comparison

Preparation only: the prior single-attempt Modal batch is stopped. These files do not launch inference or a benchmark. See [the protocol audit](../docs/leaderboard-protocol-parity-2026-10-29.md) for the 135-attempt schedule, historical differences and unresolved free-compute requirement.

## Validate without a GPU

Use Ruby 3.4 and Bundler 2.6.2, with Docker running. From the repository root:

```sh
BUNDLE_GEMFILE=$PWD/experiments/leaderboard.Gemfile bundle install
python3 experiments/test-leaderboard-report.py
BUNDLE_GEMFILE=$PWD/experiments/leaderboard.Gemfile bundle exec ruby experiments/test-installed-modal-transport.rb
```

The Docker integration test uses an already cached `lemans-a437e71aa43bc751abd5bed6d6741ff8:latest` image and installs the official Miniswen gem in an ephemeral container. The image must exist locally; it is a test fixture, not a frozen benchmark environment. The test sends only synthetic instructions to a fake provider. It checks actual installed-agent tool calls, the jail, inference environment isolation and zero published ports, then removes its container. Gem installation needs the existing task setup network access; no GPU is called.

## Transport boundary

`installed-modal-transport.rb` prepends only the upstream installed adapter. A sandbox-loopback HTTP listener outside the command jail forwards JSON requests over `docker exec` stdio to the existing host-loopback bridge. Modal credentials remain on the host. The sandbox receives only a disposable relay token; task commands do not inherit inference environment variables. Original task command policies and network allowlists stay in place. The provider bootstrap disables retries and declares a 1560-second request timeout.

This adapter is not a new agent loop. Preserve each task's selected host/installed adapter and original limits; never globally override the agent. Real Modal/Qwen compatibility with this installed transport still needs a synthetic preflight before scored attempts. Loading the Ruby adapter alone does not provide a Modal bridge or launch controller.

## Reporting

```sh
python3 experiments/leaderboard-report.py /path/to/frozen-plan.json /path/to/new-trials > /path/to/report.json
```

The plan supplies `attempts`, a list of objects containing `task`, plus optional exact `model` validation. Use only a new experiment's original result files, with frozen configuration verified separately. The reporter rejects extra/duplicate trials and mixed model names; it cannot prove hashes or detect different settings under the same model name. It preserves reward and fractional credit separately, including absent values for unscored attempts. Complete headline accuracy is the equal-weight average of task mean credit. Missing or unscored attempts suppress that headline. Do not fold historical MLX or stopped host-only Modal results into the new configuration. Time/step/cost leaderboard summaries and actual GPU billing reconciliation remain separate work.

There is no launch authorization or claim of exact historical environment identity in this directory. The full run remains gated on enough free compute, real-provider validation and final frozen provenance. $0 paid spending remains mandatory.
