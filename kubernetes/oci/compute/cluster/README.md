# OCI - Compute - Cluster

Kubernetes configuration file for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

Automated deployment is configured with a [Github Actions workflow](../../../../.github/workflows/kubernetes_oci_compute_cluster_deployment.yaml).

First installation should be applied with the [`install.sh`](install.sh) script, and subsequent updates can be applied with the [`update.sh`](update.sh) script.

### RKE2 configuration

- Cilium CNI

  - Enable Cilium CNI with BPF support.
  - Enable Prometheus ServiceMonitor.

- Nginx Ingress Controller
  - Enable TLS passthrough for the ingress controller.
  - Enable gzip compression.
  - Enable metrics.
  - Enable configuration snippets.
  - Enable real IP address forwarding.
  - Change the default backend to a custom one.

```bash
kubectl apply -f rke2
```

### Upgrade controller

Setup automated upgrades for the cluster.

```bash
kubectl apply -k upgrade-controller
```

### Cert manager

Setup SSL certificates for the cluster.

```bash
helm repo add jetstack https://charts.jetstack.io
helm install cert-manager jetstack/cert-manager -f cert-manager/values.yaml --create-namespace --namespace cert-manager
kubectl apply -f cert-manager/clusterissuer -n cert-manager
```

### Longhorn

Setup storage for the cluster.

```bash
helm repo add longhorn https://charts.longhorn.io
helm install longhorn longhorn/longhorn -f longhorn/values.yaml --create-namespace --namespace longhorn-system
# Optionally --set metrics.serviceMonitor.enabled=false to disable the Prometheus service monitor before installing the Kube Prometheus Stack.
```

> [!NOTE]
> You might want to setup [recurring snapshots or filesystem trim jobs](https://longhorn.io/docs/1.8.0/snapshots-and-backups/scheduling-backups-and-snapshots/) for the Longhorn volumes.
> You can setup it via the Longhorn UI (`kubectl port-forward -n longhorn-system svc/longhorn-frontend 8000:80` and open `http://localhost:8000`).

### Monitoring - Kube Prometheus Stack

Setup monitoring for the cluster.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -f monitoring/kube-prometheus-stack-values.yaml --create-namespace --namespace monitoring
```

### Monitoring - Grafana Loki

Setup log collection for the cluster.

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack -f monitoring/loki-values.yaml --create-namespace --namespace monitoring
```

### Monitoring - Grafana Tempo

Setup tracing for the cluster.

```bash
helm install tempo grafana/tempo -f monitoring/tempo-values.yaml --create-namespace --namespace monitoring
```

### Monitoring - Grafana K8s monitoring

Setup Alloy for Grafana.

```bash
helm install k8s-monitoring grafana/k8s-monitoring -f monitoring/k8s-monitoring-values.yaml --create-namespace --namespace monitoring
```

### Argo CD

Setup GitOps for the cluster.

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm install argocd argo/argo-cd -f argocd/values.yaml --create-namespace --namespace argocd
```

Now you can configure and add the Argo CD application repository.

- [Argo CD - Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Argo CD - Add private repository](https://argo-cd.readthedocs.io/en/stable/user-guide/private-repositories/)
- [Argo CD - Declarative setup](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
