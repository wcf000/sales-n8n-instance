# Backup & Recovery Guide

## Overview

This guide covers backup and recovery procedures for your self-hosted n8n platform, including database backups, workflow exports, and disaster recovery.

## Backup Strategy

### Components to Backup

1. **PostgreSQL Database**: Workflows, credentials, execution history
2. **n8n Workflows**: JSON exports via API
3. **n8n Credentials**: Encrypted credential exports
4. **Docker Volumes**: Persistent data volumes
5. **Configuration Files**: `.env`, `docker-compose.yml`, Traefik configs

### Backup Frequency

- **Database**: Daily automated backups
- **Workflows**: Weekly exports
- **Configuration**: On every change
- **Full Backup**: Monthly

## Automated Backups

### Backup Script

The `scripts/backup.sh` script performs comprehensive backups:

```bash
./scripts/backup.sh
```

### Scheduled Backups

#### Using Cron

Add to crontab:

```bash
# Daily backup at 2 AM
0 2 * * * /path/to/scripts/backup.sh

# Weekly full backup on Sunday
0 3 * * 0 /path/to/scripts/backup.sh --full
```

#### Using Docker Cron

Create `scripts/cron-backup.sh`:

```bash
#!/bin/bash
cd /path/to/project
./scripts/backup.sh
```

Add to docker-compose.yml:

```yaml
backup-cron:
  image: alpine:latest
  volumes:
    - ./scripts:/scripts
    - ./backups:/backups
    - /var/run/docker.sock:/var/run/docker.sock
  command: >
    sh -c "
    apk add --no-cache dcron &&
    echo '0 2 * * * /scripts/backup.sh' | crontab - &&
    crond -f
    "
```

## Manual Backups

### Database Backup

#### PostgreSQL Dump

```bash
# Backup database
docker compose exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} > backup-$(date +%Y%m%d-%H%M%S).sql

# Compressed backup
docker compose exec postgres pg_dump -U ${POSTGRES_USER} ${POSTGRES_DB} | gzip > backup-$(date +%Y%m%d-%H%M%S).sql.gz
```

#### Volume Backup

```bash
# Backup PostgreSQL volume
docker run --rm \
  -v self-hosted-ai-starter-kit_postgres_storage:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/postgres-$(date +%Y%m%d-%H%M%S).tar.gz /data
```

### Workflow Export

#### Via API

```bash
# Get all workflows
curl -X GET https://n8n.example.com/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key" \
  -o workflows-$(date +%Y%m%d-%H%M%S).json

# Export specific workflow
curl -X GET https://n8n.example.com/api/v1/workflows/:id \
  -H "X-N8N-API-KEY: your-api-key" \
  -o workflow-:id-$(date +%Y%m%d-%H%M%S).json
```

#### Via UI

1. Open workflow in n8n UI
2. Click "Download" button
3. Save JSON file

### Credential Export

```bash
# Export credentials (requires authentication)
curl -X GET https://n8n.example.com/api/v1/credentials \
  -H "X-N8N-API-KEY: your-api-key" \
  -o credentials-$(date +%Y%m%d-%H%M%S).json
```

## Backup Storage

### Local Storage

Backups stored in `backups/` directory:

```
backups/
├── 2024-01-15/
│   ├── database-20240115-020000.sql.gz
│   ├── workflows-20240115-020000.json
│   └── volumes-20240115-020000.tar.gz
└── 2024-01-16/
    └── ...
```

### Remote Storage

#### AWS S3 Backup

The backup script automatically uploads to S3 if configured. Add to your `.env` file:

```bash
# AWS S3 Configuration
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_S3_BUCKET=your-bucket-name
AWS_REGION=us-east-1
```

The backup script will:
- Automatically upload all backup files to `s3://your-bucket/n8n-backups/TIMESTAMP/`
- Include S3 location in backup manifest
- Automatically cleanup backups older than 30 days from S3

**Manual S3 Upload:**

```bash
# Upload to S3 manually
aws s3 cp backups/ s3://your-bucket/n8n-backups/ --recursive
```

#### MinIO Local Object Storage

MinIO provides S3-compatible local storage. Enable it with:

```bash
# Start MinIO service
docker compose --profile minio up -d minio
```

Access MinIO Console at `http://localhost:9001` (default credentials: `minioadmin`/`minioadmin`)

Configure in `.env`:

```bash
# MinIO Configuration
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET=n8n-backups
MINIO_ENDPOINT_URL=http://minio:9000
```

The backup script will automatically use MinIO if `MINIO_BUCKET` is set.

**Create MinIO Bucket:**

1. Access MinIO Console: `http://localhost:9001`
2. Login with credentials
3. Create bucket: `n8n-backups`
4. Set bucket policy for backup script access

#### SFTP Backup

```bash
# Upload via SFTP
scp -r backups/ user@backup-server:/backups/n8n/
```

## Recovery Procedures

### Database Recovery

#### From SQL Dump

