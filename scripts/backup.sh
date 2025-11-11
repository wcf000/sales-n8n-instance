#!/bin/bash
# Backup Script for n8n Platform
# This script creates comprehensive backups of the n8n instance

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DATE_DIR="${BACKUP_DIR}/$(date +%Y-%m-%d)"
COMPRESS="${COMPRESS:-true}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=== n8n Backup Script ==="
echo "Timestamp: $TIMESTAMP"
echo ""

# Create backup directories
mkdir -p "$BACKUP_DATE_DIR"

# Function to log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if services are running
if ! docker compose ps postgres | grep -q "Up"; then
    log_error "PostgreSQL container is not running"
    exit 1
fi

# 1. Backup PostgreSQL Database
log_info "Backing up PostgreSQL database..."
DB_BACKUP_FILE="${BACKUP_DATE_DIR}/database-${TIMESTAMP}.sql"

if docker compose exec -T postgres pg_dump -U "${POSTGRES_USER:-n8n}" "${POSTGRES_DB:-n8n}" > "$DB_BACKUP_FILE" 2>/dev/null; then
    log_info "Database backup created: $DB_BACKUP_FILE"
    
    if [ "$COMPRESS" = "true" ]; then
        log_info "Compressing database backup..."
        gzip "$DB_BACKUP_FILE"
        DB_BACKUP_FILE="${DB_BACKUP_FILE}.gz"
        log_info "Compressed backup: $DB_BACKUP_FILE"
    fi
else
    log_error "Failed to backup database"
    exit 1
fi

# 2. Backup Docker Volumes
log_info "Backing up Docker volumes..."

VOLUMES=(
    "self-hosted-ai-starter-kit_n8n_storage:/home/node/.n8n"
    "self-hosted-ai-starter-kit_postgres_storage:/var/lib/postgresql/data"
)

for volume_info in "${VOLUMES[@]}"; do
    VOLUME_NAME=$(echo "$volume_info" | cut -d: -f1)
    VOLUME_PATH=$(echo "$volume_info" | cut -d: -f2)
    
    if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
        log_info "Backing up volume: $VOLUME_NAME"
        VOLUME_BACKUP_FILE="${BACKUP_DATE_DIR}/volume-${VOLUME_NAME//\//_}-${TIMESTAMP}.tar.gz"
        
        docker run --rm \
            -v "$VOLUME_NAME:$VOLUME_PATH" \
            -v "$(pwd)/$BACKUP_DATE_DIR:/backup" \
            alpine tar czf "/backup/volume-${VOLUME_NAME//\//_}-${TIMESTAMP}.tar.gz" -C "$VOLUME_PATH" . 2>/dev/null
        
        if [ -f "$VOLUME_BACKUP_FILE" ]; then
            log_info "Volume backup created: $VOLUME_BACKUP_FILE"
        else
            log_warn "Failed to backup volume: $VOLUME_NAME"
        fi
    else
        log_warn "Volume not found: $VOLUME_NAME"
    fi
done

# 3. Export n8n Workflows (if API is available)
log_info "Exporting n8n workflows..."
WORKFLOWS_BACKUP_FILE="${BACKUP_DATE_DIR}/workflows-${TIMESTAMP}.json"

if docker compose ps n8n | grep -q "Up"; then
    # Try to export workflows via API if credentials are available
    if [ -n "$N8N_API_KEY" ] && [ -n "$N8N_URL" ]; then
        log_info "Exporting workflows via API..."
        curl -s -H "X-N8N-API-KEY: $N8N_API_KEY" \
            "${N8N_URL}/api/v1/workflows" > "$WORKFLOWS_BACKUP_FILE" 2>/dev/null || true
        
        if [ -s "$WORKFLOWS_BACKUP_FILE" ]; then
            log_info "Workflows exported: $WORKFLOWS_BACKUP_FILE"
        else
            log_warn "Workflow export via API failed or returned empty"
            rm -f "$WORKFLOWS_BACKUP_FILE"
        fi
    else
        log_warn "N8N_API_KEY or N8N_URL not set, skipping API export"
        log_info "Workflows are stored in the database backup"
    fi
else
    log_warn "n8n container is not running, skipping workflow export"
fi

# 4. Backup Configuration Files
log_info "Backing up configuration files..."
CONFIG_BACKUP_FILE="${BACKUP_DATE_DIR}/config-${TIMESTAMP}.tar.gz"

tar czf "$CONFIG_BACKUP_FILE" \
    docker-compose.yml \
    .env 2>/dev/null || log_warn "Some config files not found"

