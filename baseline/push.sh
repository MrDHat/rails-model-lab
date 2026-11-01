#!/usr/bin/env bash
# Run on your laptop. Copies the repository (without runs, gems or the
# benchmark checkout, which the VM fetches itself) to the VM.
set -euo pipefail
cd "$(dirname "$0")/.."
ZONE="${GCP_ZONE:-us-central1-a}"
VM="${VM_NAME:-rails-qwen}"

archive="$(mktemp -t rails-model-lab).tgz"
COPYFILE_DISABLE=1 tar --exclude ./runs --exclude ./vendor --exclude ./.git \
  --exclude '*.DS_Store' --exclude '__pycache__' -czf "$archive" .
gcloud compute scp --zone "$ZONE" "$archive" "$VM:~/rails-model-lab.tgz"
gcloud compute ssh "$VM" --zone "$ZONE" --command \
  'mkdir -p ~/rails-model-lab && tar -xzf ~/rails-model-lab.tgz -C ~/rails-model-lab && rm ~/rails-model-lab.tgz'
rm -f "$archive"
# Inference on Modal needs your Modal token on the VM (it stays in your home directory there).
if [ -f ~/.modal.toml ]; then
  gcloud compute scp --zone "$ZONE" ~/.modal.toml "$VM:~/.modal.toml"
fi
