#!/usr/bin/env bash
# Run on the VM after serve-qwen.sh. Runs the official tasks with lemans and
# its own docker backend, inside tmux so it survives SSH disconnects.
#
#   QWEN=qwen3.5-27b bash baseline/run-baseline.sh atomic   # 19 at- tasks, 1 attempt each (ATTEMPTS=3 for official count)
#   bash baseline/run-baseline.sh official   # 135 runs: 3 attempts per task, 2 on the three ms- exceptions
#
# Reruns use `lemans run --resume`, which only counts scored trials: an
# infrastructure failure gets another attempt, a scored model failure never does.
# Every attempt's directory stays on disk.
set -euo pipefail
cd "$(dirname "$0")/.."
source baseline/settings.sh

stage="${1:?usage: run-baseline.sh atomic|official}"
if [ -z "${TMUX:-}" ] && [ "${2:-}" != --inside ]; then
  # A running tmux server keeps its own environment, so pass the knobs explicitly.
  tmux new-session -d -s "baseline-$QWEN-$stage" \
    "QWEN=$QWEN CONCURRENCY=$CONCURRENCY ATTEMPTS=${ATTEMPTS:-1} bash baseline/run-baseline.sh $stage --inside 2>&1 | tee -a runs/baseline-$QWEN-$stage.log"
  echo "Started in tmux session baseline-$QWEN-$stage. Watch: tmux attach -t baseline-$QWEN-$stage"
  exit 0
fi

eval "$(~/.rbenv/bin/rbenv init - bash)" 2>/dev/null || true
test "$(cat runs/inference/proxy.model 2>/dev/null)" = "$MODEL" && curl -sf "http://127.0.0.1:$PROXY_PORT/v1/models" >/dev/null \
  || { echo "Run QWEN=$QWEN baseline/serve-qwen.sh first" >&2; exit 1; }
test "$(git -C vendor/ai-evals rev-parse HEAD)" = "$(cat benchmark-revision.txt)"

runs="runs/$QWEN-$stage"
mkdir -p "$runs"
export GPUSTACK_API_BASE="http://127.0.0.1:$PROXY_PORT/v1"
# The relay sends this as a bearer token; vLLM is loopback-only and ignores it.
export MODAL_BRIDGE_TOKEN="$(openssl rand -hex 16)"

lemans() {
  bundle exec lemans run -r ./baseline/transport/staged-provider-config.rb \
    --bench vendor/ai-evals --backend docker --model "gpustack/$MODEL" \
    --max-output-tokens 32768 --concurrency "$CONCURRENCY" --runs-dir "$runs" --resume "$@" || true
}

task_flags() { for t in "$@"; do printf -- '--task\n%s\n' "$t"; done; }
mapfile -t atomic < <(ls vendor/ai-evals/tasks | grep '^at-')
mapfile -t feature < <(ls vendor/ai-evals/tasks | grep '^ft-')
two_attempts=(ms-greenfield-helpdesk ms-redmine-rails-upgrade ms-retire-proposals)
mapfile -t multistep < <(ls vendor/ai-evals/tasks | grep '^ms-' | grep -vxF -f <(printf '%s\n' "${two_attempts[@]}"))

for pass in 1 2 3; do
  echo "=== $stage pass $pass $(date -u +%FT%TZ)"
  case "$stage" in
    atomic) mapfile -t f < <(task_flags "${atomic[@]}"); lemans --attempts "${ATTEMPTS:-1}" "${f[@]}" ;;
    official)
      mapfile -t f < <(task_flags "${atomic[@]}" "${feature[@]}" "${multistep[@]}"); lemans --attempts 3 "${f[@]}"
      mapfile -t f < <(task_flags "${two_attempts[@]}"); lemans --attempts 2 "${f[@]}" ;;
    *) echo "unknown stage $stage" >&2; exit 2 ;;
  esac
done

bundle exec lemans report "$runs" --skip-invalid -A model-task | tee "$runs/report-by-task.txt"
bundle exec lemans report "$runs" --skip-invalid -A model | tee "$runs/report.txt"
echo "Invalid (infrastructure) attempts kept on disk:"
bundle exec lemans report "$runs" | grep -ci invalid || true
