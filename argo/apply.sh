#!/bin/bash

set -a
source .env
set +a

missing_vars=()

# Check each required variable
[[ -z "${ARGO_ADMIN_PASSWORD}" ]] && missing_vars+=("ARGO_ADMIN_PASSWORD")
[[ -z "${GITOPS_REPO_URL}" ]] && missing_vars+=("GITOPS_REPO_URL")

# If any variables are missing, print error and exit
if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "Error: The following required environment variables are not set:"
    printf '%s\n' "${missing_vars[@]}"
    exit 1
fi

if [ ! -x "./argocd" ]; then
    arch=$(uname -m)
    [ "$arch" = "x86_64" ] && arch=amd64
    curl -L -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-$(uname -s | tr '[:upper:]' '[:lower:]')-${arch}
    chmod +x argocd
fi

./argocd login 95hb91k8wvxnxwg0.cd.akuity.cloud --grpc-web --username admin --password ${ARGO_ADMIN_PASSWORD}
./argocd repo add ${GITOPS_REPO_URL}
./argocd appset create --upsert appset.yaml
