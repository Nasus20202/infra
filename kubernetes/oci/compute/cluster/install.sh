#!/bin/bash

echo "Installing RKE2 configuration"
kubectl apply -f rke2

echo "Installing Upgrade controller"
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
kubectl apply -f upgrade-controller

echo "Installing Cert manager"
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f cert-manager/clusterissuer -n cert-manager

echo "Installing Longhorn"
helm repo add longhorn https://charts.longhorn.io
helm install longhorn longhorn/longhorn -f longhorn/values.yaml --create-namespace --namespace longhorn-system

echo "Installing Monitoring"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml --create-namespace --namespace monitoring

echo "Installing Portainer"
helm repo add portainer https://portainer.github.io/k8s/
helm install portainer portainer/portainer -f portainer/values.yaml --create-namespace --namespace portainer

echo "Installing Argo CD"
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd
