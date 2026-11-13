#!/usr/bin/env bash
# Run on your laptop. Runs DPO rounds back to back on the spot VM (collect the
# previous round's attempts, train, evaluate on validation) until a round no
# longer fully solves more validation attempts than the best round so far.
#
#   START=4 BEST=30 bash training/rounds-spot.sh
#
# START is the first round to run; BEST is the best validation score so far
# (fully solved attempts out of 51).
set -uo pipefail
cd "$(dirname "$0")/.."
n="${START:?START=first round to run}" best="${BEST:?BEST=best validation score so far}"
while :; do
  prev=dpo$((n - 1)); [ "$n" = 2 ] && prev=dpo
  env=baseline/models/qwen3.5-27b-dpo$n.env
  [ -f "$env" ] || cat > "$env" <<EOF
# Qwen3.5-27B after DPO round $n (training/dpo/run.sh, ROUND=$n), served from
# local weights under the same settings as the base 27B.
MODEL=rails-qwen3.5-27b-dpo$n
WEIGHTS=/root/.cache/huggingface/merged/qwen3.5-27b-dpo$n
MODEL_REVISION=local
MAX_SEQS=6
GPU_MEMORY_UTILIZATION=0.90
EOF
  echo "=== round $n: collect $prev"
  MODE=collect V=$prev HOURS=30 bash training/drive-spot.sh || exit 1
  echo "=== round $n: train dpo$n"
  MODE=train V=dpo$n HOURS=20 bash training/drive-spot.sh || exit 1
  echo "=== round $n: evaluate dpo$n"
  out=$(MODE=eval V=dpo$n HOURS=20 bash training/drive-spot.sh | tee /dev/stderr) || exit 1
  solved=$(echo "$out" | sed -n 's/.* \([0-9][0-9]*\) solved.*/\1/p' | tail -1)
  echo "=== round $n: $solved/51 fully solved (best before: $best)"
  [ -n "$solved" ] && [ "$solved" -gt "$best" ] || { echo "=== flat after round $n"; exit 0; }
  best=$solved n=$((n + 1))
done
