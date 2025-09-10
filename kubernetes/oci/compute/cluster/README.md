# OCI - Compute - Cluster

Kubernetes configuration files for the RKE2 cluster created with [this script](../../../../ansible/oci/compute/cluster/).

This cluster uses **ArgoCD** for GitOps-based deployment and management of all infrastructure applications.

## ArgoCD Applications

The cluster is managed through ArgoCD applications defined in the [`argocd-apps/`](argocd-apps/) directory:

- **ArgoCD** - GitOps controller and UI
- **Cert-Manager** - SSL certificate management
- **Longhorn** - Distributed storage system
- **Monitoring Stack** - Prometheus, Grafana, Loki, Tempo, and K8s monitoring
- **RKE2 Configs** - CNI and ingress controller configuration
- **Upgrade Controller** - Automated cluster upgrades

## Initial Setup

### Prerequisites

1. **ArgoCD Installation**: Install ArgoCD first using the manual installation script:

```bash
./install.sh
```

2. **Root Application**: Apply the root application to bootstrap all other applications:

```bash
kubectl apply -f argocd-apps/argocd-infra-root-app.yaml
```

## Configuration

### ArgoCD OIDC Authentication

ArgoCD is configured with OIDC authentication. Add the following to the `argocd-cm` ConfigMap:

```yaml
dex.config: |
  connectors:
  - type: oidc
    id: nasus-sso
    name: Nasus SSO
    config:
      issuer: [ISSUER_URL]
      clientID: [CLIENT_ID]
      clientSecret: $argocd-oidc-secret:clientSecret
      redirectURI: [REDIRECT_URI]
      scopes:
        - openid
        - profile
        - email
```

Client secret is stored in the `argocd-oidc-secret` Kubernetes secret with the key `clientSecret`. It should be created before applying the ArgoCD configuration.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: argocd-oidc-secret
  namespace: argocd
stringData:
  clientSecret: [YOUR_CLIENT_SECRET]
```

### ArgoCD Notifications

ArgoCD Discord webhook URL should be set in the `argocd-notifications-secret` secret. It should be created before applying the ArgoCD configuration. Webhook URL is stored in the `discord-webhook-url` key.