if [ -f "$CONFIG_BACKUP_FILE" ]; then
    log_info "Configuration backup created: $CONFIG_BACKUP_FILE"
fi

# 5. Create backup manifest
log_info "Creating backup manifest..."
MANIFEST_FILE="${BACKUP_DATE_DIR}/manifest-${TIMESTAMP}.txt"

cat > "$MANIFEST_FILE" <<EOF
n8n Backup Manifest
===================
Timestamp: $TIMESTAMP
Date: $(date)

Backup Contents:
- Database: $DB_BACKUP_FILE
- Volumes: $(ls -1 ${BACKUP_DATE_DIR}/volume-*-${TIMESTAMP}.tar.gz 2>/dev/null | wc -l) volume(s)
- Workflows: ${WORKFLOWS_BACKUP_FILE:-N/A}
- Configuration: ${CONFIG_BACKUP_FILE:-N/A}

System Information:
- Docker Version: $(docker --version)
- Docker Compose Version: $(docker compose version --short)
- Hostname: $(hostname)

Backup Location: $BACKUP_DATE_DIR
EOF

log_info "Manifest created: $MANIFEST_FILE"

# 6. Calculate backup size
BACKUP_SIZE=$(du -sh "$BACKUP_DATE_DIR" | cut -f1)
log_info "Total backup size: $BACKUP_SIZE"

# 7. Upload to S3 or MinIO (if configured)
if [ -n "$AWS_S3_BUCKET" ] || [ -n "$MINIO_BUCKET" ]; then
    log_info "Uploading backup to cloud storage..."
    
    # Determine if using MinIO or AWS S3
    if [ -n "$MINIO_BUCKET" ]; then
        # MinIO configuration
        ENDPOINT_URL="${MINIO_ENDPOINT_URL:-http://minio:9000}"
        ACCESS_KEY="${MINIO_ROOT_USER:-minioadmin}"
        SECRET_KEY="${MINIO_ROOT_PASSWORD:-minioadmin}"
        BUCKET="$MINIO_BUCKET"
        USE_MINIO=true
        log_info "Using MinIO: $ENDPOINT_URL"
    else
        # AWS S3 configuration
        ENDPOINT_URL=""
        ACCESS_KEY="${AWS_ACCESS_KEY_ID}"
        SECRET_KEY="${AWS_SECRET_ACCESS_KEY}"
        BUCKET="$AWS_S3_BUCKET"
        REGION="${AWS_REGION:-us-east-1}"
        USE_MINIO=false
        log_info "Using AWS S3: s3://$BUCKET (region: $REGION)"
    fi
    
    # Check if boto3 is available (Python script for S3 upload)
    if command -v python3 >/dev/null 2>&1; then
        # Create Python script for S3 upload
        UPLOAD_SCRIPT=$(mktemp)
        cat > "$UPLOAD_SCRIPT" <<PYTHON_SCRIPT
import os
import sys
import boto3
from botocore.exceptions import ClientError
from pathlib import Path

bucket = "$BUCKET"
endpoint_url = "$ENDPOINT_URL" if "$ENDPOINT_URL" else None
access_key = "$ACCESS_KEY"
secret_key = "$SECRET_KEY"
backup_dir = "$BACKUP_DATE_DIR"
timestamp = "$TIMESTAMP"
region = "${REGION:-us-east-1}"

# Configure S3 client
s3_config = {
    'aws_access_key_id': access_key,
    'aws_secret_access_key': secret_key,
}
if endpoint_url:
    s3_config['endpoint_url'] = endpoint_url
    s3_config['region_name'] = 'us-east-1'  # MinIO default
else:
    s3_config['region_name'] = region

s3_client = boto3.client('s3', **s3_config)

# Upload all files in backup directory
uploaded_files = []
failed_files = []

for file_path in Path(backup_dir).rglob('*'):
    if file_path.is_file():
        s3_key = f"n8n-backups/{timestamp}/{file_path.relative_to(backup_dir)}"
        try:
            s3_client.upload_file(str(file_path), bucket, s3_key)
            uploaded_files.append(s3_key)
            print(f"Uploaded: {s3_key}")
        except ClientError as e:
            failed_files.append((str(file_path), str(e)))
            print(f"Failed to upload {file_path}: {e}", file=sys.stderr)

