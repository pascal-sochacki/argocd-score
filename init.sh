#!/bin/sh

# Name of the Kubernetes secret to store the state
STATE_SECRET_NAME="$ARGOCD_APP_NAME-state"
# The key within the secret that will hold the state file content
STATE_SECRET_KEY="state.yaml"
# Local path for the state file required by score-k8s
SCORE_STATE_FILE=".score-k8s/state.yaml"

DESTINATION_NAMESPACE="${ARGOCD_APP_NAMESPACE}"

score-k8s init

echo "Checking for existing state in secret '${STATE_SECRET_NAME}'..."
# Try to get the secret and decode its data. The command will fail if the secret doesn't exist.
if kubectl get secret "${STATE_SECRET_NAME}" -o jsonpath="{.data.${STATE_SECRET_KEY}}" >/dev/null 2>&1; then
  echo "Found existing state in secret. Restoring it to ${SCORE_STATE_FILE}"
  # The .score-k8s directory is created by the 'init' command above.
  kubectl get secret "${STATE_SECRET_NAME}" -o jsonpath="{.data.${STATE_SECRET_KEY}}" | base64 --decode > "${SCORE_STATE_FILE}"
else
  echo "No existing state secret found. Proceeding with a clean state."
fi

score-k8s generate ./score.yaml --namespace default

TRACKING_ID_VALUE="${ARGOCD_APP_NAME}:v1/Secret:${DESTINATION_NAMESPACE}/${STATE_SECRET_NAME}"

echo "Saving state to Kubernetes secret '${STATE_SECRET_NAME}'..."

kubectl create secret generic "${STATE_SECRET_NAME}" \
  --namespace "${DESTINATION_NAMESPACE}" \
  --from-file="${STATE_SECRET_KEY}=${SCORE_STATE_FILE}" \
  --dry-run=client -o yaml | \
  kubectl annotate -f - "argocd.argoproj.io/tracking-id=${TRACKING_ID_VALUE}" --local -o yaml | \
  kubectl apply -f -
