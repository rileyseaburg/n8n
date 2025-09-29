# n8n Helm Chart Installation Guide

This guide provides step-by-step instructions for installing n8n on Kubernetes using Helm.

## Prerequisites

1. **Kubernetes cluster** (version 1.19+)
2. **Helm** (version 3.2.0+)
3. **kubectl** configured to communicate with your cluster
4. Sufficient cluster resources (CPU, memory, storage)

## Quick Start

### 1. Basic Installation

Install n8n with default settings (SQLite database, single instance):

```bash
# Add the chart repository (when available)
helm repo add n8n https://charts.n8n.io
helm repo update

# Install n8n
helm install my-n8n n8n/n8n
```

Or install directly from this repository:

```bash
# Clone the repository
git clone https://github.com/n8n-io/n8n.git
cd n8n

# Install the chart
helm install my-n8n ./charts/n8n
```

### 2. Access n8n

After installation, follow the instructions shown by the `helm install` command to access n8n:

```bash
# For ClusterIP service (default)
export POD_NAME=$(kubectl get pods -l "app.kubernetes.io/name=n8n,app.kubernetes.io/instance=my-n8n" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:5678
```

Then open http://localhost:8080 in your browser.

## Configuration Examples

### Example 1: External Database (Simple Setup)

Connect to your existing database server with just the IP, database name, and password:

```bash
# PostgreSQL database
helm install my-n8n ./charts/n8n \
  --set database.type=postgresdb \
  --set database.postgresql.external=true \
  --set database.postgresql.host="192.168.1.100" \
  --set database.postgresql.database="n8n" \
  --set database.postgresql.username="n8n" \
  --set database.postgresql.password="your-secure-password"

# MySQL database
helm install my-n8n ./charts/n8n \
  --set database.type=mysqldb \
  --set database.mysql.external=true \
  --set database.mysql.host="192.168.1.100" \
  --set database.mysql.database="n8n" \
  --set database.mysql.username="n8n" \
  --set database.mysql.password="your-secure-password"
```

Or use the external database example file:

```bash
helm install my-n8n ./charts/n8n -f charts/n8n/examples/values-external-db.yaml
```

### Example 2: Development Setup

Perfect for development and testing:

```bash
helm install dev-n8n ./charts/n8n \
  --values ./charts/n8n/examples/values-basic.yaml \
  --set persistence.size=5Gi
```

### Example 3: Chart-Deployed PostgreSQL

For better performance with built-in database:

```bash
helm install prod-n8n ./charts/n8n \
  --values ./charts/n8n/examples/values-postgres.yaml \
  --set n8n.encryptionKey="your-secure-32-character-key-here"
```

### Example 4: High-Availability Queue Mode

For high-throughput production environments:

```bash
helm install ha-n8n ./charts/n8n \
  --values ./charts/n8n/examples/values-queue.yaml \
  --set queue.workerCount=5 \
  --set n8n.encryptionKey="your-secure-32-character-key-here"
```

### Example 5: With Ingress and TLS

```bash
helm install web-n8n ./charts/n8n \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.hosts[0].host=n8n.yourdomain.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix \
  --set ingress.tls[0].secretName=n8n-tls \
  --set ingress.tls[0].hosts[0]=n8n.yourdomain.com
```

## Advanced Configuration

### Custom Values File

Create a custom values file for your specific needs:

```yaml
# my-values.yaml
replicaCount: 2
executionMode: main

database:
  type: postgresdb
  postgresql:
    external: true
    host: "my-postgres.example.com"
    password: "secure-password"

n8n:
  encryptionKey: "my-32-character-encryption-key-123"

resources:
  requests:
    cpu: 500m
    memory: 1Gi
  limits:
    cpu: 1000m
    memory: 2Gi

ingress:
  enabled: true
  className: "nginx"
  hosts:
    - host: n8n.example.com
      paths:
        - path: /
          pathType: Prefix
```

Install with your custom values:

```bash
helm install my-n8n ./charts/n8n -f my-values.yaml
```

### Environment-Specific Configurations

#### Development
- SQLite database
- Single instance
- No ingress
- Minimal resources