# Update manifest with S3 location
manifest_path = Path(backup_dir) / f"manifest-{timestamp}.txt"
if manifest_path.exists():
    with open(manifest_path, 'a') as f:
        f.write(f"\\nS3 Location: s3://{bucket}/n8n-backups/{timestamp}/\\n")
        f.write(f"Uploaded Files: {len(uploaded_files)}\\n")

if failed_files:
    print(f"Failed to upload {len(failed_files)} file(s)", file=sys.stderr)
    sys.exit(1)
else:
    print(f"Successfully uploaded {len(uploaded_files)} file(s) to s3://{bucket}/n8n-backups/{timestamp}/")
PYTHON_SCRIPT
        
        # Run upload script
        if python3 "$UPLOAD_SCRIPT" 2>&1; then
            log_info "Backup uploaded successfully to cloud storage"
            
            # Update manifest with S3 location
            if [ -f "$MANIFEST_FILE" ]; then
                if [ -n "$MINIO_BUCKET" ]; then
                    echo "MinIO Location: $ENDPOINT_URL/$MINIO_BUCKET/n8n-backups/$TIMESTAMP/" >> "$MANIFEST_FILE"
                else
                    echo "S3 Location: s3://$AWS_S3_BUCKET/n8n-backups/$TIMESTAMP/" >> "$MANIFEST_FILE"
                fi
            fi
        else
            log_warn "Failed to upload backup to cloud storage (backup still exists locally)"
        fi
        
        rm -f "$UPLOAD_SCRIPT"
    else
        log_warn "Python3 not available, skipping cloud upload"
        log_info "Install Python3 and boto3 to enable cloud backup upload"
    fi
fi

# 8. Cleanup old backups (keep last 30 days locally)
if [ -d "$BACKUP_DIR" ]; then
    log_info "Cleaning up local backups older than 30 days..."
    find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    log_info "Local cleanup complete"
fi

# 9. Cleanup old S3 backups (if configured)
if [ -n "$AWS_S3_BUCKET" ] || [ -n "$MINIO_BUCKET" ]; then
    if command -v python3 >/dev/null 2>&1; then
        log_info "Cleaning up cloud backups older than 30 days..."
        
        CLEANUP_SCRIPT=$(mktemp)
        cat > "$CLEANUP_SCRIPT" <<PYTHON_SCRIPT
import boto3
from datetime import datetime, timedelta
from botocore.exceptions import ClientError

bucket = "$BUCKET"
endpoint_url = "$ENDPOINT_URL" if "$ENDPOINT_URL" else None
access_key = "$ACCESS_KEY"
secret_key = "$SECRET_KEY"
region = "${REGION:-us-east-1}"

s3_config = {
    'aws_access_key_id': access_key,
    'aws_secret_access_key': secret_key,
}
if endpoint_url:
    s3_config['endpoint_url'] = endpoint_url
    s3_config['region_name'] = 'us-east-1'
else:
    s3_config['region_name'] = region

s3_client = boto3.client('s3', **s3_config)
cutoff_date = datetime.now() - timedelta(days=30)

try:
    paginator = s3_client.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=bucket, Prefix='n8n-backups/')
    
    deleted_count = 0
    for page in pages:
        if 'Contents' in page:
            for obj in page['Contents']:
                if obj['LastModified'].replace(tzinfo=None) < cutoff_date:
                    s3_client.delete_object(Bucket=bucket, Key=obj['Key'])
                    deleted_count += 1
    
    print(f"Deleted {deleted_count} old backup(s) from cloud storage")
except ClientError as e:
    print(f"Error cleaning up cloud backups: {e}", file=sys.stderr)
PYTHON_SCRIPT
        
        python3 "$CLEANUP_SCRIPT" 2>&1 || log_warn "Failed to cleanup old cloud backups"
        rm -f "$CLEANUP_SCRIPT"
    fi
fi

echo ""
log_info "=== Backup Complete ==="
log_info "Backup location: $BACKUP_DATE_DIR"
log_info "Backup size: $BACKUP_SIZE"
if [ -n "$AWS_S3_BUCKET" ] || [ -n "$MINIO_BUCKET" ]; then
    if [ -n "$MINIO_BUCKET" ]; then
        log_info "Cloud location: $ENDPOINT_URL/$MINIO_BUCKET/n8n-backups/$TIMESTAMP/"
    else
        log_info "Cloud location: s3://$AWS_S3_BUCKET/n8n-backups/$TIMESTAMP/"
    fi
fi
echo ""

# List backup files
echo "Backup files created:"
ls -lh "$BACKUP_DATE_DIR" | grep "$TIMESTAMP" || true

