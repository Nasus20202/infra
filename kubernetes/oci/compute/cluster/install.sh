#!/bin/bash

echo "Add Helm repos"
helm repo add jetstack https://charts.jetstack.io
helm repo add longhorn https://charts.longhorn.io
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Installing Upgrade controller"
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
kubectl apply -f upgrade-controller

echo "Installing Cert manager"
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f cert-manager/clusterissuer -n cert-manager

echo "Installing Longhorn"
helm install longhorn longhorn/longhorn -f longhorn/values.yaml --create-namespace --namespace longhorn-system --set metrics.serviceMonitor.enabled=false

echo "Installing Monitoring - Kube Prometheus Stack"
helm install prometheus prometheus-community/kube-prometheus-stack -f monitoring/kube-prometheus-stack-values.yaml --create-namespace --namespace monitoring

echo "Installing Monitoring - Loki"
helm install loki grafana/loki -f monitoring/loki-values.yaml --create-namespace --namespace monitoring

echo "Installing Monitoring - Tempo"
helm install tempo grafana/tempo -f monitoring/tempo-values.yaml --create-namespace --namespace monitoring

echo "Installing Monitoring - K8s Monitoring"
helm install k8s-monitoring grafana/k8s-monitoring -f monitoring/k8s-monitoring-values.yaml --create-namespace --namespace monitoring

echo "Enable Longhorn metrics"
helm upgrade longhorn longhorn/longhorn -f longhorn/values.yaml --namespace longhorn-system

echo "Installing Argo CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd

echo "Installing RKE2 configuration"
kubectl apply -f rke2
