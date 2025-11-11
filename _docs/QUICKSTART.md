# Quick Start Guide

This guide will help you get your self-hosted n8n platform with Python execution up and running quickly.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- Git
- 4GB+ RAM available
- 10GB+ disk space

## Initial Setup

### 1. Clone and Navigate

```bash
git clone <repository-url>
cd self-hosted-ai-starter-kit
```

### 2. Create Environment File

Create a `.env` file in the project root:

```bash
# Copy the template (if available) or create manually
cp .env.example .env  # If .env.example exists
```

**Required Environment Variables:**

```bash
# PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=your_strong_password_here
POSTGRES_DB=n8n

# n8n Encryption Keys (generate these)
N8N_ENCRYPTION_KEY=$(openssl rand -hex 16)
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

# Traefik (for production)
TRAEFIK_DOMAIN=n8n.example.com
TRAEFIK_EMAIL=your-email@example.com

# Traefik Basic Auth (generate with: htpasswd -nb admin password | sed -e s/\\$/\\$\\$/g)
TRAEFIK_BASIC_AUTH_USER=admin
TRAEFIK_BASIC_AUTH_PASSWORD_HASH=$apr1$...
```

### 3. Generate Encryption Keys

```bash
# Generate N8N_ENCRYPTION_KEY
openssl rand -hex 16

# Generate N8N_USER_MANAGEMENT_JWT_SECRET
openssl rand -base64 32

# Generate Traefik Basic Auth Hash (requires htpasswd)
htpasswd -nb admin yourpassword | sed -e s/\\$/\\$\\$/g
```

### 4. Build Custom n8n Image

The custom image includes Python and required packages:

```bash
docker compose build n8n
```

This may take several minutes as it installs Python and all packages.

### 5. Start Services

#### Development (Direct Access)

```bash
docker compose up -d
```

Access n8n at: `http://localhost:5678`

#### Production (with Traefik)

```bash
docker compose up -d traefik n8n postgres qdrant
```

Access n8n at: `https://your-domain.com` (via Traefik)

#### With GPU Support

```bash
# NVIDIA GPU
docker compose --profile gpu-nvidia up -d

# AMD GPU (Linux)
docker compose --profile gpu-amd up -d

# CPU Only
docker compose --profile cpu up -d
```

### 6. Verify Installation

#### Check Services

```bash
docker compose ps
```

All services should show "Up" status.

#### Validate Python Environment

```bash
./_debug/validate-python.sh
```

This script verifies:
- Python 3.11+ is installed
- All required packages are available
- Python scripts can execute

#### Health Check

```bash
./_debug/monitoring/health-check.sh
```

### 7. Initial n8n Setup

1. Open n8n in your browser:
   - Direct: `http://localhost:5678`
   - Via Traefik: `https://your-domain.com`

2. Create your admin account

3. Import demo workflow (optional):
   - URL: `http://localhost:5678/workflow/srOnR8PAY3u4RSwb`

## Using Python in Workflows

### Basic Example

1. Create a new workflow
2. Add "Execute Command" node
3. Configure:
   - **Command**: `python3`
   - **Arguments**: `-c "import json; print(json.dumps({'test': 'success'}))"`
4. Execute the workflow

### Advanced Example with Pandas

```python
import pandas as pd
import json
import sys

# Read input from n8n
data = json.load(sys.stdin)

# Create DataFrame
df = pd.DataFrame(data)

# Process
result = {
    "rows": len(df),
    "columns": list(df.columns),
    "summary": df.describe().to_dict()
}

# Output
print(json.dumps(result, default=str))
```

## Worker Mode Setup

To enable distributed execution:

1. Update `.env`:
   ```bash
   EXECUTIONS_MODE=queue
   ```

2. Start with worker profile:
   ```bash
   docker compose --profile worker up -d
   ```

3. Scale workers:
   ```bash
   docker compose --profile worker up -d --scale n8n-worker=3
   ```

## Backup and Restore

### Create Backup

```bash
./scripts/backup.sh
```

Backups are stored in `./backups/YYYY-MM-DD/`

### Restore from Backup

```bash
./scripts/restore.sh backups/2024-01-15/database-20240115-020000.sql.gz
```

## Common Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n

# Last 100 lines
docker compose logs --tail=100 n8n
```

### Stop Services

```bash
docker compose down
```

### Restart Services

```bash
docker compose restart n8n
```

### Update Services

```bash
# Pull latest images
docker compose pull

# Rebuild custom n8n image
docker compose build n8n

# Restart
docker compose up -d
```

### Access Container Shell

```bash
# n8n container
docker compose exec n8n sh

# PostgreSQL
docker compose exec postgres psql -U n8n -d n8n
```

## Troubleshooting

### Python Not Available

1. Rebuild image: `docker compose build n8n`
2. Verify: `docker compose exec n8n python3 --version`

### Services Won't Start

1. Check logs: `docker compose logs <service-name>`
2. Verify `.env` file exists and has all required variables
3. Check port conflicts: `netstat -tulpn | grep <port>`

### Database Connection Issues

1. Verify PostgreSQL is running: `docker compose ps postgres`
2. Check credentials in `.env`
3. Review logs: `docker compose logs postgres`

### Traefik Not Routing

1. Check Traefik logs: `docker compose logs traefik`
2. Verify domain DNS points to server
3. Check SSL certificate generation

For more help, see `_docs/troubleshooting.md`

## Next Steps

- Read `_docs/deployment.md` for detailed deployment instructions
- Review `_docs/python-environment.md` for Python usage
- Check `_docs/architecture.md` for system overview
- Explore `_docs/custom-nodes.md` to create custom nodes

## Support

- [n8n Community Forum](https://community.n8n.io/)
- [n8n Documentation](https://docs.n8n.io/)
- Project Issues: [GitHub Issues](https://github.com/your-repo/issues)

