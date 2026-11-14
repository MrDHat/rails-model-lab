#!/usr/bin/env bash
# Run on your laptop. Runs training rounds back to back on the spot VM (collect
# the previous model's attempts, train, evaluate on validation) until a round no
# longer fully solves more validation attempts than the best model so far.
#
#   START=4 BEST=30 bash training/rounds-spot.sh                          # DPO rounds 4, 5, ...
#   STAGE=rl FROM=dpo4 START=1 BEST=34 SKIP_COLLECT=1 bash training/rounds-spot.sh
#   STAGE=rl FROM=rl START=3 BEST=37 ATTEMPTS=16 bash training/rounds-spot.sh
#
# STAGE is dpo (default) or rl. START is the first round to run; BEST is the
# best validation score so far (fully solved attempts out of 51). FROM is the
# model the first round starts from (rl only; required for round 1).
# ATTEMPTS is attempts per train task when collecting (default 6). SKIP_COLLECT=1 reuses the attempts the
# first round's starting model already made on the train tasks.
set -uo pipefail
cd "$(dirname "$0")/.."
stage="${STAGE:-dpo}" from="${FROM:-}"; unset FROM  # FROM is for the first round only
n="${START:?START=first round to run}" best="${BEST:?BEST=best validation score so far}"
model() { [ "$1" = 1 ] && echo "$stage" || echo "$stage$1"; }  # round 1 is "dpo"/"rl", then dpo2, rl2, ...
while :; do
  cur=$(model "$n") prev=$(model $((n - 1)))
  first=""; [ "$n" = "$START" ] && [ -n "$from" ] && prev=$from first=$from
  [ "$n" = 1 ] && prev="${from:?FROM=model round 1 starts from}"
  env=baseline/models/qwen3.5-27b-$cur.env
  [ -f "$env" ] || cat > "$env" <<EOF
# Qwen3.5-27B after $stage round $n (training/$stage/run.sh, ROUND=$n), served from
# local weights under the same settings as the base 27B.
MODEL=rails-qwen3.5-27b-$cur
WEIGHTS=/root/.cache/huggingface/merged/qwen3.5-27b-$cur
MODEL_REVISION=local
MAX_SEQS=6
GPU_MEMORY_UTILIZATION=0.90
EOF
  if [ -n "${SKIP_COLLECT:-}" ] && [ "$n" = "$START" ]; then
    echo "=== round $n: reusing $prev's train attempts"
  else
    echo "=== round $n: collect $prev"
    MODE=collect V=$prev HOURS=30 bash training/drive-spot.sh || exit 1
  fi
  echo "=== round $n: train $cur"
  FROM=$first MODE=train V=$cur HOURS=20 bash training/drive-spot.sh || exit 1
  echo "=== round $n: evaluate $cur"
  out=$(MODE=eval V=$cur HOURS=20 bash training/drive-spot.sh | tee /dev/stderr) || exit 1
  solved=$(echo "$out" | sed -n 's/.* \([0-9][0-9]*\) solved.*/\1/p' | tail -1)
  echo "=== round $n: $solved/51 fully solved (best before: $best)"
  [ -n "$solved" ] && [ "$solved" -gt "$best" ] || { echo "=== flat after round $n"; exit 0; }
  best=$solved n=$((n + 1))
done
