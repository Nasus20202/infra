# OCI - Compute - Cluster

Kubernetes configuration file for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

### Upgrade controller

Setup automated upgrades for the cluster.

```bash
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/system-upgrade-controller.yaml
kubectl apply -f https://github.com/rancher/system-upgrade-controller/releases/latest/download/crd.yaml
kubectl apply -f upgrade-controller
```

### Cert manager

Setup SSL certificates for the cluster.

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --set crds.enabled=true
kubectl apply -f cert-manager/clusterissuer -n cert-manager
```

### Longhorn

Setup storage for the cluster.

```bash
helm repo add longhorn https://charts.longhorn.io
helm install longhorn longhorn/longhorn --create-namespace --namespace longhorn-system
```

### Monitoring

Setup monitoring for the cluster.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -f monitoring/values.yaml --create-namespace --namespace monitoring
```