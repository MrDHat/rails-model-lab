# Modal Qwen full-corpus baseline — 2026-10-28 launch checkpoint

## Coverage at validation callback

The detached controller passed its setup gates and started the first task, `at-announce-once`. At the callback snapshot, 0/46 tasks had completed, one attempt had started, and 45 were unstarted. No benchmark score is available at this checkpoint.

The pinned corpus contains 19 atomic, 20 feature, and seven multistep tasks, excluding the auxiliary Rust task. This experiment plans one fresh attempt per task. It is not an exact reproduction of the website's multiple-attempt leaderboard protocol. Completion coverage and every scored/unscored outcome, reward, and credit will be reported from original harness results. Historical MLX results remain a separate experiment.

## Frozen protocol

- Benchmark revision: `f587d5a44897f3467af2a48c0503aef4eb6acf55`.
- Original model: `Qwen/Qwen3.5-4B`, revision `851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a`, BF16.
- One NVIDIA A10; vLLM 0.32.0; native context allowance 262,144; output allowance 32,768.
- Thinking enabled; temperature 0.6, top-p 0.95, top-k 20, repetition penalty 1.0, presence penalty 0, seed 42.
- Existing lemans 1.5.2 / Miniswen, Docker environments, task-specific time/step/command/session/verifier limits.
- Placement deviation: tasks configured for installed Miniswen use the upstream host adapter, allowing private Modal RPC inference through a loopback OpenAI transport. Prompts, tools, agent loop, environments and verifiers remain upstream.
- One sequential attempt, no inference overlap, request retries disabled, no silent reruns or regrading.

## Validation and provenance

The synthetic native-context probe passed at 98,286 prompt tokens. A real upstream Miniswen agent then completed a two-turn tool-result exchange through the private transport. Its synthetic outcome was `step_limit` at two steps, not a solved benchmark task.

A previous setup gate rejected Qwen's second exploratory command because it incorrectly demanded immediate synthetic submission. That failed setup is preserved locally. The amended gate records commands without executing them and validates transport rather than task-solving behaviour. No scored task had started before the correction.

Verified at launch: all 723 frozen benchmark-input hashes, 12 model-file hashes against the earlier successful preflight, and five frozen controller/transport source hashes. Remote metadata attests the deployed inference module against the local frozen source.

Input-manifest SHA256: `74992aa2012a93851c639c2e2f8bf003186ebbe07805ea380120cbb33dc06ab8`.

Frozen local source SHA256:

| File | SHA256 |
| --- | --- |
| modal_inference.py | be8a55ed23d9164a2640856ce3f8fd5c7c3eba1be44fd30f66ceb848c82478f5 |
| modal_bridge.py | f9f262141cb030a0408e5e50854145b0f7852003cfb0b91d4144371962ba3f74 |
| modal-provider.rb | 87f26e27732f3f644f2fbb10e0d74f683f97529657298cf0fa2ab03da82c60d5 |
| run_full_baseline.py | fb5d15c66b36ecbffd4123e2a049ea20024b7f0fe200f35d8f63b866c3c57a13 |
| agent-preflight.rb | 179321329311bf034c5cdd1b95ed39cfe693ba9e4081228e03d2a53d9d954263 |

## Credit and evidence boundaries

Workspace controls remain $25 usage ceiling and $0 net spend, free credits only. The controller has a conservative 16-hour wall allowance estimated at at most $24 for this batch's configured resources, excluding prior setup usage; workspace limits are the outer guard. It reserves each task's complete declared allowance before starting it, and stops safely if time, disk, provider or environment prevents continuation. The full corpus may not fit this credit cycle; unfinished tasks remain explicitly unstarted. An attempted task is never retried.

Harness per-token API cost is zero; actual Modal GPU/CPU/RAM credit consumption is separate and must not be reported as zero compute cost.

Only model-visible inference requests cross the private RPC boundary. No persistent volume or public endpoint is created. Hidden graders, reference solutions and raw evidence remain local. All benchmark material stays out of training. Training, purchases, merges and access expansion are not authorized.

Completion/failure delivery uses a direct callback from the detached controller, without scheduled or in-context polling.
