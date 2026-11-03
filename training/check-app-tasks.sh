#!/usr/bin/env bash
# Builds the apps' image and scores the app tasks in it. Logs land in runs/app-tasks/.
#   bash training/check-app-tasks.sh [--schema] [task ...]
set -euo pipefail
cd "$(dirname "$0")"
for lock in apps/*/Gemfile.lock; do
  cmp -s "$lock" apps/toolshed/Gemfile.lock || { echo "$lock differs from apps/toolshed/Gemfile.lock; the image only has toolshed's gems" >&2; exit 1; }
done
docker build -q -t rails-app-tasks -f apps/Dockerfile apps >/dev/null
mkdir -p ../runs/app-tasks
docker run --rm -e BUNDLE_GEMFILE= -v "$PWD":/repo/training -v "$PWD/../runs":/repo/runs -w /repo/training rails-app-tasks ruby bin/check-app-tasks "$@"
