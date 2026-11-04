#!/usr/bin/env bash
# Run on your laptop. Creates one native x86 GPU VM that hosts both vLLM and
# the lemans harness, then copies this repository to it.
#
#   GCP_PROJECT=my-project bash baseline/create-vm.sh
#
# Overrides: GCP_ZONE, VM_NAME, MACHINE (g2-standard-16 = 1x L4),
# PROVISIONING (SPOT or STANDARD), DISK_GB, DISK_TYPE.
set -euo pipefail
cd "$(dirname "$0")/.."

: "${GCP_PROJECT:?set GCP_PROJECT}"
ZONE="${GCP_ZONE:-us-central1-a}"
VM="${VM_NAME:-rails-qwen}"
MACHINE="${MACHINE:-g2-standard-16}"
PROVISIONING="${PROVISIONING:-SPOT}"
DISK_GB="${DISK_GB:-200}"  # new projects allow 250 GB of SSD-class disk per region
DISK_TYPE="${DISK_TYPE:-pd-balanced}"  # pd-standard counts against the larger HDD quota

gcloud config set project "$GCP_PROJECT" >/dev/null

# GPU=0 makes a CPU-only harness VM; inference then runs on Modal.
if [ "${GPU:-1}" = 0 ]; then
  MACHINE="${MACHINE_CPU:-n2-standard-8}"
  gcloud compute instances create "$VM" --zone "$ZONE" --machine-type "$MACHINE" \
    --image-family ubuntu-2204-lts --image-project ubuntu-os-cloud \
    --boot-disk-size "${DISK_GB}GB" --boot-disk-type "$DISK_TYPE"
else
# Deep Learning VM images ship the NVIDIA driver, Docker and the container toolkit.
IMAGE="$(gcloud compute images list --project deeplearning-platform-release \
  --filter='family~^common-cu12.*ubuntu-2204' --sort-by=~creationTimestamp \
  --format='value(name)' --limit 1)"
: "${IMAGE:?no Deep Learning VM image found; pick one with gcloud compute images list --project deeplearning-platform-release}"
echo "Image: $IMAGE"

spot_flags=()
if [ "$PROVISIONING" = SPOT ]; then
  # A preempted VM stops instead of being deleted; restart it and rerun with --resume.
  spot_flags=(--provisioning-model=SPOT --instance-termination-action=STOP)
fi

gcloud compute instances create "$VM" --zone "$ZONE" \
  --machine-type "$MACHINE" "${spot_flags[@]}" \
  --maintenance-policy TERMINATE \
  --image "$IMAGE" --image-project deeplearning-platform-release \
  --boot-disk-size "${DISK_GB}GB" --boot-disk-type "$DISK_TYPE" \
  --metadata install-nvidia-driver=True
fi

echo "Waiting for SSH..."
until gcloud compute ssh "$VM" --zone "$ZONE" --command true 2>/dev/null; do sleep 10; done

bash baseline/push.sh
gcloud compute ssh "$VM" --zone "$ZONE" --command 'bash ~/rails-model-lab/baseline/provision.sh'
echo
echo "Ready. Next:  gcloud compute ssh $VM --zone $ZONE"
echo "Then on the VM:  bash ~/rails-model-lab/baseline/serve-qwen.sh && bash ~/rails-model-lab/baseline/run-baseline.sh atomic"
