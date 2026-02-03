#!/bin/bash

LONGHORN_SECRET_NAME="longhorn-backup-secret"
LONGHORN_NAMESPACE="longhorn-system"

set -e

echo "Creating Longhorn backup secret '$LONGHORN_SECRET_NAME' in namespace $LONGHORN_NAMESPACE"
(
    cd ../../../../terraform/oci/compute
    AWS_ACCESS_KEY_ID=$(terraform output -raw longhorn_backup_access_key_id)
    AWS_SECRET_ACCESS_KEY=$(terraform output -raw longhorn_backup_secret_access_key)
    AWS_ENDPOINTS=$(terraform output -raw longhorn_backup_s3_endpoint)
    BACKUP_TARGET=$(terraform output -raw longhorn_backup_target)

    kubectl create ns $LONGHORN_NAMESPACE || true
    kubectl delete secret $LONGHORN_SECRET_NAME --namespace $LONGHORN_NAMESPACE || true
    kubectl create secret generic "$LONGHORN_SECRET_NAME" \
        --namespace $LONGHORN_NAMESPACE \
        --from-literal=AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
        --from-literal=AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
        --from-literal=AWS_ENDPOINTS="$AWS_ENDPOINTS"

    echo "Use $LONGHORN_SECRET_NAME secret in Longhorn configuration for backup target $BACKUP_TARGET"
)

echo "Installing ArgoCD"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd -f applications/argocd/values.yaml --create-namespace --namespace argocd --atomic
kubectl apply -f applications/argocd/manifests/projects -n argocd
kubectl apply -f argocd-apps/argocd-infra-root-app.yaml -n argocd
