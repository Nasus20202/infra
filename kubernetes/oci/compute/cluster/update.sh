#!/bin/bash

helm repo update

echo "Updating Upgrade controller"
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml

echo "Updating Cert Manager"
helm upgrade cert-manager jetstack/cert-manager --namespace cert-manager --set crds.enabled=true

echo "Updating Longhorn"
helm upgrade longhorn longhorn/longhorn -f longhorn/values.yaml --namespace longhorn-system

echo "Updating Monitoring"
helm upgrade prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml --namespace monitoring

echo "Updating Portainer"
helm upgrade portainer portainer/portainer -f portainer/values.yaml --namespace portainer

echo "Updating Argo CD"
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
