#!/usr/bin/env bash
# Run on your laptop. Copies the VM's runs/ into runs/vm/ here.
set -euo pipefail
cd "$(dirname "$0")/.."
ZONE="${GCP_ZONE:-us-central1-a}"
VM="${VM_NAME:-rails-qwen}"
mkdir -p runs/vm
gcloud compute ssh "$VM" --zone "$ZONE" --command 'tar -czf /tmp/runs.tgz -C ~/rails-model-lab runs'
gcloud compute scp --zone "$ZONE" "$VM:/tmp/runs.tgz" runs/vm/runs.tgz
tar -xzf runs/vm/runs.tgz -C runs/vm && rm runs/vm/runs.tgz
echo "Results in runs/vm/runs"
