# Shared settings for the baseline. QWEN picks a model file in baseline/models/.
RUBY_VERSION="${RUBY_VERSION:-3.4}"  # newest 3.4.x
export LANG=C.UTF-8 LC_ALL=C.UTF-8
VLLM_IMAGE="${VLLM_IMAGE:-vllm/vllm-openai:v0.32.0}"
QWEN="${QWEN:-qwen3.5-4b}"
# MAX_SEQS and GPU_MEMORY_UTILIZATION from the environment override the model
# file, e.g. for a GPU with less memory than the one it was tuned for.
seqs="${MAX_SEQS:-}" util="${GPU_MEMORY_UTILIZATION:-}"
set -a; source "baseline/models/$QWEN.env"; set +a
MAX_SEQS="${seqs:-$MAX_SEQS}" GPU_MEMORY_UTILIZATION="${util:-$GPU_MEMORY_UTILIZATION}"
export QWEN
# A GCP local NVMe SSD (wiped on every stop) reads weights far faster than a
# standard persistent disk: about 20 MB/s there made each vLLM start take 40
# minutes. provision.sh mounts it at /mnt/localssd and downloads the weights.
LOCAL_SSD=/dev/disk/by-id/google-local-nvme-ssd-0
if [ -e "$LOCAL_SSD" ]; then HF_CACHE=/mnt/localssd/hf-cache; else HF_CACHE="$HOME/hf-cache"; fi
VLLM_PORT=8000
# A smaller GPU may not fit a full 256K context in its KV cache.
MAX_MODEL_LEN="${MAX_MODEL_LEN:-262144}"
PROXY_PORT=8001
# Concurrent agents sharing the one GPU. More agents means each one generates
# slower and is likelier to hit the 90-minute task limit.
CONCURRENCY="${CONCURRENCY:-2}"
# "local" serves vLLM on this VM's GPU; "modal" calls the deployed baseline/modal_qwen.py.
INFERENCE="${INFERENCE:-$(command -v nvidia-smi >/dev/null && echo local || echo modal)}"
MODAL_VENV="$HOME/modal-venv"
