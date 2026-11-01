#!/usr/bin/env bash
# Run on the VM. Starts vLLM (loopback only) and the settings proxy, then
# waits until a real completion comes back. Safe to rerun.
set -euo pipefail
cd "$(dirname "$0")/.."
source baseline/settings.sh

if [ "$INFERENCE" = modal ]; then
  mkdir -p runs/inference
  if ! pgrep -f baseline/settings-proxy.py >/dev/null; then
    nohup "$MODAL_VENV/bin/python" baseline/settings-proxy.py "runs/inference/$(date -u +%Y%m%dT%H%M%S)" \
      "$PROXY_PORT" modal > runs/inference/proxy.log 2>&1 &
    sleep 3
  fi
  echo "Calling Modal (a cold start takes several minutes)..."
  curl -sf --max-time 1500 "http://127.0.0.1:$PROXY_PORT/v1/chat/completions" -H 'Content-Type: application/json' \
    -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}]}' \
    | jq '{content: .choices[0].message.content, usage}' || { cat runs/inference/proxy.log; exit 1; }
  echo "Qwen (Modal) is reachable on 127.0.0.1:$PROXY_PORT"
  exit 0
fi

if ! docker ps --format '{{.Names}}' | grep -qx qwen-vllm; then
  docker rm -f qwen-vllm >/dev/null 2>&1 || true
  # Same serving flags as the earlier staged Modal provider (git history), without --enforce-eager.
  docker run -d --name qwen-vllm --gpus all --network host --ipc host \
    -v "$HF_CACHE:/root/.cache/huggingface" -e HF_HUB_OFFLINE=1 \
    "$VLLM_IMAGE" "$MODEL" --revision "$MODEL_REVISION" \
    --host 127.0.0.1 --port "$VLLM_PORT" --dtype bfloat16 \
    --max-model-len 262144 --max-num-seqs 4 --gpu-memory-utilization 0.85 \
    --language-model-only --enable-auto-tool-choice --tool-call-parser qwen3_coder \
    --reasoning-parser qwen3 --enable-prefix-caching --generation-config vllm \
    --no-enable-log-requests
fi

mkdir -p runs/inference
if ! pgrep -f baseline/settings-proxy.py >/dev/null; then
  nohup python3 baseline/settings-proxy.py "runs/inference/$(date -u +%Y%m%dT%H%M%S)" \
    "$PROXY_PORT" "$VLLM_PORT" > runs/inference/proxy.log 2>&1 &
fi

echo "Waiting for vLLM (compiled startup takes several minutes)..."
until curl -sf "http://127.0.0.1:$VLLM_PORT/health" >/dev/null; do
  docker ps --format '{{.Names}}' | grep -qx qwen-vllm || { docker logs --tail 50 qwen-vllm; exit 1; }
  sleep 10
done

curl -sf "http://127.0.0.1:$PROXY_PORT/v1/chat/completions" -H 'Content-Type: application/json' \
  -d '{"messages":[{"role":"user","content":"Reply with exactly: OK"}]}' \
  | jq '{content: .choices[0].message.content, usage}'
echo "Qwen is serving on 127.0.0.1:$PROXY_PORT"
