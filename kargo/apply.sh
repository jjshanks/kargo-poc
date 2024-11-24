#!/bin/bash

set -a
source .env
set +a

missing_vars=()

# Check each required variable
[[ -z "${GITOPS_REPO_URL}" ]] && missing_vars+=("GITOPS_REPO_URL")
[[ -z "${GITHUB_USERNAME}" ]] && missing_vars+=("GITHUB_USERNAME")
[[ -z "${GITHUB_PAT}" ]] && missing_vars+=("GITHUB_PAT")

# If any variables are missing, print error and exit
if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "Error: The following required environment variables are not set:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

if [ ! -x "./kargo" ]; then
    arch=$(uname -m)
    [ "$arch" = "x86_64" ] && arch=amd64
    curl -L -o kargo https://github.com/akuity/kargo/releases/latest/download/kargo-$(uname -s | tr '[:upper:]' '[:lower:]')-${arch}
    chmod +x kargo
fi

envsubst < project.yaml | ./kargo apply -f -
envsubst < secrets.yaml | ./kargo apply -f -
envsubst < warehouse.yaml | ./kargo apply -f -
envsubst < stages.yaml | ./kargo apply -f -