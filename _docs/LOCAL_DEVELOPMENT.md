# Local Development Guide

This guide explains how to set up and run the n8n platform locally for development.

## Prerequisites

- Docker Desktop (Windows/Mac) or Docker Engine + Docker Compose (Linux)
- Git
- 4GB+ RAM available
- 10GB+ disk space

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd self-hosted-ai-starter-kit
```

### 2. Create Environment File

Create a `.env` file in the project root:

```bash
# Copy the template (see SETUP.md for full template)
cat > .env <<EOF
POSTGRES_USER=n8n
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=n8n

N8N_ENCRYPTION_KEY=$(openssl rand -hex 16)
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

N8N_DIAGNOSTICS_ENABLED=false
N8N_PERSONALIZATION_ENABLED=false

N8N_HOST=0.0.0.0
N8N_PORT=5678

EXECUTIONS_MODE=regular

N8N_COMMUNITY_PACKAGES_ENABLED=true

TRAEFIK_DOMAIN=localhost
TRAEFIK_EMAIL=dev@localhost
TRAEFIK_BASIC_AUTH_USER=admin
TRAEFIK_BASIC_AUTH_PASSWORD_HASH=\$apr1\$test\$test

OLLAMA_HOST=ollama:11434
EOF
```

**Note**: For local development, you can use simple passwords. For production, use strong passwords.

### 3. Build Custom n8n Image

The first time, you need to build the custom n8n image with Python:

```bash
docker compose build n8n
```

This will take 5-10 minutes as it:
- Downloads the base n8n image
- Installs Python 3.11+
- Installs all Python packages from `requirements.txt`

### 4. Start Services

#### Option A: Start All Services (Recommended)

```bash
docker compose up -d
```

This starts:
- PostgreSQL (database)
- n8n (main application)
- Traefik (reverse proxy)
- Qdrant (vector database)
- Ollama (LLM - CPU mode)

#### Option B: Start Without Traefik (Direct Access)

If you don't need Traefik for local development:

```bash
docker compose up -d postgres n8n qdrant
```

Then access n8n directly at: `http://localhost:5678`

#### Option C: Start with GPU Support

If you have an NVIDIA GPU:

```bash
docker compose --profile gpu-nvidia build n8n
docker compose --profile gpu-nvidia up -d
```

### 5. Verify Services

Check that all services are running:

```bash
docker compose ps
```

You should see all services with "Up" status.

### 6. Access n8n

- **Direct Access**: http://localhost:5678
- **Via Traefik**: http://localhost (if Traefik is running)

### 7. Initial Setup

1. Open n8n in your browser
2. Create your admin account (first time only)
3. You're ready to create workflows!

## Development Workflow

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f n8n

# Last 100 lines
docker compose logs --tail=100 n8n
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart n8n
```

### Stop Services

```bash
docker compose down
```

### Rebuild After Changes

If you modify:
- `n8n/Dockerfile`
- `n8n/requirements.txt`

Rebuild the image:

```bash
docker compose build n8n
docker compose up -d n8n
```

### Update Python Packages

1. Edit `n8n/requirements.txt`
2. Rebuild: `docker compose build n8n`
3. Restart: `docker compose restart n8n`

### Test Python Environment

```bash
./_debug/validate-python.sh
```

## Common Development Tasks

### Add a New Python Package

1. Edit `n8n/requirements.txt`:
   ```
   new-package>=1.0.0
   ```

2. Rebuild and restart:
   ```bash
   docker compose build n8n
   docker compose restart n8n
   ```

3. Verify installation:
   ```bash
   docker compose exec n8n pip list | grep new-package
   ```

### Test a Python Script

1. Create a workflow in n8n
2. Add "Execute Command" node
3. Set command: `python3`
4. Set arguments: `-c "your_python_code_here"`
5. Execute the workflow

### Access Container Shell

```bash
# n8n container
docker compose exec n8n sh

# PostgreSQL
docker compose exec postgres psql -U n8n -d n8n
```

### View Database

```bash
docker compose exec postgres psql -U n8n -d n8n
```

Then run SQL queries:
```sql
SELECT * FROM workflow_entity;
SELECT * FROM credentials_entity;
```

### Import Demo Workflow

The demo workflow is automatically imported on first startup. Access it at:
- http://localhost:5678/workflow/srOnR8PAY3u4RSwb

## Troubleshooting

### Port Already in Use

If port 5678 is already in use:

1. Find the process:
   ```bash
   # Linux/Mac
   lsof -i :5678
   
   # Windows
   netstat -ano | findstr :5678
   ```

2. Stop the process or change the port in `.env`:
   ```
   N8N_PORT=5679
   ```

### Services Won't Start

1. Check logs:
   ```bash
   docker compose logs
   ```

2. Verify `.env` file exists and has all required variables

3. Check Docker resources:
   ```bash
   docker system df
   docker stats
   ```

### Python Not Available

1. Verify image was built:
   ```bash
   docker images | grep n8n
   ```

2. Rebuild:
   ```bash
   docker compose build --no-cache n8n
   docker compose up -d n8n
   ```

3. Check Python in container:
   ```bash
   docker compose exec n8n python3 --version
   ```

### Database Connection Issues

1. Verify PostgreSQL is running:
   ```bash
   docker compose ps postgres
   ```

2. Check database logs:
   ```bash
   docker compose logs postgres
   ```

3. Verify credentials in `.env` match

### Out of Disk Space

Clean up Docker:

```bash
# Remove unused images
docker image prune -a

# Remove unused volumes (CAREFUL: This removes data)
docker volume prune

# Full cleanup (removes everything not in use)
docker system prune -a --volumes
```

## Development Tips

### Hot Reload

n8n doesn't support hot reload. After code changes:
1. Rebuild image: `docker compose build n8n`
2. Restart: `docker compose restart n8n`

### Persistent Data

All data is stored in Docker volumes:
- `n8n_storage`: n8n workflows and credentials
- `postgres_storage`: Database data
- `qdrant_storage`: Vector database data
- `ollama_storage`: LLM models

Data persists between container restarts.

### Shared Folder

Files in `./shared` are accessible in n8n at `/data/shared`:
- Use this for file-based workflows
- Great for testing file operations

### Environment Variables

All environment variables are in `.env`. Changes require restart:
```bash
docker compose restart n8n
```

## Next Steps

- Read `_docs/QUICKSTART.md` for more details
- Check `_docs/python-environment.md` for Python usage
- Review `_docs/troubleshooting.md` for common issues
- Explore example workflows in `_debug/`

## Production vs Development

For local development:
- Use simple passwords in `.env`
- Traefik is optional
- Direct port access is fine
- No SSL needed

For production:
- Use strong passwords
- Enable Traefik with SSL
- Use worker mode for scaling
- Set up backups
- Configure monitoring

