# Baseline runner: GCP CPU VM + Modal GPU

A CPU VM on GCP runs the official lemans harness with its Docker backend.
vLLM runs on a Modal GPU. Nothing depends on the laptop staying awake.

```
lemans (VM) ── docker exec stdio ── miniswen in task container
     │
     └─ transport/ relay ── settings-proxy.py :8001 ── Modal (vLLM, A10)
```

- `transport/` is loaded by lemans (`-r`). It relays the in-container
  agent's model calls over `docker exec` to the loopback proxy, so the task
  network allowlist stays unchanged.
- `settings-proxy.py` adds the frozen sampling settings, records every
  request/response under `runs/inference/`, and forwards to Modal.
- `modal_qwen.py` is the Modal app: vLLM with prefix caching, scales to zero
  after 5 idle minutes.

With a GPU VM (`GPU=1`, needs GCP GPU quota) vLLM runs on the VM instead and
Modal isn't used.

## Setup (once)

1. GCP project with billing, and `gcloud auth login`.
2. `modal token new`, so `~/.modal.toml` exists.
3. `modal deploy baseline/modal_qwen.py`.
4. `GPU=0 GCP_PROJECT=your-project bash baseline/create-vm.sh` creates the VM,
   copies the repo and `~/.modal.toml`, and provisions Ruby, Docker and lemans.

## Run

```sh
gcloud compute ssh rails-qwen --zone us-central1-a
bash ~/rails-model-lab/baseline/serve-qwen.sh            # proxy + smoke completion
bash ~/rails-model-lab/baseline/run-baseline.sh atomic   # 19 atomic tasks, in tmux
```

`official` runs the leaderboard protocol: 135 scored runs, three attempts per
task and two on the three named multistep tasks.

Afterwards, on the laptop:

```sh
bash baseline/pull-results.sh                       # VM runs/ -> runs/vm/
modal app stop rails-qwen
gcloud compute instances stop rails-qwen --zone us-central1-a
```

A stopped VM bills only its 200 GB disk, about $8/month.

## Failure policy

`lemans run --resume` counts only scored trials, so each of the three passes
reruns infrastructure failures (Docker errors, a preempted GPU) and never a
scored model failure. Every attempt's directory stays under `runs/gcp-<stage>/`.

## Knobs

- `CONCURRENCY` (default 2): agents sharing the GPU. More finishes the batch
  sooner but slows each agent against the 90-minute task limit.
- `ATTEMPTS` (atomic only, default 1).
