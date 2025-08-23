# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a GitOps homelab repository managing Kubernetes clusters using [Flux](https://fluxcd.io/). The infrastructure and applications are declaratively managed through YAML manifests organized in a structured GitOps pattern.

## Architecture

### Directory Structure
- `clusters/` - Cluster-specific Flux configuration and bootstrapping
- `infrastructure/` - Infrastructure components (cert-manager, ingress, sealed-secrets)
  - `base/` - Base infrastructure components shared across clusters
  - `green/` - Cluster-specific infrastructure configurations (secrets)
- `apps/` - Application deployments organized by cluster
- `kubernetes/` - Cluster configuration files and bootstrapping scripts
- `vms/` - Cloud-init configurations for VMs

### Flux GitOps Pattern
- Infrastructure components are deployed first via `infrastructure.yaml` 
- Applications depend on infrastructure and are deployed via `apps.yaml`
- Each component uses Kustomization resources with proper dependency ordering
- Sealed Secrets are used for sensitive data management

## Common Commands

### Cluster Management
Set up environment for cluster operations:
```bash
export CLUSTER_NAME=green
source $(pwd)/kubernetes/clusters/.envs
```

Bootstrap Flux on a new cluster:
```bash
flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --kubeconfig=$(pwd)/kubernetes/clusters/$CLUSTER_NAME.conf \
  --owner=dkoshkin \
  --repository=homelab \
  --path=clusters/$CLUSTER_NAME \
  --read-write-key \
  --personal
```

### Secrets Management
Create sealed secrets for infrastructure components:
```bash
export CLUSTER_SEALED_SECRETS_DIR=infrastructure/$CLUSTER_NAME/secrets
export SEALED_SECRET_CERT=$CLUSTER_SEALED_SECRETS_DIR/sealed-secret-cert.pem
mkdir -p $CLUSTER_SEALED_SECRETS_DIR
```

Example: Create a sealed secret for Cloudflare API token:
```bash
kubectl create secret generic cloudflare-api-token \
  --namespace cert-manager \
  --from-literal api-token=$CLOUDFLARE_API_TOKEN \
  --dry-run=client \
  -o yaml | \
kubeseal \
  --format=yaml \
  --cert=$SEALED_SECRET_CERT \
  > $CLUSTER_SEALED_SECRETS_DIR/cloudflare-api-token.yaml
```

### Deployment Workflow
1. Make changes to YAML manifests in the appropriate directory
2. Commit and push changes to the main branch
3. Flux automatically detects changes and applies them to the cluster
4. Monitor deployments via Flux dashboard or kubectl

## Key Components

### Current Deployments (green cluster)
- **cert-manager** - TLS certificate management with Cloudflare DNS challenge
- **NGINX Ingress Controller** - Ingress traffic management  
- **Sealed Secrets** - Encrypted secret management
- **PostgreSQL** - Database for Teslamate
- **Teslamate** - Tesla vehicle data logging and analytics
- **ASP Fantasy** - Custom application with image automation
- **Flux Dashboard** - GitOps workflow visualization

### Dependencies
Infrastructure components have explicit dependency chains:
- cert-issuers depends on cert-manager
- applications depend on ingress-controller
- flux-dashboard depends on sealed-secrets-controller and ingress-controller

## Development Notes

- All infrastructure components use base configurations in `infrastructure/base/` with cluster-specific overlays
- Applications use Helm releases via Flux HelmRelease resources
- Image automation is configured for select applications (ASP Fantasy)
- Slack notifications are configured for deployment alerts
- Kubeconfig files are stored in `kubernetes/clusters/` directory