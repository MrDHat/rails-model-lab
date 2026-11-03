#!/usr/bin/env bash
# Builds the toolshed image and scores the app tasks in it. Logs land in runs/app-tasks/.
#   bash training/check-app-tasks.sh [--schema] [task ...]
set -euo pipefail
cd "$(dirname "$0")"
docker build -q -t toolshed-tasks -f apps/Dockerfile.toolshed apps >/dev/null
mkdir -p ../runs/app-tasks
docker run --rm -e BUNDLE_GEMFILE= -v "$PWD":/repo/training -v "$PWD/../runs":/repo/runs -w /repo/training toolshed-tasks ruby bin/check-app-tasks "$@"
