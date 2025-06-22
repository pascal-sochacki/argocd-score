#!/bin/sh

STATE_FILE_PATH="/data/$ARGOCD_APP_NAME/state.yaml"

score-k8s init

echo "Checking for existing state file at ${STATE_FILE_PATH}..."
if [ -f "$STATE_FILE_PATH" ]; then
  echo "Found existing state file. Restoring it to .score-k8s/state.yaml"
  # The .score-k8s directory is created by the 'init' command above.
  cp "$STATE_FILE_PATH" .score-k8s/state.yaml
else
  echo "No existing state file found. Proceeding with a clean state."
fi

score-k8s generate ./score.yaml --namespace default

mkdir -p "/data/$ARGOCD_APP_NAME"
cp .score-k8s/state.yaml "$STATE_FILE_PATH"

