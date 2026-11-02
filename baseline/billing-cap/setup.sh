#!/usr/bin/env bash
# One-time setup: a budget on the trial credit window that stops every VM in the
# project when spend reaches CAP. Budgets alone only send email.
#
#   GCP_PROJECT=my-project BILLING_ACCOUNT=XXXXXX-XXXXXX-XXXXXX bash baseline/billing-cap/setup.sh
set -euo pipefail
cd "$(dirname "$0")"

PROJECT="${GCP_PROJECT:?set GCP_PROJECT}"
BILLING="${BILLING_ACCOUNT:?set BILLING_ACCOUNT}"
REGION=us-central1
CAP="${CAP:-260EUR}"
TOPIC=billing-cap
SA=billing-cap@$PROJECT.iam.gserviceaccount.com

gcloud pubsub topics describe $TOPIC --project $PROJECT >/dev/null 2>&1 \
  || gcloud pubsub topics create $TOPIC --project $PROJECT

gcloud iam service-accounts describe $SA --project $PROJECT >/dev/null 2>&1 \
  || gcloud iam service-accounts create billing-cap --project $PROJECT --display-name "Stops VMs at the billing cap"
gcloud projects add-iam-policy-binding $PROJECT --member "serviceAccount:$SA" \
  --role roles/compute.instanceAdmin.v1 --condition None >/dev/null
# New projects no longer let the default compute account build functions.
gcloud projects add-iam-policy-binding $PROJECT --member "serviceAccount:$SA" \
  --role roles/cloudbuild.builds.builder --condition None >/dev/null

gcloud functions deploy billing-cap --gen2 --project $PROJECT --region $REGION \
  --runtime python312 --source . --entry-point stop_on_cap \
  --trigger-topic $TOPIC --service-account $SA --trigger-service-account $SA \
  --build-service-account projects/$PROJECT/serviceAccounts/$SA \
  --set-env-vars PROJECT=$PROJECT --max-instances 1 --memory 256Mi
# The Pub/Sub trigger calls the function as $SA, which must be allowed to invoke it.
gcloud run services add-iam-policy-binding billing-cap --project $PROJECT --region $REGION \
  --member "serviceAccount:$SA" --role roles/run.invoker >/dev/null

# Credits are excluded, so this measures gross spend from the start of the trial.
gcloud billing budgets create --billing-account $BILLING --display-name "Trial credit cap" \
  --budget-amount $CAP --filter-projects projects/$PROJECT \
  --start-date 2026-11-01 --end-date 2027-01-31 --credit-types-treatment exclude-all-credits \
  --threshold-rule percent=0.5 --threshold-rule percent=0.9 --threshold-rule percent=1.0 \
  --notifications-rule-pubsub-topic projects/$PROJECT/topics/$TOPIC
