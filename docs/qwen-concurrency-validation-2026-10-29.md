# Qwen concurrent transport validation

The corrected synthetic integration passed with Qwen3.5-4B: four isolated installed agents each submitted after two real bash-tool calls. Eight responses completed with four overlapping provider calls in one GPU container, no provider errors, and separate sandbox markers. The upstream installed adapter, command jail, sandbox relay and host bridge were exercised together. Frozen model and source hashes matched, and the application and test containers were verified stopped afterward.

The preceding attempt failed before inference because the packaged provider filename did not match its Python module name. Its failed outcome is retained separately. The corrected attempt first validated the import and source hash on CPU before allowing a GPU call. Shutdown limits and zero configured retries were retained. Raw traces, private configuration and detailed operational records stay local.

The separately measured eager-engine synthetic sweep achieved 23.08, 37.75 and 69.51 output tokens per second at concurrency one, two and four respectively. The four-way result is a 3.01× aggregate throughput gain for that fixed short workload, with about 32% higher mean request latency. CUDA graph mode failed during startup because compiler tooling was missing; no graph speedup was measured. These observations do not establish coding quality, a full-run cost, or long-context performance.

The planned Rails comparison still contains 135 distinct unstarted attempts across 46 tasks, preserving the intended three/two repetition schedule. No scored benchmark or training ran during this validation. Historical preliminary scores stay separate; this result does not establish a leaderboard position.

Remaining launch gates are sufficient free compute, long-context capacity, validation of the separate host-adapter path, final environment provenance and a declared policy for infrastructure-invalid attempts. The current tests do not prove the complete comparison fits the free-credit allowance. Paid spending remains capped at zero; passing this test does not authorize an automatic benchmark launch.

Public runtime templates require private image selection and callback destination through environment variables. Exact executed source snapshots, hashes, application identities and run evidence remain local; the public templates omit deployment-specific values.

Before running synthetic fixtures, supply `SYNTHETIC_IMAGE` for an appropriate local Docker image. The private GPU preflight additionally requires `QWEN_PREFLIGHT_IMAGE_ID` and `CODEX_NOTIFY_THREAD_ID`; missing configuration fails before launch. These values and provider credentials do not belong in source control.
