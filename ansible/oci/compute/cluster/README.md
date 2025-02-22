# OCI - Compute - Cluster

This module provides a set of resources to manage a RKE2 cluster with 2 nodes created with this [Terraform script](../../../terraform/oci/compute/).

#### Playbooks

- [`configure-iptables.yml`](./configure-iptables.yaml) - Add non persistent iptables rules to allow traffic between nodes
- [`create-user.yaml`](./create-user.yaml) - Create a user with sudo privileges
- [`install-package.yaml`](./install-package.yaml) - Install a package on all nodes
- [`reboot.yaml`](./reboot.yaml) - Reboot all nodes
- [`setup-rke2.yaml`](./setup-rke2.yaml) - Install RKE2 on all nodes
- [`update.yaml`](./update.yaml) - Update all packages

#### Roles

- [`rke2-server`](./roles/rke2-server) - Install RKE2 on a server node
- [`rke2-worker`](./roles/rke2-worker) - Install RKE2 on a worker node

> [!WARNING]  
> Due to problem when using the `canal` network plugin, the `cilium` network plugin is used instead.