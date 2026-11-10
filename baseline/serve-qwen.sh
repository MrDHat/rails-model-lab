#!/usr/bin/env bash
# Run on the VM. Starts vLLM (loopback only) and the settings proxy, then
# waits until a real completion comes back. Safe to rerun.
set -euo pipefail
cd "$(dirname "$0")/.."
source baseline/settings.sh

mkdir -p runs/inference
# One proxy serves one model; replace it when QWEN changes.
if [ "$(cat runs/inference/proxy.model 2>/dev/null)" != "$MODEL" ]; then
  pkill -f settings-proxy.py || true
  sleep 1
fi
start_proxy() {
  pgrep -f baseline/settings-proxy.py >/dev/null && return
  nohup "$@" baseline/settings-proxy.py "runs/inference/$QWEN-$(date -u +%Y%m%dT%H%M%S)" \
    "$PROXY_PORT" "$UPSTREAM" > "runs/inference/proxy-$QWEN.log" 2>&1 &
  echo "$MODEL" > runs/inference/proxy.model
  sleep 3
}

if [ "$INFERENCE" = modal ]; then
  UPSTREAM=modal start_proxy "$MODAL_VENV/bin/python"
  echo "Calling Modal (a cold start takes several minutes)..."
  curl -sf --max-time 1500 "http://127.0.0.1:$PROXY_PORT/v1/chat/completions" -H 'Content-Type: application/json' \
    -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}]}' \
    | jq '{content: .choices[0].message.content, usage}' || { cat "runs/inference/proxy-$QWEN.log"; exit 1; }
  echo "$MODEL (Modal) is reachable on 127.0.0.1:$PROXY_PORT"
  exit 0
fi

# A model file with WEIGHTS serves local (e.g. fine-tuned) weights under the name MODEL.
if [ -n "${WEIGHTS:-}" ]; then
  model_args=("$WEIGHTS" --served-model-name "$MODEL")
else
  model_args=("$MODEL" --revision "$MODEL_REVISION")
fi
if ! docker ps --format '{{.Names}}' | grep -qx qwen-vllm; then
  docker rm -f qwen-vllm >/dev/null 2>&1 || true
  # Same serving flags as the earlier staged Modal provider (git history), without --enforce-eager.
  docker run -d --name qwen-vllm --gpus all --network host --ipc host \
    -v "$HF_CACHE:/root/.cache/huggingface" -e HF_HUB_OFFLINE=1 \
    "$VLLM_IMAGE" "${model_args[@]}" \
    --host 127.0.0.1 --port "$VLLM_PORT" --dtype bfloat16 \
    --max-model-len "$MAX_MODEL_LEN" --max-num-seqs "$MAX_SEQS" --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION" \
    --language-model-only --enable-auto-tool-choice --tool-call-parser qwen3_coder \
    --reasoning-parser qwen3 --enable-prefix-caching --generation-config vllm \
    --no-enable-log-requests
fi

UPSTREAM="$VLLM_PORT" start_proxy python3

echo "Waiting for vLLM (compiled startup takes several minutes)..."
until curl -sf "http://127.0.0.1:$VLLM_PORT/health" >/dev/null; do
  docker ps --format '{{.Names}}' | grep -qx qwen-vllm || { docker logs --tail 50 qwen-vllm; exit 1; }
  sleep 10
done

curl -sf "http://127.0.0.1:$PROXY_PORT/v1/chat/completions" -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}]}' \
  | jq '{content: .choices[0].message.content, usage}'
echo "$MODEL is serving on 127.0.0.1:$PROXY_PORT"
