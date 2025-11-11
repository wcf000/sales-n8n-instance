#!/bin/bash
# Restore Script for n8n Platform
# This script restores n8n from backups

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if backup file/directory is provided
if [ -z "$1" ]; then
    log_error "Usage: $0 <backup-file-or-directory> [--database|--volumes|--workflows|--config]"
    echo ""
    echo "Examples:"
    echo "  $0 backups/2024-01-15/database-20240115-020000.sql.gz"
    echo "  $0 backups/2024-01-15 --database"
    echo "  $0 backups/2024-01-15 --volumes"
    exit 1
fi

BACKUP_PATH="$1"
RESTORE_TYPE="${2:-all}"

echo "=== n8n Restore Script ==="
echo "Backup path: $BACKUP_PATH"
echo "Restore type: $RESTORE_TYPE"
echo ""

# Verify backup exists
if [ ! -e "$BACKUP_PATH" ]; then
    log_error "Backup not found: $BACKUP_PATH"
    exit 1
fi

# Confirm restore
read -p "This will overwrite existing data. Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    log_info "Restore cancelled"
    exit 0
fi

# Stop services before restore
log_info "Stopping services..."
docker compose stop n8n postgres 2>/dev/null || true

# Restore database
if [ "$RESTORE_TYPE" = "all" ] || [ "$RESTORE_TYPE" = "--database" ]; then
    log_info "Restoring database..."
    
    # Find database backup file
    if [ -f "$BACKUP_PATH" ] && [[ "$BACKUP_PATH" == *.sql* ]]; then
        DB_BACKUP="$BACKUP_PATH"
    elif [ -d "$BACKUP_PATH" ]; then
        DB_BACKUP=$(find "$BACKUP_PATH" -name "database-*.sql*" | head -1)
    else
        log_warn "Database backup file not found"
        DB_BACKUP=""
    fi
    
    if [ -n "$DB_BACKUP" ] && [ -f "$DB_BACKUP" ]; then
        log_info "Found database backup: $DB_BACKUP"
        
        # Start PostgreSQL if not running
        docker compose up -d postgres
        sleep 5
        
        # Wait for PostgreSQL to be ready
        log_info "Waiting for PostgreSQL to be ready..."
        timeout=30
        while [ $timeout -gt 0 ]; do
            if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-n8n}" >/dev/null 2>&1; then
                break
            fi
            sleep 1
            timeout=$((timeout - 1))
        done
        
        if [ $timeout -eq 0 ]; then
            log_error "PostgreSQL did not become ready"
            exit 1
        fi
        
        # Restore database
        if [[ "$DB_BACKUP" == *.gz ]]; then
            log_info "Decompressing and restoring database..."
            gunzip -c "$DB_BACKUP" | docker compose exec -T postgres psql -U "${POSTGRES_USER:-n8n}" "${POSTGRES_DB:-n8n}"
        else
            log_info "Restoring database..."
            docker compose exec -T postgres psql -U "${POSTGRES_USER:-n8n}" "${POSTGRES_DB:-n8n}" < "$DB_BACKUP"
        fi
        
        log_info "Database restored successfully"
    else
        log_warn "Database backup not found, skipping database restore"
    fi
fi

# Restore volumes
if [ "$RESTORE_TYPE" = "all" ] || [ "$RESTORE_TYPE" = "--volumes" ]; then
    log_info "Restoring volumes..."
    
    if [ -d "$BACKUP_PATH" ]; then
        VOLUME_BACKUPS=$(find "$BACKUP_PATH" -name "volume-*.tar.gz")
        
        for VOLUME_BACKUP in $VOLUME_BACKUPS; do
            log_info "Restoring volume from: $VOLUME_BACKUP"
            
            # Extract volume name from backup filename
            VOLUME_NAME=$(basename "$VOLUME_BACKUP" | sed 's/volume-\(.*\)-[0-9]*\.tar\.gz/\1/' | sed 's/_/\//g')
            
            if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
                log_info "Restoring volume: $VOLUME_NAME"
                
                # Determine volume path based on volume name
                if [[ "$VOLUME_NAME" == *n8n_storage* ]]; then
                    VOLUME_PATH="/home/node/.n8n"
                elif [[ "$VOLUME_NAME" == *postgres_storage* ]]; then
                    VOLUME_PATH="/var/lib/postgresql/data"
                else
                    VOLUME_PATH="/data"
                fi
                
                docker run --rm \
                    -v "$VOLUME_NAME:$VOLUME_PATH" \
                    -v "$(pwd)/$(dirname $VOLUME_BACKUP):/backup" \
                    alpine sh -c "cd $VOLUME_PATH && rm -rf * && tar xzf /backup/$(basename $VOLUME_BACKUP) --strip-components=0" 2>/dev/null || log_warn "Failed to restore volume: $VOLUME_NAME"
                
                log_info "Volume restored: $VOLUME_NAME"
            else
                log_warn "Volume not found: $VOLUME_NAME"
            fi
        done
    else
        log_warn "Backup path is not a directory, skipping volume restore"
    fi
fi

# Restore workflows
if [ "$RESTORE_TYPE" = "all" ] || [ "$RESTORE_TYPE" = "--workflows" ]; then
    log_info "Restoring workflows..."
    
    if [ -d "$BACKUP_PATH" ]; then
        WORKFLOWS_BACKUP=$(find "$BACKUP_PATH" -name "workflows-*.json" | head -1)
        
        if [ -n "$WORKFLOWS_BACKUP" ] && [ -f "$WORKFLOWS_BACKUP" ]; then
            log_info "Found workflows backup: $WORKFLOWS_BACKUP"
            
            if [ -n "$N8N_API_KEY" ] && [ -n "$N8N_URL" ]; then
                log_info "Importing workflows via API..."
                # Note: This would require API implementation for workflow import
                log_warn "Workflow import via API not fully implemented"
                log_info "Workflows are included in the database backup"
            else
                log_info "Workflows are included in the database backup"
            fi
        else
            log_info "Workflows are included in the database backup"
        fi
    fi
fi

# Restore configuration
if [ "$RESTORE_TYPE" = "all" ] || [ "$RESTORE_TYPE" = "--config" ]; then
    log_info "Restoring configuration..."
    
    if [ -d "$BACKUP_PATH" ]; then
        CONFIG_BACKUP=$(find "$BACKUP_PATH" -name "config-*.tar.gz" | head -1)
        
        if [ -n "$CONFIG_BACKUP" ] && [ -f "$CONFIG_BACKUP" ]; then
            log_info "Found configuration backup: $CONFIG_BACKUP"
            log_warn "Configuration restore requires manual extraction"
            log_info "Extract with: tar xzf $CONFIG_BACKUP"
        fi
    fi
fi

# Start services
log_info "Starting services..."
docker compose up -d

log_info "Waiting for services to be ready..."
sleep 10

log_info "=== Restore Complete ==="
log_info "Services have been restarted"
log_info "Verify the restore by checking the n8n UI"

