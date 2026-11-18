#!/usr/bin/env bash
# Run on the GPU VM. Puts a trained model's merged weights in place for vLLM,
# downloading them from the private Hugging Face repo when they are there.
# Rebuilding a late round means merging every earlier round's adapter in turn,
# about 30 minutes; on a spot VM preempted every hour that leaves little time to
# run anything. A download takes a few minutes.
#
#   HF_ADAPTER_REPO=<repo> bash training/merged-cache.sh qwen3.5-27b-rl3 'FROM= ROUND=3 bash training/rl/run.sh'
#
# Without the weights in the repo it runs the build command, then uploads the
# result in the background so the next restart can download it. The upload is
# one commit, so a preempted upload leaves nothing half-written in the repo.
set -euo pipefail
cd "$(dirname "$0")/.."
QWEN=qwen3.5-27b source baseline/settings.sh
name="${1:?model name, e.g. qwen3.5-27b-rl3}" build="${2:?build command}"
repo="${HF_ADAPTER_REPO:-}" hf=~/hf-cli/bin/hf dst="$HF_CACHE/merged/$name"
[ -f "$dst/config.json" ] && exit 0

if [ -n "$repo" ]; then
  tmp="$HF_CACHE/download-$name"
  sudo rm -rf "$tmp"; sudo mkdir -p "$tmp"; sudo chown "$USER" "$tmp"
  if "$hf" download "$repo" --repo-type model --include "merged/$name/*" --local-dir "$tmp" >/dev/null 2>&1 \
     && [ -f "$tmp/merged/$name/config.json" ]; then
    sudo mkdir -p "$HF_CACHE/merged"; sudo rm -rf "$dst"; sudo mv "$tmp/merged/$name" "$dst"; sudo rm -rf "$tmp"
    echo "downloaded merged $name"; exit 0
  fi
  sudo rm -rf "$tmp"
fi

bash -c "$build"
test -f "$dst/config.json"
if [ -n "$repo" ]; then
  sudo chmod -R a+rX "$dst"
  nohup "$hf" upload "$repo" "$dst" "merged/$name" --repo-type model \
    --commit-message "Add merged $name" > runs/merged-upload-$name.log 2>&1 &
  echo "uploading merged $name in the background"
fi
