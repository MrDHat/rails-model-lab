#!/usr/bin/env bash
# Run on your laptop while the VM is up. Uploads one round's LoRA adapter
# from the VM straight to a private Hugging Face model repo, as a backup off
# the VM's disk; nothing is copied to the laptop. Needs the hf CLI on the VM
# (~/hf-cli/bin/hf) logged in once with `hf auth login`.
#
#   bash training/push-adapter.sh runs/rl/qwen3.5-27b-rl3
#
# The repo is HF_ADAPTER_REPO, else the one named in runs/hf-adapter-repo
# (untracked); with neither it skips quietly. Each adapter goes in a folder
# named after its model (qwen3.5-27b-rl3/), with from.txt naming the model it
# was trained on top of, down to the base Qwen3.5-27B.
set -euo pipefail
cd "$(dirname "$0")/.."
repo="${HF_ADAPTER_REPO:-$(cat runs/hf-adapter-repo 2>/dev/null || true)}"
[ -n "$repo" ] || { echo "no Hugging Face repo set; not uploading"; exit 0; }
VM="${VM_NAME:-rails-qwen-a100}" Z="${GCP_ZONE:-us-central1-a}"
run="${1:?run dir, e.g. runs/rl/qwen3.5-27b-rl3}" name=$(basename "$1")
# Docker wrote the adapter as root and owner-only, so make it readable first.
gcloud compute ssh "$VM" --zone "$Z" --command "set -e; cd ~/rails-model-lab/$run
  sudo chmod -R a+rX adapter; test -s adapter/adapter_model.safetensors
  test ! -f from || echo qwen3.5-27b-\$(cat from) | sudo tee adapter/from.txt >/dev/null
  ~/hf-cli/bin/hf repos create $repo --repo-type model --private --exist-ok >/dev/null
  ~/hf-cli/bin/hf upload $repo adapter $name --repo-type model --exclude README.md --commit-message 'Add $name adapter' >/dev/null" 2>&1 \
  | { grep -v 'Ignoring unknown\|IAP tunnel\|NumPy\|tcp_upload\|^WARNING\|^$' || true; }
test "${PIPESTATUS[0]}" = 0
echo "uploaded $name to https://huggingface.co/$repo/tree/main/$name"
