# Deployment Guide

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Domain name (for production) or local DNS setup
- SSL certificate (Let's Encrypt recommended for production)

## Initial Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd self-hosted-ai-starter-kit
```

### 2. Environment Configuration

Copy the example environment file and configure:

```bash
cp .env.example .env
```

Edit `.env` and set the following required variables:

- `POSTGRES_USER`: Database username
- `POSTGRES_PASSWORD`: Strong database password
- `POSTGRES_DB`: Database name (default: `n8n`)
- `N8N_ENCRYPTION_KEY`: 32-character encryption key (generate with `openssl rand -hex 16`)
- `N8N_USER_MANAGEMENT_JWT_SECRET`: JWT secret (generate with `openssl rand -base64 32`)
- `TRAEFIK_DOMAIN`: Your domain name (e.g., `n8n.example.com`)
- `TRAEFIK_EMAIL`: Email for Let's Encrypt certificates

### 3. Generate Encryption Keys

```bash
# Generate N8N_ENCRYPTION_KEY
openssl rand -hex 16

# Generate N8N_USER_MANAGEMENT_JWT_SECRET
openssl rand -base64 32
```

### 4. Configure Traefik

For production with Let's Encrypt:
- Set `TRAEFIK_DOMAIN` in `.env`
- Set `TRAEFIK_EMAIL` in `.env`
- Ensure port 80 and 443 are accessible

For development:
- Use self-signed certificates
- Or disable SSL (not recommended)

### 5. Build Custom n8n Image

The custom n8n image includes Python and required packages:

```bash
docker compose build n8n
```

## Deployment Options

### Development Deployment

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop services
docker compose down
```

### Production Deployment

```bash
# Pull latest images
docker compose pull

# Build custom n8n image
docker compose build n8n

# Start services
docker compose up -d

# Verify services
docker compose ps
```

### GPU-Enabled Deployment

#### NVIDIA GPU

```bash
docker compose --profile gpu-nvidia up -d
```

#### AMD GPU (Linux)

```bash
docker compose --profile gpu-amd up -d
```

#### CPU Only

```bash
docker compose --profile cpu up -d
```

## Service Access

### n8n Web Interface

- **Via Traefik (Production)**: `https://<TRAEFIK_DOMAIN>`
- **Direct (Development)**: `http://localhost:5678`

### Traefik Dashboard

- **URL**: `http://localhost:8080`
- **Authentication**: Configured in Traefik config

### Service Ports

- **n8n**: 5678 (internal), 5679 (metrics)
- **PostgreSQL**: Internal only
- **Redis**: Internal only
- **Ollama**: 11434
- **Qdrant**: 6333
- **Traefik**: 80, 443, 8080
- **Prometheus**: 9090 (monitoring profile)
- **Grafana**: 3000 (monitoring profile)
- **MinIO**: 9000 (API), 9001 (Console) (minio profile)

## Initial Configuration

### 1. First Login

1. Access n8n via Traefik or direct port
2. Create admin account
3. Configure user management settings

### 2. Verify Python Environment

Run validation script:

```bash
./_debug/validate-python.sh
```

Or manually test in n8n:
1. Create workflow with Execute Command node
2. Run: `python3 --version`
3. Run: `python3 -c "import pandas; print('OK')"`

### 3. Import Demo Workflow

Demo workflow is automatically imported on first startup.

Access at: `http://localhost:5678/workflow/srOnR8PAY3u4RSwb`

## Worker Mode Setup

### Enable Worker Mode

1. Update `docker-compose.yml` to include worker services
2. Set `EXECUTIONS_MODE=queue` in environment
3. Configure Redis connection
4. Start main and worker services:

```bash
docker compose up -d n8n-main n8n-worker redis
```

### Verify Worker Mode

1. Check n8n UI for execution mode
2. Trigger a workflow
3. Verify execution shows worker instance

## Community Nodes Installation

1. Edit `n8n/community-nodes.json`
2. Add node package names
3. Restart n8n:

```bash
docker compose restart n8n
```

## Custom Nodes Installation

1. Build and publish custom node to NPM
2. Add package name to `n8n/community-nodes.json`
3. Restart n8n

See `_docs/custom-nodes.md` for detailed instructions.

## Upgrading

### Update Images

```bash
# Pull latest images
docker compose pull

# Rebuild custom n8n image
docker compose build n8n

# Restart services
docker compose up -d
```

### Database Migrations

n8n handles database migrations automatically on startup.

## Health Checks

### Container Health Status

The n8n container includes a built-in health check that monitors the `/healthz` endpoint:

```bash
# Check container health
docker compose ps

# View health check logs
docker inspect n8n | grep -A 10 Health
```

### Health Check Configuration

The health check is configured in the Dockerfile:
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Start Period**: 40 seconds (allows time for n8n to start)
- **Retries**: 3

### Manual Health Check

```bash
# Test health endpoint
curl http://localhost:5678/healthz

# From within container
docker compose exec n8n curl -f http://localhost:5678/healthz
```

## Monitoring

### Enable Monitoring Stack

Start Prometheus and Grafana with the monitoring profile:

```bash
docker compose --profile monitoring up -d prometheus grafana
```

### Access Monitoring

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
  - Default credentials: `admin` / `admin` (change on first login)

### n8n Metrics

n8n metrics are automatically exposed when `N8N_METRICS=true` (default):
- **Metrics Endpoint**: http://n8n:5679/metrics
- **Scraped by**: Prometheus (when monitoring profile is enabled)

### Grafana Dashboards

Pre-configured dashboards are available:
- **n8n Platform Monitoring**: Shows execution metrics, error rates, queue size

### Configure Monitoring

Add to `.env`:
```bash
# Monitoring
N8N_METRICS=true
N8N_METRICS_PORT=5679
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=your-secure-password
```

## Troubleshooting

### Services Not Starting

1. Check logs: `docker compose logs <service-name>`
2. Verify environment variables in `.env`
3. Check port conflicts: `netstat -tulpn | grep <port>`
4. Verify Docker resources (memory, disk)

### Python Not Available

1. Verify Dockerfile built correctly
2. Check container logs: `docker compose logs n8n`
3. Rebuild image: `docker compose build n8n`

### Traefik Not Routing

1. Check Traefik logs: `docker compose logs traefik`
2. Verify domain DNS points to server
3. Check Traefik configuration files
4. Verify SSL certificate generation

### Database Connection Issues

1. Verify PostgreSQL is healthy: `docker compose ps postgres`
2. Check database credentials in `.env`
3. Verify network connectivity
4. Check PostgreSQL logs: `docker compose logs postgres`

## Backup Before Deployment

Always backup before major deployments:

```bash
./scripts/backup.sh
```

## Rollback Procedure

1. Stop services: `docker compose down`
2. Restore database: `./scripts/restore.sh <backup-file>`
3. Restore volumes if needed
4. Start services: `docker compose up -d`

## Production Checklist

- [ ] Strong passwords in `.env`
- [ ] SSL/TLS certificates configured
- [ ] Firewall rules configured
- [ ] Backup strategy implemented
- [ ] Monitoring configured
- [ ] Worker mode enabled (if needed)
- [ ] Resource limits set
- [ ] Log rotation configured
- [ ] Security updates applied

