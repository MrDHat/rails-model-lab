#!/usr/bin/env bash
# Run on the GPU VM. One DPO round, end to end and safe to rerun after a
# preemption: builds the pairs from train-split attempts, trains the LoRA
# (resuming from its last checkpoint), and merges it into full weights that
# baseline/models/<name>.env serves. Stops vLLM first, since training needs
# the whole GPU.
#
#   bash training/dpo/run.sh            # round 1: the base model's attempts -> qwen3.5-27b-dpo
#   ROUND=2 bash training/dpo/run.sh    # round 2: qwen3.5-27b-dpo's own attempts -> qwen3.5-27b-dpo2
#
# Round N starts from round N-1's merged model, which is also its reference,
# and learns from that model's attempts (training/run-bench.sh train served
# as QWEN=<previous>), so each round sees the mistakes the model makes now.
set -euo pipefail
cd "$(dirname "$0")/../.."
QWEN=qwen3.5-27b source baseline/settings.sh
ROUND="${ROUND:-1}"
if [ "$ROUND" = 1 ]; then
  name=qwen3.5-27b-dpo start=""
  attempts=(runs/bench-qwen3.5-27b-train runs/bench-qwen3.5-27b-apps)
else
  prev=qwen3.5-27b-dpo; [ "$ROUND" -gt 2 ] && prev=qwen3.5-27b-dpo$((ROUND - 1))
  name=qwen3.5-27b-dpo$ROUND start=/root/.cache/huggingface/merged/$prev
  attempts=("runs/bench-$prev-train")
  # The local SSD loses merged weights on preemption; rebuild the previous round's.
  [ -f "$HF_CACHE/merged/$prev/config.json" ] || ROUND=$((ROUND - 1)) bash training/dpo/run.sh
fi
out=runs/dpo/$name
mkdir -p "$out"

python3 training/dpo/build_pairs.py "$out/pairs.jsonl" "${attempts[@]}" | tee "$out/pairs.txt"
docker rm -f qwen-vllm >/dev/null 2>&1 || true

# The vLLM image already has a PyTorch and transformers that know Qwen3.5.
in_image() {
  docker run --rm --gpus all --ipc host --entrypoint bash \
    -v "$HF_CACHE:/root/.cache/huggingface" -v "$PWD:/work" -w /work/training \
    -e HF_HUB_OFFLINE=1 -e PYTHONUNBUFFERED=1 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True \
    ${start:+-e MODEL=$start} "$VLLM_IMAGE" -c \
    "pip install -q 'peft>=0.17,<1' flash-linear-attention 2>&1 | tail -1; $1"
}
[ -d "$out/adapter" ] || in_image "python3 dpo/train.py /work/$out/pairs.jsonl /work/$out" 2>&1 | tee -a "$out/train.log"
test -d "$out/adapter"
[ -f "$HF_CACHE/merged/$name/config.json" ] \
  || in_image "cd sft && python3 merge.py /work/$out/adapter /root/.cache/huggingface/merged/$name" 2>&1 | tee -a "$out/merge.log"
echo "DPO round $ROUND done: serve with QWEN=$name bash baseline/serve-qwen.sh"
