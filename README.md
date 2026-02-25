# Nextcloud on IONOS Managed Kubernetes

Deploy [Nextcloud](https://nextcloud.com/) on [IONOS Managed Kubernetes](https://cloud.ionos.com/managed-kubernetes) using [IONOS DBaaS PostgreSQL](https://cloud.ionos.com/databases/postgresql) as the backend database.

> **Status:** 🚧 Work in progress

## Overview

This tutorial demonstrates how to deploy a production-ready Nextcloud instance on IONOS Cloud, combining:

- **IONOS Managed Kubernetes** — for running the Nextcloud application
- **IONOS DBaaS PostgreSQL** — managed database backend
- **IONOS Block Storage** — persistent storage for Nextcloud data
- **NGINX Ingress + cert-manager** — TLS termination with Let's Encrypt

## Architecture

```
Internet
   │
   ▼
[DNS / Domain]
   │
   ▼
[NGINX Ingress Controller]  ←  [cert-manager / Let's Encrypt]
   │
   ▼
[Nextcloud Pods]
   │              │
   ▼              ▼
[PVC / Block   [IONOS DBaaS
  Storage]      PostgreSQL]
```

## Prerequisites

- IONOS Cloud account
- IONOS Managed Kubernetes cluster (v1.29+)
- `kubectl` configured and connected to your cluster
- `helm` v3 installed
- IONOS DBaaS PostgreSQL instance
- A domain name pointing to your cluster's load balancer IP

## Repository Structure

```
├── manifests/
│   ├── 01-namespace/         # Namespace definition
│   ├── 02-storage/           # PersistentVolumeClaim for Nextcloud data
│   ├── 03-database/          # Secret for DBaaS PostgreSQL credentials
│   ├── 04-nextcloud/         # Nextcloud Deployment + Service
│   └── 05-ingress/           # Ingress + TLS Certificate
├── helm/
│   ├── values-basic.yaml     # Minimal setup (dev/test)
│   └── values-production.yaml # Production-ready configuration
└── docs/
    └── architecture.md       # Detailed architecture notes
```

## Deployment Options

### Option A: Helm Chart (Recommended)

```bash
helm repo add nextcloud https://nextcloud.github.io/helm/
helm repo update

helm install nextcloud nextcloud/nextcloud \
  --namespace nextcloud \
  --create-namespace \
  -f helm/values-production.yaml
```

### Option B: Raw YAML Manifests

```bash
kubectl apply -f manifests/01-namespace/
kubectl apply -f manifests/02-storage/
kubectl apply -f manifests/03-database/
kubectl apply -f manifests/04-nextcloud/
kubectl apply -f manifests/05-ingress/
```

## Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/rdelarrearemiro-ionos/nextcloud-on-ionos-managed-kubernetes.git
   cd nextcloud-on-ionos-managed-kubernetes
   ```

2. **Create your DBaaS PostgreSQL instance** in the [IONOS DCD](https://dcd.ionos.com) or via API

3. **Configure your credentials**
   ```bash
   cp manifests/03-database/dbaas-secret.yaml.example manifests/03-database/dbaas-secret.yaml
   # Edit dbaas-secret.yaml with your DBaaS connection details
   ```

4. **Deploy**
   ```bash
   kubectl apply -f manifests/
   ```

5. **Access Nextcloud** at your configured domain

## Tested With

| Component | Version |
|---|---|
| IONOS Managed Kubernetes | 1.29+ |
| Nextcloud | 32.x |
| Nextcloud Helm Chart | 8.x |
| cert-manager | 1.19 |
| NGINX Ingress Controller | 1.14 |

## Related Resources

- [IONOS Managed Kubernetes Docs](https://docs.ionos.com/cloud/containers/managed-kubernetes)
- [IONOS DBaaS PostgreSQL Docs](https://docs.ionos.com/cloud/databases/postgresql)
- [Nextcloud Helm Chart](https://github.com/nextcloud/helm)
- [cert-manager Docs](https://cert-manager.io/docs/)

## License

MIT
