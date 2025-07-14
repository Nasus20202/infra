#!/bin/bash

set -e

echo "Installing ArgoCD"
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd -f argocd/values.yaml --create-namespace --namespace argocd --atomic
kubectl apply -f argocd-apps/argocd-infra-root-app.yaml