```bash
helm install dev-n8n ./charts/n8n \
  --set replicaCount=1 \
  --set database.type=sqlite \
  --set persistence.size=2Gi
```

#### Staging
- PostgreSQL database
- Single instance
- Basic ingress
- Moderate resources

```bash
helm install staging-n8n ./charts/n8n \
  --set database.type=postgresdb \
  --set database.postgresql.deploy=true \
  --set database.postgresql.password="staging-password" \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=n8n-staging.example.com
```

#### Production
- External PostgreSQL
- Queue mode with workers
- TLS ingress
- High resources
- Monitoring enabled

```bash
helm install prod-n8n ./charts/n8n \
  --set executionMode=queue \
  --set queue.workerCount=3 \
  --set database.type=postgresdb \
  --set database.postgresql.external=true \
  --set database.postgresql.host="prod-postgres.example.com" \
  --set database.postgresql.password="prod-secure-password" \
  --set ingress.enabled=true \
  --set ingress.className=nginx \
  --set ingress.annotations."cert-manager\.io/cluster-issuer"=letsencrypt-prod \
  --set ingress.hosts[0].host=n8n.example.com \
  --set ingress.tls[0].secretName=n8n-tls \
  --set ingress.tls[0].hosts[0]=n8n.example.com
```

## Upgrading

### Upgrade the Release

```bash
# Update to latest chart version
helm repo update
helm upgrade my-n8n n8n/n8n

# Or upgrade with new values
helm upgrade my-n8n ./charts/n8n -f my-updated-values.yaml
```

### Backup Before Upgrade

Always backup your data before upgrading:

```bash
# For SQLite installations
kubectl exec -it deployment/my-n8n -- tar czf - /home/node/.n8n > n8n-backup.tar.gz

# For PostgreSQL installations
kubectl exec -it deployment/my-n8n-postgresql -- pg_dump -U n8n n8n > n8n-db-backup.sql
```

## Monitoring and Maintenance

### Health Checks

Check the status of your n8n installation:

```bash
# Check pods
kubectl get pods -l app.kubernetes.io/name=n8n

# Check services
kubectl get services -l app.kubernetes.io/name=n8n

# Check ingress (if enabled)
kubectl get ingress -l app.kubernetes.io/name=n8n

# View logs
kubectl logs -f deployment/my-n8n
```

### Scaling

Scale the number of replicas:

```bash
# Scale main instance
kubectl scale deployment my-n8n --replicas=3

# Scale workers (queue mode only)
kubectl scale deployment my-n8n-worker --replicas=5
```

Or use Helm:

```bash
helm upgrade my-n8n ./charts/n8n --set replicaCount=3 --set queue.workerCount=5
```

## Troubleshooting

### Common Issues

1. **Pod not starting**
   ```bash
   kubectl describe pod <pod-name>
   kubectl logs <pod-name>
   ```

2. **Database connection issues**
   ```bash
   # Check database pod (if deployed)
   kubectl logs deployment/my-n8n-postgresql
   
   # Test connection from n8n pod
   kubectl exec -it deployment/my-n8n -- nc -zv <db-host> <db-port>
   ```

3. **Persistent volume issues**
   ```bash
   kubectl get pvc
   kubectl describe pvc my-n8n
   ```

4. **Ingress not working**
   ```bash
   kubectl get ingress
   kubectl describe ingress my-n8n
   
   # Check ingress controller
   kubectl get pods -n ingress-nginx
   ```

### Reset Installation

To completely reset your installation:

```bash
# Delete the release
helm uninstall my-n8n

# Delete persistent volumes (WARNING: This deletes all data!)
kubectl delete pvc -l app.kubernetes.io/name=n8n
```

## Security Considerations

1. **Always set a custom encryption key** in production
2. **Use strong database passwords**
3. **Enable TLS/HTTPS** for production deployments
4. **Configure network policies** for security isolation
5. **Set resource limits** to prevent resource exhaustion
6. **Keep the chart and images updated**

## Getting Help

- [n8n Documentation](https://docs.n8n.io)
- [n8n Community Forum](https://community.n8n.io)
- [GitHub Issues](https://github.com/n8n-io/n8n/issues)
- [Helm Chart Issues](https://github.com/n8n-io/n8n/issues)