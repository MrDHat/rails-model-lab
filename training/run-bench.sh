#!/usr/bin/env bash
# Run on the VM after baseline/serve-qwen.sh. Runs the training tasks as an
# agentic bench with the baseline's harness, agent, transport and limits,
# inside tmux so it survives SSH disconnects.
#
#   bash training/run-bench.sh proof     # oracle and no-op agents on all 60 tasks: 1.0 and 0 each, no model
#   QWEN=qwen3.5-27b bash training/run-bench.sh heldout   # validation + sealed tasks, 3 attempts each
#   QWEN=qwen3.5-27b bash training/run-bench.sh apps      # app tasks (training/app-tasks), 3 attempts each
#   QWEN=qwen3.5-27b bash training/run-bench.sh train     # train-split tasks, ATTEMPTS (default 6) each, for SFT data
#   QWEN=qwen3.5-27b-sft bash training/run-bench.sh validation   # validation tasks of both sets, 3 attempts each
#
# Like run-baseline.sh, each pass reruns only infrastructure failures.
set -euo pipefail
cd "$(dirname "$0")/.."
source baseline/settings.sh

stage="${1:?usage: run-bench.sh proof|heldout|apps|train|validation}"
if [ -z "${TMUX:-}" ] && [ "${2:-}" != --inside ]; then
  session="bench-${QWEN//./_}-$stage"
  tmux new-session -d -s "$session" \
    "QWEN=$QWEN CONCURRENCY=$CONCURRENCY ATTEMPTS=${ATTEMPTS:-} bash training/run-bench.sh $stage --inside 2>&1 | tee -a runs/bench-$QWEN-$stage.log"
  echo "Started in tmux session $session. Watch: tmux attach -t $session"
  exit 0
fi

eval "$(~/.rbenv/bin/rbenv init - bash)" 2>/dev/null || true
ruby training/bin/build-bench
mapfile -t heldout < <(jq -r '.validation[], .sealed[]' training/splits.json)
mapfile -t apps < <(ls training/app-tasks)
mapfile -t train < <(jq -r '.train[]' training/splits.json training/app-splits.json)
mapfile -t validation < <(jq -r '.validation[]' training/splits.json training/app-splits.json)
task_flags() { for t in "$@"; do printf -- '--task\n%s\n' "$t"; done; }

lemans() {
  bundle exec lemans run -r ./baseline/transport/staged-provider-config.rb \
    --bench training/bench --concurrency "$CONCURRENCY" --resume "$@" || true
}

case "$stage" in
  proof)
    # Neither agent calls a model; the transport only needs a loopback address to load.
    export GPUSTACK_API_BASE="http://127.0.0.1:$PROXY_PORT/v1" MODAL_BRIDGE_TOKEN=unused
    for agent in oracle nop; do
      bundle exec lemans run -r ./baseline/transport/staged-provider-config.rb --bench training/bench \
        --agent "$agent" --model "gpustack/$MODEL" --concurrency 4 --runs-dir "runs/bench-proof-$agent" || true
      bundle exec lemans report "runs/bench-proof-$agent" -A model | tee "runs/bench-proof-$agent/report.txt"
    done
    ;;
  heldout|apps|train|validation)
    test "$(cat runs/inference/proxy.model 2>/dev/null)" = "$MODEL" && curl -sf "http://127.0.0.1:$PROXY_PORT/v1/models" >/dev/null \
      || { echo "Run QWEN=$QWEN baseline/serve-qwen.sh first" >&2; exit 1; }
    export GPUSTACK_API_BASE="http://127.0.0.1:$PROXY_PORT/v1"
    export MODAL_BRIDGE_TOKEN="$(openssl rand -hex 16)"
    runs="runs/bench-$QWEN-$stage"
    mkdir -p "$runs"
    case "$stage" in
      apps) mapfile -t f < <(task_flags "${apps[@]}") ;;
      train) mapfile -t f < <(task_flags "${train[@]}"); ATTEMPTS="${ATTEMPTS:-6}" ;;
      validation) mapfile -t f < <(task_flags "${validation[@]}") ;;
      *) mapfile -t f < <(task_flags "${heldout[@]}") ;;
    esac
    for pass in 1 2 3; do
      echo "=== $stage pass $pass $(date -u +%FT%TZ)"
      lemans --model "gpustack/$MODEL" --max-output-tokens 32768 --attempts "${ATTEMPTS:-3}" --runs-dir "$runs" "${f[@]}"
    done
    bundle exec lemans report "$runs" --skip-invalid -A model-task | tee "$runs/report-by-task.txt"
    bundle exec lemans report "$runs" --skip-invalid -A model | tee "$runs/report.txt"
    ;;
  *) echo "unknown stage $stage" >&2; exit 2 ;;
esac
