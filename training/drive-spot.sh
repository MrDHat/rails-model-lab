#!/usr/bin/env bash
# Run on your laptop. Keeps the spot GPU VM going through preemptions until a
# training-stage job finishes, then stops the VM (or after HOURS). Each
# (re)start pushes the code and provisions the VM (mounts the local SSD,
# downloads the base weights); the jobs resume from what the VM's disk kept.
#
#   MODE=train   V=dpo2 bash training/drive-spot.sh   # train and merge model V
#   MODE=collect V=dpo  bash training/drive-spot.sh   # model V attempts the train tasks (runs/bench-qwen3.5-27b-V-train)
#   MODE=eval    V=dpo2 bash training/drive-spot.sh   # model V on the validation tasks (runs/bench-qwen3.5-27b-V-validation)
#
# V is sft, dpo (DPO round 1), dpoN (round N), rl (RL round 1) or rlN. collect and eval first
# rebuild V's merged weights if the local SSD lost them.
set -uo pipefail
VM="${VM_NAME:-rails-qwen-a100}" Z="${GCP_ZONE:-us-central1-a}"
REPO="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${MODE:?MODE=train, collect or eval}" V="${V:?V=sft, dpo, dpoN, rl or rlN}"
deadline=$(( $(date +%s) + ${HOURS:-12} * 3600 ))
log() { echo "$(date -u +%T) $*"; }
remote() { gcloud compute ssh "$VM" --zone "$Z" --command "$1" 2>&1 | { grep -v 'Ignoring unknown' || true; }; return "${PIPESTATUS[0]}"; }
status() { gcloud compute instances describe "$VM" --zone "$Z" --format='value(status)'; }
stop_vm() { gcloud compute instances stop "$VM" --zone "$Z" --discard-local-ssd=true >/dev/null 2>&1; log "VM stopped"; }

NAME=qwen3.5-27b-$V
case "$V" in
  sft) BUILD="bash training/sft/run.sh" LOGS=runs/sft ;;
  dpo) BUILD="ROUND=1 bash training/dpo/run.sh" LOGS=runs/dpo ;;
  dpo*) BUILD="ROUND=${V#dpo} bash training/dpo/run.sh" LOGS=runs/dpo ;;
  rl) BUILD="ROUND=1 bash training/rl/run.sh" LOGS=runs/rl ;;
  rl*) BUILD="ROUND=${V#rl} bash training/rl/run.sh" LOGS=runs/rl ;;
  *) echo "unknown V=$V" >&2; exit 2 ;;
esac
OUT=$LOGS/$NAME
SERVE="QWEN=$NAME MAX_SEQS=8 GPU_MEMORY_UTILIZATION=0.93 MAX_MODEL_LEN=131072 CONCURRENCY=6"
case "$MODE" in
  train)
    DONE="test -d $OUT/adapter && test -f /mnt/localssd/hf-cache/merged/$NAME/config.json"
    JOB="tmux new-session -d -s job '$BUILD 2>&1 | tee -a $LOGS/run.log'" ;;
  collect|eval)
    # Collecting needs varied attempts, so sampling is unseeded; eval keeps the frozen seed.
    stage=validation seed=""
    [ "$MODE" = collect ] && stage=train seed="SAMPLING_SEED=none"
    RUNS=runs/bench-$NAME-$stage
    DONE="test -f $RUNS/report.txt"
    JOB="rm -f $RUNS/report.txt && tmux new-session -d -s job \"$BUILD >> $LOGS/run.log 2>&1 && sg docker -c '$seed $SERVE bash baseline/serve-qwen.sh' >> $LOGS/serve.log 2>&1 && $SERVE bash training/run-bench.sh $stage --inside 2>&1 | tee -a $RUNS.log\"" ;;
  *) echo "unknown MODE=$MODE" >&2; exit 2 ;;
esac

started=0 booted=0
while [ "$(date +%s)" -lt "$deadline" ]; do
  if [ "$(status)" != RUNNING ]; then
    gcloud compute instances start "$VM" --zone "$Z" >/dev/null 2>&1 || { sleep 300; continue; }
    log "VM started"; booted=1
  fi
  until remote true >/dev/null 2>&1; do sleep 15; [ "$(status)" = RUNNING ] || continue 2; done

  if [ "$started" = 1 ] && remote "cd ~/rails-model-lab && $DONE && ! tmux has-session -t job 2>/dev/null" >/dev/null 2>&1; then
    log "done"
    [ "$MODE" = train ] && remote "tail -3 ~/rails-model-lab/$OUT/train.log"
    [ "$MODE" != train ] && remote "cat ~/rails-model-lab/$RUNS/report.txt"
    stop_vm; exit 0
  fi

  alive=$(remote 'tmux has-session -t job 2>/dev/null && echo JOB=up || echo JOB=down')
  case "$alive" in
    *JOB=up*) ;;
    *JOB=down*)
      # SSH answered and the job is gone. If the VM stayed up since the job
      # started, that is a real failure, not a preemption: stop rather than loop.
      if [ "$started" = 1 ] && [ "$booted" = 0 ]; then
        # The job may have finished between the done check above and this one.
        remote "cd ~/rails-model-lab && $DONE" >/dev/null 2>&1 && continue
        log "job failed"; remote "cd ~/rails-model-lab && tail -25 $LOGS/run.log $LOGS/serve.log ${RUNS:-}.log 2>/dev/null"
        stop_vm; exit 1
      fi
      (cd "$REPO" && VM_NAME="$VM" bash baseline/push.sh >/dev/null 2>&1) || { log "push failed"; continue; }
      remote "cd ~/rails-model-lab && mkdir -p $LOGS && QWEN=qwen3.5-27b bash baseline/provision.sh > $LOGS/provision.log 2>&1" \
        || { log "provision failed"; continue; }
      remote "cd ~/rails-model-lab && $JOB" && { started=1 booted=0; log "job started"; } ;;
    *) log "ssh lost, rechecking" ;;  # neither marker: SSH itself failed, e.g. a preemption
  esac
  sleep 120
done
log "deadline reached"; stop_vm
