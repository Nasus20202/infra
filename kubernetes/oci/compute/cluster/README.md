# OCI - Compute - Cluster

Kubernetes configuration file for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

### Cert manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f cert-manager/clusterissuer -n cert-manager
```

### Monitoring

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml --create-namespace --namespace monitoring
```