#!/usr/bin/env bash
# Builds the pinned Ruby 3.4 / Rails 8.1 image and scores the tasks in it.
#   bash training/check-tasks.sh [task ...]
set -euo pipefail
cd "$(dirname "$0")"
docker build -q -t rails-model-lab-tasks . >/dev/null
docker run --rm -v "$PWD":/training:ro rails-model-lab-tasks ruby bin/check-tasks "$@"
