# OCI - Compute - Cluster

Kubernetes configuration file for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

### RKE2 configuration

- Enable TLS passthrough for the ingress controller.

```bash
kubectl apply -f rke2
```

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

### Argo CD

Setup GitOps for the cluster.

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd
```

Now you can configure and add the Argo CD application repository.

- [Argo CD - Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD - Add private repository](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/)
- [Argo CD - Declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
