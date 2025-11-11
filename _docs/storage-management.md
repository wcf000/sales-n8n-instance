# Storage Management Guide

## Overview

This guide covers storage management for the self-hosted n8n platform, including volume configuration, data persistence, and storage best practices.

## Volume Structure

### External Volumes

The platform uses Docker volumes for persistent data storage:

| Volume | Mount Point | Purpose | Data Stored |
|--------|-------------|---------|-------------|
| `n8n_storage` | `/home/node/.n8n` | n8n configuration | Workflows, credentials, settings |
| `n8n_data` | `/data` | Workflow exports | JSON workflow exports, shared data |
| `n8n_scripts` | `/root/.n8n/scripts` | Python scripts | Custom Python scripts and utilities |
| `postgres_storage` | `/var/lib/postgresql/data` | Database | PostgreSQL data files |
| `ollama_storage` | `/root/.ollama` | LLM models | Downloaded Ollama models |
| `qdrant_storage` | `/qdrant/storage` | Vector database | Qdrant vector data |
| `redis_storage` | Redis data | Cache/Queue | Redis data files |
| `minio_storage` | `/data` | Object storage | MinIO object storage (optional) |

### Volume Mount Points

```
/home/node/.n8n          → n8n_storage (config & credentials)
/data                     → n8n_data (workflow JSON exports)
/root/.n8n/scripts        → n8n_scripts (Python environment scripts)
/var/lib/postgresql/data  → postgres_storage (database)
/root/.ollama             → ollama_storage (LLM models)
/qdrant/storage           → qdrant_storage (vector database)
```

## Volume Setup

### Initial Setup

Run the volume setup script to initialize all volumes:

```bash
./scripts/setup-volumes.sh
```

This script will:
- Create all required Docker volumes
- Set proper permissions
- Create local directories for bind mounts
- Display volume information

### Manual Volume Creation

```bash
# Create volumes manually
docker volume create self-hosted-ai-starter-kit_n8n_storage
docker volume create self-hosted-ai-starter-kit_n8n_data
docker volume create self-hosted-ai-starter-kit_n8n_scripts
docker volume create self-hosted-ai-starter-kit_postgres_storage
docker volume create self-hosted-ai-starter-kit_ollama_storage
docker volume create self-hosted-ai-starter-kit_qdrant_storage
docker volume create self-hosted-ai-starter-kit_redis_storage
docker volume create self-hosted-ai-starter-kit_minio_storage
```

## Data Persistence

### Workflow Data

Workflows are stored in:
- **Database**: PostgreSQL (`postgres_storage` volume)
- **Exports**: `/data` directory (`n8n_data` volume)

### Credentials

Encrypted credentials are stored in:
- **Location**: `/home/node/.n8n` (`n8n_storage` volume)
- **Encryption**: Uses `N8N_ENCRYPTION_KEY` from `.env`

### Python Scripts

Custom Python scripts should be placed in:
- **Location**: `/root/.n8n/scripts` (`n8n_scripts` volume)
- **Access**: Available to Execute Command nodes

## Volume Management

### Inspect Volumes

```bash
# List all volumes
docker volume ls | grep self-hosted-ai-starter-kit

# Inspect specific volume
docker volume inspect self-hosted-ai-starter-kit_n8n_storage

# View volume size
docker system df -v
```

### Backup Volumes

```bash
# Backup specific volume
docker run --rm \
  -v self-hosted-ai-starter-kit_n8n_storage:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/n8n-storage-$(date +%Y%m%d).tar.gz -C /data .

# Backup all volumes
./scripts/backup.sh
```

### Restore Volumes

```bash
# Restore specific volume
docker run --rm \
  -v self-hosted-ai-starter-kit_n8n_storage:/data \
  -v $(pwd)/backups:/backup \
  alpine sh -c "cd /data && rm -rf * && tar xzf /backup/n8n-storage-20240115.tar.gz"

# Restore all volumes
./scripts/restore.sh backups/2024-01-15/ --volumes
```

### Remove Volumes

⚠️ **Warning**: This will delete all data in the volume!

```bash
# Stop services first
docker compose down

# Remove specific volume
docker volume rm self-hosted-ai-starter-kit_n8n_storage

# Remove all volumes (use with caution!)
docker compose down -v
```

## Storage Best Practices

### Regular Backups

1. **Automated Backups**: Set up cron job for daily backups
2. **Off-site Storage**: Upload backups to S3/MinIO
3. **Retention Policy**: Keep 30 days of backups
4. **Verification**: Regularly test restore procedures

### Disk Space Management

1. **Monitor Usage**: Check volume sizes regularly
2. **Clean Old Data**: Prune execution history (see Performance guide)
3. **Archive Workflows**: Export and archive old workflows
4. **Clean Logs**: Remove old log files

### Security

1. **Encryption**: Use encrypted volumes for sensitive data
2. **Access Control**: Restrict access to volume data
3. **Backup Encryption**: Encrypt backups containing credentials
4. **Audit Logs**: Monitor volume access

## Volume Migration

### Moving Volumes Between Hosts

1. **Export Volume**:
   ```bash
   docker run --rm \
     -v self-hosted-ai-starter-kit_n8n_storage:/data \
     -v $(pwd):/backup \
     alpine tar czf /backup/n8n-storage.tar.gz -C /data .
   ```

2. **Transfer Archive**: Copy `.tar.gz` file to new host

3. **Import Volume**:
   ```bash
   docker volume create self-hosted-ai-starter-kit_n8n_storage
   docker run --rm \
     -v self-hosted-ai-starter-kit_n8n_storage:/data \
     -v $(pwd):/backup \
     alpine sh -c "cd /data && tar xzf /backup/n8n-storage.tar.gz"
   ```

### Upgrading n8n

When upgrading n8n, volumes persist automatically:

1. Pull new image: `docker compose pull n8n`
2. Restart services: `docker compose up -d`
3. Volumes remain intact with all data

## Troubleshooting

### Volume Not Mounting

```bash
# Check volume exists
docker volume ls | grep n8n_storage

# Check container mounts
docker inspect n8n | grep -A 10 Mounts

# Verify permissions
docker compose exec n8n ls -la /home/node/.n8n
```

### Permission Issues

```bash
# Fix permissions (run as root in container)
docker compose exec -u root n8n chown -R node:node /home/node/.n8n
docker compose exec -u root n8n chown -R node:node /data
```

### Volume Full

```bash
# Check volume size
docker system df -v

# Clean up old data
docker compose exec n8n find /data -type f -mtime +30 -delete

# Prune unused volumes (careful!)
docker volume prune
```

## Resources

- [Docker Volume Documentation](https://docs.docker.com/storage/volumes/)
- [n8n Data Storage](https://docs.n8n.io/hosting/configuration/#data-storage)
- [PostgreSQL Data Directory](https://www.postgresql.org/docs/current/storage-file-layout.html)

