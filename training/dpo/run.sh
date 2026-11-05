#!/usr/bin/env bash
# Run on the GPU VM. The DPO stage, end to end and safe to rerun after a
# preemption: builds the pairs from the train-split attempts, trains the LoRA
# (resuming from its last checkpoint), and merges it into full weights that
# baseline/models/qwen3.5-27b-dpo.env serves. Stops vLLM first, since
# training needs the whole GPU.
#
#   bash training/dpo/run.sh
set -euo pipefail
cd "$(dirname "$0")/../.."
QWEN=qwen3.5-27b source baseline/settings.sh
out=runs/dpo/qwen3.5-27b-dpo
mkdir -p "$out"

python3 training/dpo/build_pairs.py "$out/pairs.jsonl" runs/bench-qwen3.5-27b-train runs/bench-qwen3.5-27b-apps \
  | tee "$out/pairs.txt"
docker rm -f qwen-vllm >/dev/null 2>&1 || true

# The vLLM image already has a PyTorch and transformers that know Qwen3.5.
in_image() {
  docker run --rm --gpus all --ipc host --entrypoint bash \
    -v "$HF_CACHE:/root/.cache/huggingface" -v "$PWD:/work" -w /work/training \
    -e HF_HUB_OFFLINE=1 -e PYTHONUNBUFFERED=1 -e PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True "$VLLM_IMAGE" -c \
    "pip install -q 'peft>=0.17,<1' flash-linear-attention 2>&1 | tail -1; $1"
}
[ -d "$out/adapter" ] || in_image "python3 dpo/train.py /work/$out/pairs.jsonl /work/$out" 2>&1 | tee -a "$out/train.log"
test -d "$out/adapter"
[ -f "$HF_CACHE/merged/qwen3.5-27b-dpo/config.json" ] \
  || in_image "cd sft && python3 merge.py /work/$out/adapter /root/.cache/huggingface/merged/qwen3.5-27b-dpo" 2>&1 | tee -a "$out/merge.log"
echo "DPO done: serve with QWEN=qwen3.5-27b-dpo bash baseline/serve-qwen.sh"
