# Architecture Notes

## Components

### IONOS Managed Kubernetes
Hosts the Nextcloud application pods. The cluster handles:
- Pod scheduling and self-healing
- Horizontal scaling (if configured)
- Load balancer provisioning for the ingress

### IONOS DBaaS PostgreSQL
Managed PostgreSQL instance used as the Nextcloud database backend.
- Automated backups
- High availability (multi-replica)
- No database administration overhead
- Connected to the cluster via private network or public endpoint

### IONOS Block Storage (PVC)
Persistent volume for Nextcloud's data directory (`/var/www/html`).
Stores uploaded files, apps, and configuration.

### NGINX Ingress Controller
Routes external HTTPS traffic to the Nextcloud service.
Handles large file uploads via proxy buffer configuration.

### cert-manager + Let's Encrypt
Automates TLS certificate provisioning and renewal.

## Network Connectivity

```
User → DNS → Load Balancer (IONOS) → NGINX Ingress → Nextcloud Pod
                                                            │
                                              ┌─────────────┴──────────────┐
                                              ▼                             ▼
                                    PVC (Block Storage)        DBaaS PostgreSQL
```

## Storage Sizing Guidelines

| Use Case | Recommended PVC Size |
|---|---|
| Personal / test | 20–50 GB |
| Small team (< 10 users) | 100–500 GB |
| Medium team (10–50 users) | 500 GB – 2 TB |

## DBaaS PostgreSQL Sizing

| Use Case | Recommended Template |
|---|---|
| Dev / test | XS (1 vCPU, 2 GB RAM) |
| Small production | S (2 vCPU, 4 GB RAM) |
| Medium production | M (4 vCPU, 16 GB RAM) |

## Known IONOS-Specific Considerations

- Storage class `ionos-enterprise-hdd` is the default; use `ionos-enterprise-ssd` for better I/O performance
- DBaaS PostgreSQL connection requires the cluster nodes to be in the same datacenter location or connected via private LAN
- Load balancer IP assignment may take 2–5 minutes after ingress creation

## Security Checklist

- [ ] Use Kubernetes Secrets (not plain text) for all credentials
- [ ] Enable 2FA for the Nextcloud admin account post-install
- [ ] Set `NEXTCLOUD_TRUSTED_DOMAINS` to your exact domain
- [ ] Configure network policies to restrict pod-to-pod traffic
- [ ] Enable automatic security updates for Nextcloud
