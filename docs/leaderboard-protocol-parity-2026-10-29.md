# Matching the Rails leaderboard protocol — 2026-10-29

This is a protocol audit, not a claim that the Modal batch is an exact leaderboard reproduction. No active attempt was changed, restarted, regraded or stopped by this research subtask. During the audit, the user explicitly requested stopping the current benchmark to avoid further spending; the coordinating agent reported stopping its local process group and Modal app, verifying zero Modal tasks and no running Docker containers. No benchmark launch is authorized by this document. No hidden graders or reference solutions were inspected.

## Confirmed target

The [official Stage 3 report](https://rubyonrails.org/2026/10/13/agents-on-rails-stage-3) specifies **135 scored runs per model configuration**: three attempts on 43 tasks and two attempts on `ms-greenfield-helpdesk`, `ms-redmine-rails-upgrade` and `ms-retire-proposals`. This is 57 atomic attempts, 60 feature attempts and 18 multistep attempts, across 46 equally weighted tasks. Each multistep attempt includes all its sessions, subject to the intermediate gates; sessions are not independent leaderboard attempts.

The [official leaderboard methodology](https://rubyonrails.org/ai) averages fractional scores within each task, then averages the task means. It does not select the best attempt. Its headline accuracy is `100 * mean(task mean credit)`; binary all-checks-passed reward must also be retained, but is not a substitute for this metric. Time, steps, tokens and cost likewise need equal task weighting. The published sweep reports no invalid runs; an unscored provider interruption is not a scored zero and cannot establish complete 135-scored-run coverage.

The [pinned methodology](https://github.com/rails/ai-evals/blob/f587d5a44897f3467af2a48c0503aef4eb6acf55/methodology.md), verified against the local clean checkout at that revision, gives these additional requirements:

- Existing lemans/Miniswen loop, prompt and single bash tool; task Docker app environments contain no benchmark machinery.
- Task-specific time, steps, cost, command, build and verifier limits. Preserve overrides rather than using one global limit. The defaults are 90 minutes, 400 steps, $60 per run; some tasks differ materially.
- Original preverification, restoration rules, deterministic checks and optional-check weights. An intermediate multistep gate failure terminates that attempt with zero credit. Fresh conversation for each ticket, while files/notes persist within the attempt.
- Original sandbox resource, placement and network declarations, including RubyGems access where explicitly permitted. No extra tools, hints, solution material or benchmark data in training.

## Known differences in the current Modal batch

The frozen local configuration is `runs/full-baseline-20261026/frozen-configuration.json`; the controller invokes `--attempts 1 --concurrency 1 --agent miniswen --backend docker --max_output_tokens 32768`.

| Dimension | Current Modal batch | Parity requirement |
| --- | --- | --- |
| Repetition | One attempt per task | Frozen 3/2 schedule above, independent attempt identities and clean start per attempt |
| Agent placement | Global host `miniswen` override | Preserve task-selected `miniswen-installed` versus `miniswen` |
| Inference | Private Modal RPC through a loopback OpenAI bridge | Model-specific inference is expected, but must be declared and validated; it must not change the agent/environment contract |
| Generation | Thinking on, temperature .6, top-p .95, top-k 20, seed 42; 32,768 output cap | Declare Qwen configuration prospectively; upstream does not specify a universal temperature/output cap for all models |
| Budget | Shared free-credit and 16-hour batch boundary | Monetary user guard remains mandatory, but a partial run is not a completed leaderboard-equivalent measurement |
| Token API cost | Zero in harness; Modal compute external | Reconcile actual compute separately; never compare zero token fee with paid-provider cost as if GPU were free |
| Harness | Installed lemans/Miniswen 1.5.2 | Published atomic/features used 1.5.1; multistep metadata contains 1.4.0, 1.5.0 and 1.5.1. Our build differs |

The host placement difference is concrete, not just naming. The installed adapter executes the Miniswen CLI in the task sandbox with a jail, passes the task's allowed model hosts and installs the matching Miniswen version during setup. Some multistep configs deliberately choose the host adapter because the installed jail would prevent app dependencies or sandbox-local database access. See the [upstream adapter](https://github.com/rails/lemans/blob/main/lib/lemans/agents/miniswen_installed.rb) and [task configs](https://github.com/rails/ai-evals/tree/f587d5a44897f3467af2a48c0503aef4eb6acf55/tasks). A global adapter override therefore cannot be called exact task-config parity even when the underlying loop matches.

## Public run metadata audit

Read-only `git cat-file --batch` inspection of **only public `result.json`** objects in the three October 6 run directories at the pinned local tree confirmed the article's schedule across all 11 configurations. No `agent.result.json`, trajectory, patch, hidden checks, verifier log or other evidence content was read for this audit. No vendor checkout files were changed.

| Published stage | Public results | Recorded lemans versions | Recorded adapter |
| --- | --- | --- | --- |
| [Atomic](https://github.com/rails/ai-evals/tree/f587d5a44897f3467af2a48c0503aef4eb6acf55/runs/2026-10-06-atomic-tasks-revamped) | 627 = 11 × 19 × 3 | 1.5.1: 627 | miniswen-installed: 627 |
| [Feature](https://github.com/rails/ai-evals/tree/f587d5a44897f3467af2a48c0503aef4eb6acf55/runs/2026-10-06-feature-tasks-revamped) | 660 = 11 × 20 × 3 | 1.5.1: 660 | miniswen-installed: 660 |
| [Multistep](https://github.com/rails/ai-evals/tree/f587d5a44897f3467af2a48c0503aef4eb6acf55/runs/2026-10-06-multistep-tasks) | 198 = 11 × 18 | 1.5.0: 89; 1.5.1: 106; 1.4.0: 3 | miniswen: 109; miniswen-installed: 89 |

All 1,485 outcome objects have `scored: true`. Every model configuration has exactly 135 task attempts: 43 tasks appear three times, and the same named three multistep tasks appear twice. The atomic and feature records all have profile digest `4963d01dcd0f49b8` and revision `3c523253c35d59f8de65b6f51fe6a23135ee52a9`, marked clean. For example, [this public atomic result](https://github.com/rails/ai-evals/blob/f587d5a44897f3467af2a48c0503aef4eb6acf55/runs/2026-10-06-atomic-tasks-revamped/gpt-6.1-sol-xhigh/at-announce-once__67o90oE/result.json) records lemans 1.5.1, installed placement, reward 1.0 and credit 0.1. That example independently illustrates why reward is not the headline credit metric.

The multistep metadata is heterogeneous even within a task:

| Task | Recorded lemans versions (attempt counts) | Profile digests (attempt counts) |
| --- | --- | --- |
| ms-campfire-bots | 1.5.0 (26), 1.5.1 (7) | 9a060290183dbfc2 (31), 0f5270701e36531b (2) |
| ms-forem-active-storage | 1.5.0 (33) | cec4391ff2e24851 (33) |
| ms-greenfield-helpdesk | 1.4.0 (3), 1.5.0 (8), 1.5.1 (11) | 03c022f8c568790a (5), 74598927a3a288e3 (16), b12ef30f3940d648 (1) |
| ms-greenfield-quizzy | 1.5.1 (33) | 8fc28a7c793a127b (33) |
| ms-mastodon-tests | 1.5.1 (33) | b9cf9e34fa8fd21e (23), d9c6206bb943e3e5 (5), cb6c1d0277fb4340 (2), c4f3fd8dc165caf0 (3) |
| ms-redmine-rails-upgrade | 1.5.1 (22) | 2bb28dda8acb17dd (22) |
| ms-retire-proposals | 1.5.0 (22) | ad585ab4795bec06 (18), 183d3d070e5730ed (4) |

Forem's records contain 23 installed and 10 host attempts; the pinned present task config deliberately selects host placement. Other multistep tasks' recorded placements agree by task with the pinned placement. These are provenance facts, not an assertion that the historical runs were invalid. A digest alone does not recover its full original config or explain why it differs. The published sweep itself therefore has no single uniform historical harness version/profile to copy blindly. A prospective comparable Qwen run needs one explicit reconciled target, with changes from historical metadata disclosed.

## Facts that remain unresolved

1. **Exact historical dependency/environment build.** Public results now establish actual lemans versions and profile/task digests. They do not provide a complete dependency lock, original effective config for every distinct digest, image digest, host architecture or provider revision. Local 1.5.2 is demonstrably newer than the recorded published builds. The current pinned corpus uses a different revision from the common atomic/feature recorded revision. That historical object is not present in the local object database (`git diff` reports `bad object`), so this read-only audit could not compare its effective configs. Recover/check those configs and relevant version changes before claiming exact historical identity.
2. **Provider generation defaults.** Upstream Miniswen passes `temperature: nil`, and the local bench profile leaves `max_output_tokens` unset (zero means provider default). This is visible in the local installed source and [upstream agent](https://github.com/rails/lemans/blob/main/lib/miniswen/agent.rb). The report explicitly varies reasoning effort by model. There is no one shared model-independent temperature/context cap to copy. Qwen needs a declared model configuration; changing it creates a separate experiment.
3. **Real-provider installed-agent validation.** A new transport prototype now passes a synthetic two-tool-call integration through the upstream 1.5.1 installed adapter and its real Docker jail. A loopback relay outside the command jail carries inference over Docker stdio to the existing host bridge. No ports are published, the task allowlist stays unchanged, and inference environment variables are absent inside task commands. Modal credentials stay on the host. This is a fake-provider test with zero GPU calls; actual Qwen/Modal end-to-end validation remains pending. The provider bootstrap explicitly disables retries and sets a request timeout; these are declared configuration choices, not historical defaults.
4. **135 attempts within free credit.** This has not been demonstrated. The $25 workspace ceiling/$0 net spend are hard user constraints. More attempts are statistically meaningful, but increasing repetitions does not make time/compute free. Full matching coverage must remain conditional on available credits, without shortening individual task budgets or spending paid money.

## Smallest defensible change plan

1. Preserve the stopped single-attempt batch as a separate preliminary experiment. Do not silently combine its host-adapter attempts with a new placement/configuration in one score. Preserve every attempted trial and its exact scored/unscored status, reward and credit.
2. Freeze a new explicit 135-attempt manifest, the reconciled benchmark revision, per-task configuration, selected model revision/precision/reasoning and generation settings, harness/dependency versions and environment provenance before new attempts start. Enumerate attempts 1–3, except the three named two-attempt tasks. Never replace an attempt based on its score.
3. Resolve and synthetically test installed-agent private connectivity without benchmark examples, hidden files or reference fixes. Preserve task-selected adapters and sandbox networking. If this needs a permission/access change, it is a real unresolved constraint, not exact parity already achieved.
4. Calculate the resource allowance prospectively and retain a deterministic stop-before-next-attempt credit guard, independent of a future Codex turn. A budget stop means incomplete coverage, not a smaller claimed full benchmark.
5. Use the original verifiers once per attempt. Publish per-task attempted/scored/unscored counts and both reward and credit. Compute the equal-task credit average only with an explicitly stated coverage/invalid-run policy. A complete official-style 135-scored-run comparison also requires a prospective infrastructure-failure policy; the current no-rerun rule cannot be silently relaxed.

The confirmed 135-run schedule and scoring can be matched. The current setup must not be described as **exactly identical** until placement/connectivity and historical provenance differences are reconciled. A transparent comparable reproduction is feasible in principle; a guaranteed full reproduction on remaining free credits is not established.

## Preparation checkpoint

The separate `experiments/leaderboard.Gemfile.lock` pins lemans/Miniswen 1.5.1 without changing the original experiment lock. Its newly resolved transitive dependencies are not asserted to reproduce the unpublished historical lock. The pinned current task profiles select 42 installed adapters and four host adapters; no global adapter override belongs in a future launch. A local preparation manifest enumerates all 135 attempts, but no new scored attempt has started.

The synthetic installed-agent integration passed with two steps, two requests, an active jail, zero published ports and zero GPU calls. Six synthetic reporter tests cover equal task weighting, fractional credit rather than binary reward, incomplete/unscored coverage, duplicate/extra trials, and mixed/unexpected models. The reporter never runs inference or a verifier and suppresses a full headline while any planned scored attempt is missing.

### Free-credit feasibility

[Modal pricing](https://modal.com/pricing) lists A10 at $0.000306/s, physical CPU cores at $0.0000131/s and RAM at $0.00000222/GiB/s. The configured A10, two physical CPU cores and 16 GiB give a resource-rate ceiling of $1.323792/hour. At the single scored attempt's observed 5407.1-second pace, 135 attempts would represent 202.77 GPU-hours, about **$268.42 at that rate**. This is a one-task scenario, not a forecast, minimum, invoice or confidence interval; other task types, gates and overhead can change it substantially. Declared session allowances total 309 hours before setup/verification overhead.

This provides no defensible basis for promising completion on the remaining free credits. The old $25.98 credit observation is stale and is not a current balance. The [workspace budget controls](https://modal.com/docs/guide/budgets) remain a $25 usage ceiling and $0 net spend. The scored benchmark stays stopped; no GPU preflight or new launcher is activated by this checkpoint. Next is securing sufficient free compute or establishing a credibly affordable inference route, then validating the real provider and freezing the final configuration before any attempt. Do not shorten task limits or silently substitute a partial score.
