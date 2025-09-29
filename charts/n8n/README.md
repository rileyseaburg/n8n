# n8n Helm Chart

This Helm chart deploys [n8n](https://n8n.io), a workflow automation platform, on Kubernetes.

## Introduction

n8n is a low-code platform for workflow automation and data integration. It allows you to connect anything to everything via its open, fair-code model.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (if persistence is enabled)

## Installing the Chart

To install the chart with the release name `my-n8n`:

```bash
helm repo add n8n https://charts.n8n.io  # (when available)
helm install my-n8n n8n/n8n
```

Or install directly from this repository:

```bash
helm install my-n8n ./charts/n8n
```

## Uninstalling the Chart

To uninstall/delete the `my-n8n` deployment:

```bash
helm delete my-n8n
```

## Configuration

The following table lists the configurable parameters of the n8n chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `""` |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]` |
| `global.storageClass` | Global StorageClass for Persistent Volume(s) | `""` |

### n8n Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | n8n image registry | `docker.n8n.io` |
| `image.repository` | n8n image repository | `n8nio/n8n` |
| `image.tag` | n8n image tag | `latest` |
| `image.pullPolicy` | n8n image pull policy | `IfNotPresent` |
| `image.pullSecrets` | n8n image pull secrets | `[]` |

### Deployment Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of n8n replicas | `1` |
| `executionMode` | n8n execution mode (`main` or `queue`) | `main` |

### Queue Mode Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `queue.workerCount` | Number of worker replicas (queue mode only) | `2` |
| `queue.redis.external` | Use external Redis instance | `false` |
| `queue.redis.host` | Redis host (when external) | `""` |
| `queue.redis.port` | Redis port | `6379` |
| `queue.redis.password` | Redis password | `""` |
| `queue.redis.username` | Redis username | `""` |
| `queue.redis.database` | Redis database number | `0` |
| `queue.redis.deploy` | Deploy Redis as part of this chart | `true` |

### Database Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.type` | Database type (`sqlite`, `postgresdb`, `mysqldb`, `mariadb`) | `sqlite` |
| `database.postgresql.external` | Use external PostgreSQL instance | `false` |
| `database.postgresql.host` | PostgreSQL host (when external) | `""` |
| `database.postgresql.port` | PostgreSQL port | `5432` |
| `database.postgresql.database` | PostgreSQL database name | `n8n` |
| `database.postgresql.username` | PostgreSQL username | `n8n` |
| `database.postgresql.password` | PostgreSQL password | `""` |
| `database.postgresql.schema` | PostgreSQL schema | `public` |
| `database.postgresql.ssl` | Enable SSL for PostgreSQL | `false` |
| `database.postgresql.deploy` | Deploy PostgreSQL as part of this chart | `false` |

### n8n Configuration Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `n8n.encryptionKey` | Encryption key for credentials (auto-generated if empty) | `""` |
| `n8n.host` | n8n host | `0.0.0.0` |
| `n8n.port` | n8n port | `5678` |
| `n8n.protocol` | n8n protocol | `http` |
| `n8n.userFolder` | n8n user data folder | `/home/node/.n8n` |
| `n8n.diagnosticsEnabled` | Enable diagnostics | `false` |
| `n8n.taskRunners.enabled` | Enable task runners | `true` |
| `n8n.taskRunners.mode` | Task runner mode | `internal` |
| `n8n.taskRunners.python.enabled` | Enable Python task runner | `true` |
| `n8n.executions.timeout` | Default execution timeout (seconds) | `3600` |
| `n8n.executions.concurrencyProduction` | Production concurrency limit | `10` |

### Service Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Target port | `5678` |
| `service.annotations` | Service annotations | `{}` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress controller resource | `false` |
| `ingress.className` | IngressClass name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hostnames and paths | `[{host: n8n.local, paths: [{path: /, pathType: Prefix}]}]` |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Persistence Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class name | `""` |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Storage size | `1Gi` |
| `persistence.annotations` | PVC annotations | `{}` |
| `persistence.existingClaim` | Use existing PVC | `""` |

### Resource Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources` | CPU/Memory resource requests/limits | `{}` |
| `workerResources` | Worker CPU/Memory resource requests/limits | `{}` |

### Autoscaling Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable horizontal pod autoscaler | `false` |
| `autoscaling.minReplicas` | Minimum number of replicas | `1` |
| `autoscaling.maxReplicas` | Maximum number of replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU utilization percentage | `80` |
| `autoscaling.targetMemoryUtilizationPercentage` | Target memory utilization percentage | `80` |

### Security Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.annotations` | Service account annotations | `{}` |
| `serviceAccount.name` | Service account name | `""` |
| `podSecurityContext` | Pod security context | See values.yaml |
| `securityContext` | Container security context | See values.yaml |

## Examples

### Basic Installation

```bash
helm install my-n8n ./charts/n8n
```

### External Database Connection (Simple)

To connect to an external database server, you just need to provide the IP, database name, and password:

```bash
# PostgreSQL
helm install my-n8n ./charts/n8n \
  --set database.type=postgresdb \
  --set database.postgresql.external=true \
  --set database.postgresql.host="192.168.1.100" \
  --set database.postgresql.database="n8n" \
  --set database.postgresql.password="your-password"

# MySQL
helm install my-n8n ./charts/n8n \
  --set database.type=mysqldb \
  --set database.mysql.external=true \
  --set database.mysql.host="192.168.1.100" \
  --set database.mysql.database="n8n" \
  --set database.mysql.password="your-password"
```

Or use the external database example file:

```bash
helm install my-n8n ./charts/n8n -f charts/n8n/examples/values-external-db.yaml
```

### Installation with Chart-Deployed PostgreSQL

```bash
helm install my-n8n ./charts/n8n \
  --set database.type=postgresdb \
  --set database.postgresql.deploy=true \
  --set database.postgresql.password=mypassword
```

### Installation with Queue Mode

```bash
helm install my-n8n ./charts/n8n \
  --set executionMode=queue \
  --set queue.workerCount=3 \
  --set queue.redis.deploy=true
```

### Installation with Ingress

```bash
helm install my-n8n ./charts/n8n \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=n8n.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

## Upgrading

To upgrade the release:

```bash
helm upgrade my-n8n ./charts/n8n
```

## Configuration Files

You can find example configuration files in the `examples/` directory:

- `examples/values-basic.yaml` - Basic setup with SQLite
- `examples/values-postgres.yaml` - Setup with PostgreSQL
- `examples/values-queue.yaml` - Setup with queue mode and Redis
- `examples/values-production.yaml` - Production-ready setup

## Security Considerations

1. **Encryption Key**: Always set a custom encryption key in production
2. **Database Passwords**: Use strong passwords for database connections
3. **TLS**: Enable TLS/HTTPS for production deployments
4. **Network Policies**: Consider enabling network policies for security
5. **Resource Limits**: Set appropriate resource limits

## Troubleshooting

### Common Issues

1. **Pod not starting**: Check logs with `kubectl logs <pod-name>`
2. **Database connection issues**: Verify database configuration and credentials
3. **Persistent volume issues**: Check storage class and PVC status
4. **Ingress not working**: Verify ingress controller and DNS configuration

### Getting Help

- Check the [n8n documentation](https://docs.n8n.io)
- Visit the [n8n community forum](https://community.n8n.io)
- Review [GitHub issues](https://github.com/n8n-io/n8n/issues)

## License

This chart is released under the same license as n8n. See the [LICENSE](https://github.com/n8n-io/n8n/blob/master/LICENSE.md) file for details.