```bash
# Stop n8n
docker compose stop n8n

# Restore database
docker compose exec -T postgres psql -U ${POSTGRES_USER} ${POSTGRES_DB} < backup-20240115-020000.sql

# Start n8n
docker compose start n8n
```

#### From Compressed Dump

```bash
# Restore compressed backup
gunzip < backup-20240115-020000.sql.gz | docker compose exec -T postgres psql -U ${POSTGRES_USER} ${POSTGRES_DB}
```

### Volume Recovery

```bash
# Stop services
docker compose down

# Restore volume
docker run --rm \
  -v self-hosted-ai-starter-kit_postgres_storage:/data \
  -v $(pwd)/backups:/backup \
  alpine sh -c "cd /data && tar xzf /backup/postgres-20240115-020000.tar.gz --strip-components=1"

# Start services
docker compose up -d
```

### Workflow Import

#### Via API

```bash
# Import workflow
curl -X POST https://n8n.example.com/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d @workflow-20240115-020000.json
```

#### Via UI

1. Open n8n UI
2. Click "Import from File"
3. Select workflow JSON file
4. Import workflow

### Restore from S3/MinIO

The restore script can download and restore directly from S3 or MinIO:

```bash
# Restore from AWS S3
./scripts/restore.sh s3://your-bucket/n8n-backups/20240115-020000/

# Restore from MinIO
./scripts/restore.sh minio://n8n-backups/n8n-backups/20240115-020000/
```

The script will:
1. Download all backup files from cloud storage
2. Extract to temporary directory
3. Restore database, volumes, and workflows
4. Clean up temporary files

**Prerequisites:**
- Python3 and boto3 installed
- AWS credentials configured (for S3) or MinIO credentials (for MinIO)
- Network access to S3/MinIO endpoint

### Full System Recovery

#### Step 1: Restore Volumes

```bash
# Restore all volumes
./scripts/restore.sh backups/2024-01-15/ --volumes
```

#### Step 2: Restore Database

```bash
# Restore database
./scripts/restore.sh backups/2024-01-15/ --database
```

#### Step 3: Restore Workflows

```bash
# Import workflows
./scripts/restore.sh backups/2024-01-15/ --workflows
```

#### Step 4: Verify

1. Start services: `docker compose up -d`
2. Verify n8n UI accessible
3. Check workflows are present
4. Test workflow execution

## Disaster Recovery

### Complete System Failure

#### Scenario: Server Failure

1. **Provision New Server**
   - Install Docker and Docker Compose
   - Clone repository
   - Configure `.env` file

2. **Restore Backups**
   - Copy backup files to new server
   - Run restore script
   - Verify data integrity

3. **Start Services**
   - Start all services
   - Verify connectivity
   - Test workflows

#### Scenario: Data Corruption

1. **Stop Services**
   ```bash
   docker compose down
   ```

2. **Identify Last Good Backup**
   - Review backup logs
   - Select most recent backup before corruption

3. **Restore from Backup**
   - Restore database
   - Restore volumes if needed
   - Verify data

4. **Start Services**
   ```bash
   docker compose up -d
   ```

## Backup Verification

### Verify Backup Integrity

```bash
# Check SQL dump
gzip -t backup-20240115-020000.sql.gz

# Verify tar archive
tar -tzf volumes-20240115-020000.tar.gz > /dev/null

# Test restore (dry run)
gunzip < backup-20240115-020000.sql.gz | head -n 100
```

### Test Recovery

Regularly test recovery procedures:

1. Create test environment
2. Restore from backup
3. Verify all data present
4. Test workflow execution
5. Document any issues

## Retention Policy

### Default Retention

- **Daily Backups**: Keep 30 days
- **Weekly Backups**: Keep 12 weeks
- **Monthly Backups**: Keep 12 months

### Cleanup Script

```bash
# Remove backups older than 30 days
find backups/ -name "*.sql.gz" -mtime +30 -delete
find backups/ -name "*.tar.gz" -mtime +30 -delete
```

## Security

### Backup Encryption

Encrypt sensitive backups:

```bash
# Encrypt backup
gpg --encrypt --recipient your@email.com backup-20240115-020000.sql.gz

# Decrypt backup
gpg --decrypt backup-20240115-020000.sql.gz.gpg > backup-20240115-020000.sql.gz
```

### Access Control

- Restrict backup file permissions
- Use secure storage for backups
- Encrypt backups containing credentials
- Limit access to backup scripts

## Monitoring

### Backup Status

Monitor backup success:

```bash
# Check last backup
ls -lh backups/ | tail -1

# Verify backup script ran
grep "Backup completed" /var/log/backup.log
```

### Alerting

Set up alerts for:
- Backup failures
- Backup age (if too old)
- Disk space for backups
- Backup verification failures

## Resources

- [PostgreSQL Backup Documentation](https://www.postgresql.org/docs/current/backup.html)
- [n8n API Documentation](https://docs.n8n.io/api/)
- [Docker Volume Backup](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes)

