#!/usr/bin/env bash
# Run on the VM (create-vm.sh does this). Installs Ruby 3.4, the pinned
# benchmark and gems, the vLLM image and the pinned Qwen weights. Idempotent.
set -euo pipefail
cd "$(dirname "$0")/.."
source baseline/settings.sh

if [ -e "$LOCAL_SSD" ] && ! mountpoint -q /mnt/localssd; then
  sudo mkfs.ext4 -q -F "$LOCAL_SSD"
  sudo mkdir -p /mnt/localssd
  sudo mount -o discard,defaults "$LOCAL_SSD" /mnt/localssd
  sudo chown "$USER" /mnt/localssd
fi

sudo apt-get update -qq
sudo apt-get install -y -qq build-essential git curl tmux jq libssl-dev libyaml-dev \
  zlib1g-dev libffi-dev libreadline-dev python3 python3-venv

command -v docker >/dev/null || sudo apt-get install -y -qq docker.io
# BuildKit: the legacy builder races when concurrent trials build the same image.
sudo apt-get install -y -qq docker-buildx
sudo usermod -aG docker "$USER"
if [ "$INFERENCE" = local ]; then
  nvidia-smi --query-gpu=name,memory.total --format=csv
  sudo docker run --rm --gpus all --entrypoint nvidia-smi "$VLLM_IMAGE" -L >/dev/null 2>&1 \
    || { echo "Docker cannot see the GPU; check nvidia-container-toolkit" >&2; exit 1; }
else
  python3 -m venv "$MODAL_VENV"
  "$MODAL_VENV/bin/pip" install -q modal==1.6.2
  test -f ~/.modal.toml || echo "No ~/.modal.toml yet: baseline/push.sh copies your laptop's" >&2
fi

if ! command -v ruby >/dev/null || ! ruby -e 'exit RUBY_VERSION >= "3.4"'; then
  if [ ! -x "$HOME/.rbenv/bin/rbenv" ]; then
    git clone --depth 1 https://github.com/rbenv/rbenv.git ~/.rbenv
    git clone --depth 1 https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
  fi
  eval "$(~/.rbenv/bin/rbenv init - bash)"
  version="$(rbenv install -l 2>/dev/null | grep -E "^ *${RUBY_VERSION//./\\.}\\.[0-9]+$" | tail -1 | tr -d ' ')"
  rbenv install -s "$version"
  rbenv global "$version"
fi
eval "$(~/.rbenv/bin/rbenv init - bash)" 2>/dev/null || true
gem install bundler --no-document --conservative
bash bin/setup-benchmark

[ "$INFERENCE" = local ] || { echo "Provisioned (inference on Modal)."; exit 0; }
[ -z "${WEIGHTS:-}" ] || { echo "Provisioned (serving local weights from $WEIGHTS)."; exit 0; }
mkdir -p "$HF_CACHE"
sudo docker pull "$VLLM_IMAGE"
sudo docker run --rm -v "$HF_CACHE:/root/.cache/huggingface" --entrypoint python3 "$VLLM_IMAGE" -c \
  "from huggingface_hub import snapshot_download; print(snapshot_download('$MODEL', revision='$MODEL_REVISION'))"
echo "Provisioned. Log out and back in once so the docker group applies."
