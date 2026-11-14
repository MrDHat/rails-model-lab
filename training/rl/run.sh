#!/usr/bin/env bash
# Run on the GPU VM. One RL round, end to end and safe to rerun after a
# preemption: scores the previous model's train-split attempts against each
# other (build_groups.py), trains the LoRA (resuming from its last
# checkpoint), and merges it into full weights that baseline/models/<name>.env
# serves. Stops vLLM first, since training needs the whole GPU.
#
#   bash training/rl/run.sh                    # round 1: dpo4's attempts -> qwen3.5-27b-rl
#   ROUND=2 bash training/rl/run.sh            # round 2: qwen3.5-27b-rl's attempts -> qwen3.5-27b-rl2
#   ROUND=3 FROM=rl bash training/rl/run.sh    # round 3, starting from round 1 instead of 2
#
# Each round learns from its starting model's own attempts
# (runs/bench-<model>-train, collected unseeded).
set -euo pipefail
cd "$(dirname "$0")/../.."
QWEN=qwen3.5-27b source baseline/settings.sh
ROUND="${ROUND:-1}"
name=qwen3.5-27b-rl; [ "$ROUND" -gt 1 ] && name=qwen3.5-27b-rl$ROUND
out=runs/rl/$name
mkdir -p "$out"
# FROM is the model this round starts from: dpoN, rl or rlN. Round 1 defaults to
# dpo4 (the best DPO round), round N to round N-1. The first run records it, so
# a rebuild after a preemption starts from the same model.
if [ -f "$out/from" ]; then FROM=$(cat "$out/from")
elif [ -z "${FROM:-}" ]; then FROM=dpo4; [ "$ROUND" = 2 ] && FROM=rl; [ "$ROUND" -gt 2 ] && FROM=rl$((ROUND - 1))
fi
echo "$FROM" > "$out/from"
prev=qwen3.5-27b-$FROM
case "$FROM" in
  dpo) rebuild="ROUND=1 bash training/dpo/run.sh" ;;
  dpo*) rebuild="ROUND=${FROM#dpo} bash training/dpo/run.sh" ;;
  rl) rebuild="FROM= ROUND=1 bash training/rl/run.sh" ;;
  rl*) rebuild="FROM= ROUND=${FROM#rl} bash training/rl/run.sh" ;;
  *) echo "unknown FROM=$FROM" >&2; exit 2 ;;
esac
start=/root/.cache/huggingface/merged/$prev
# The local SSD loses merged weights on preemption; rebuild the previous model's.
[ -f "$HF_CACHE/merged/$prev/config.json" ] || bash -c "$rebuild"

python3 training/rl/build_groups.py "$out/groups.jsonl" "runs/bench-$prev-train" | tee "$out/groups.txt"
docker rm -f qwen-vllm >/dev/null 2>&1 || true

# The vLLM image already has a PyTorch and transformers that know Qwen3.5.
in_image() {
  docker run --rm --gpus all --ipc host --entrypoint bash \
    -v "$HF_CACHE:/root/.cache/huggingface" -v "$PWD:/work" -w /work/training \
    -e HF_HUB_OFFLINE=1 -e PYTHONUNBUFFERED=1 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
    -e MODEL="$start" "$VLLM_IMAGE" -c \
    "pip install -q 'peft>=0.17,<1' flash-linear-attention 2>&1 | tail -1; $1"
}
[ -d "$out/adapter" ] || in_image "python3 rl/train.py /work/$out/groups.jsonl /work/$out" 2>&1 | tee -a "$out/train.log"
test -d "$out/adapter"
[ -f "$HF_CACHE/merged/$name/config.json" ] \
  || in_image "cd sft && python3 merge.py /work/$out/adapter /root/.cache/huggingface/merged/$name" 2>&1 | tee -a "$out/merge.log"
# Each merged model is about 54 GB; keep only this model and the one it started from.
# Docker wrote them as root, hence sudo; a failed cleanup must not fail the round.
for old in "$HF_CACHE"/merged/*; do
  case "$(basename "$old")" in "$name"|"$prev") ;; *) sudo rm -rf "$old" || echo "could not remove $old" ;; esac
done
echo "RL round $ROUND done: serve with QWEN=$name bash baseline/serve-qwen.sh"
