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
helm install longhorn longhorn/longhorn -f longhorn/values.yaml --create-namespace --namespace longhorn-system
```

> [!NOTE]
> You might want to setup [recurring snapshots or filesystem trim jobs](https://longhorn.io/docs/1.8.0/snapshots-and-backups/scheduling-backups-and-snapshots/) for the Longhorn volumes.
> You can setup it via the Longhorn UI (`kubectl port-forward -n longhorn-system svc/longhorn-frontend 8000:80` and open `http://localhost:8000`).

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
