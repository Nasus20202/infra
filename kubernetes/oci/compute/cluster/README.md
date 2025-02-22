# OCI - Compute - Cluster

Kubernetes configuration file for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

### Cert manager

```bash

```

### Monitoring

```bash
kubectl create ns monitoring
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```