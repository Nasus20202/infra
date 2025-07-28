# My infrastructure

## Terraform

- [Remote S3 Terraform state](./terraform/remote-state)
- [Oracle Cloud Infrastructure (OCI)](./terraform/oci/)
  - [Compute](./terraform/oci/compute) - All compute resources
    - Virtual Cloud Network (VCN) with private and public subnet
    - 2 `VM.Standard.A1.Flex` instances each with 2 OCPU and 12 GB memory for RKE2 cluster

## Ansible

- [Oracle Cloud Infrastructure (OCI)](./ansible/oci/)
  - [Compute](./ansible/oci/compute)
    - [Cluster](./ansible/oci/compute/cluster) - RKE2 cluster with 2 nodes
      - Automated installation for both server and worker node

## Kubernetes

- [Oracle Cloud Infrastructure (OCI)](./kubernetes/oci/)
  - [Compute](./kubernetes/oci/compute)
    - [Cluster](./kubernetes/oci/compute/cluster) - K8s configuration for:
      - Upgrade controller - `system-upgrade-controller` for automated RKE2 upgrades
      - Cert manager - `cert-manager` for SSL certificates
      - Longhorn - `longhorn` block storage
      - Monitoring - Kube Prometheus Stack - `kube-prometheus-stack` with Prometheus and Grafana
      - Monitoring - Grafana Loki - `loki` for log collection
      - Monitoring - Grafana Tempo - `tempo` for distributed tracing
      - Monitoring - K8s Monitoring - `alloy` both as a logging agent and OpenTelemetry collector
      - ArgoCD - `argocd` for GitOps
