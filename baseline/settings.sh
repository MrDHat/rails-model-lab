# Shared settings for the baseline. Model, revision and sampling are the
# configuration frozen on 2026-10-30, before any official-limit attempt.
RUBY_VERSION="${RUBY_VERSION:-3.4}"  # newest 3.4.x
export LANG=C.UTF-8 LC_ALL=C.UTF-8
VLLM_IMAGE="${VLLM_IMAGE:-vllm/vllm-openai:v0.32.0}"
MODEL="Qwen/Qwen3.5-4B"
MODEL_REVISION="851bf6e806efd8d0a36b00ddf55e13ccb7b8cd0a"
HF_CACHE="$HOME/hf-cache"
VLLM_PORT=8000
PROXY_PORT=8001
# Concurrent agents sharing the one GPU. More agents means each one generates
# slower and is likelier to hit the 90-minute task limit.
CONCURRENCY="${CONCURRENCY:-2}"
# "local" serves vLLM on this VM's GPU; "modal" calls the deployed baseline/modal_qwen.py.
INFERENCE="${INFERENCE:-$(command -v nvidia-smi >/dev/null && echo local || echo modal)}"
MODAL_VENV="$HOME/modal-venv"
