#!/bin/bash

set -e

echo "Add Helm repos"
helm repo add jetstack https://charts.jetstack.io
helm repo add longhorn https://charts.longhorn.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo "Updating Upgrade controller"
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
kubectl apply -f upgrade-controller

echo "Updating Cert Manager"
helm upgrade cert-manager jetstack/cert-manager -f cert-manager/values.yaml --create-namespace --namespace cert-manager --atomic
kubectl apply -f cert-manager/clusterissuer -n cert-manager

echo "Updating Longhorn"
helm upgrade longhorn longhorn/longhorn -f longhorn/values.yaml --namespace longhorn-system --atomic

echo "Updating Monitoring - Kube Prometheus Stack"
helm upgrade prometheus prometheus-community/kube-prometheus-stack -f monitoring/kube-prometheus-stack-values.yaml --namespace monitoring --atomic

echo "Updating Monitoring - Loki"
helm upgrade loki grafana/loki -f monitoring/loki-values.yaml --namespace monitoring --atomic

echo "Updating Monitoring - Tempo"
helm upgrade tempo grafana/tempo -f monitoring/tempo-values.yaml --namespace monitoring --atomic

echo "Updating Monitoring - K8s Monitoring"
helm upgrade k8s-monitoring grafana/k8s-monitoring -f monitoring/k8s-monitoring-values.yaml --namespace monitoring --atomic

echo "Updating Argo CD"
helm upgrade argocd argo/argo-cd -f argocd/values.yaml --namespace argocd --atomic

echo "Updating RKE2 configuration"
kubectl apply -f rke2
