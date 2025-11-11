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

# 7. Cleanup old backups (keep last 30 days)
if [ -d "$BACKUP_DIR" ]; then
    log_info "Cleaning up backups older than 30 days..."
    find "$BACKUP_DIR" -type d -mtime +30 -exec rm -rf {} + 2>/dev/null || true
    log_info "Cleanup complete"
fi

echo ""
log_info "=== Backup Complete ==="
log_info "Backup location: $BACKUP_DATE_DIR"
log_info "Backup size: $BACKUP_SIZE"
echo ""

# List backup files
echo "Backup files created:"
ls -lh "$BACKUP_DATE_DIR" | grep "$TIMESTAMP" || true

