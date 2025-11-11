#!/bin/bash
# Volume Setup Script for n8n Platform
# This script initializes and sets up external volumes with proper permissions

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}n8n Volume Setup Script${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    log_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

log_info "Checking Docker volumes..."

# List of volumes to create/verify
VOLUMES=(
    "self-hosted-ai-starter-kit_n8n_storage"
    "self-hosted-ai-starter-kit_n8n_data"
    "self-hosted-ai-starter-kit_n8n_scripts"
    "self-hosted-ai-starter-kit_postgres_storage"
    "self-hosted-ai-starter-kit_ollama_storage"
    "self-hosted-ai-starter-kit_qdrant_storage"
    "self-hosted-ai-starter-kit_redis_storage"
    "self-hosted-ai-starter-kit_minio_storage"
)

# Get project name from docker-compose.yml or use default
PROJECT_NAME=$(docker compose config --services 2>/dev/null | head -1 | xargs dirname 2>/dev/null || echo "self-hosted-ai-starter-kit")
PROJECT_NAME=$(basename "$(pwd)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g')

log_info "Project name: $PROJECT_NAME"

# Create volumes if they don't exist
for volume in "${VOLUMES[@]}"; do
    # Replace project name placeholder
    VOLUME_NAME=$(echo "$volume" | sed "s/self-hosted-ai-starter-kit/$PROJECT_NAME/g")
    
    if docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1; then
        log_info "Volume exists: $VOLUME_NAME"
    else
        log_info "Creating volume: $VOLUME_NAME"
        docker volume create "$VOLUME_NAME" >/dev/null
        log_info "Volume created: $VOLUME_NAME"
    fi
done

# Set permissions for n8n volumes (requires running container)
log_info "Setting up volume permissions..."

if docker compose ps n8n 2>/dev/null | grep -q "Up"; then
    log_info "n8n container is running, setting permissions..."
    
    # Set permissions for /data directory (n8n_data volume)
    docker compose exec -T n8n sh -c "chown -R node:node /data 2>/dev/null || true" || log_warn "Could not set permissions for /data (may require root)"
    
    # Set permissions for /root/.n8n/scripts directory (n8n_scripts volume)
    docker compose exec -T n8n sh -c "chown -R root:root /root/.n8n/scripts 2>/dev/null || true" || log_warn "Could not set permissions for /root/.n8n/scripts (may require root)"
    
    log_info "Permissions set (if applicable)"
else
    log_warn "n8n container is not running. Permissions will be set automatically when the container starts."
    log_info "To set permissions manually, run: docker compose up -d n8n"
fi

# Create local directories for bind mounts (if needed)
log_info "Creating local directories for bind mounts..."

LOCAL_DIRS=(
    "./backups"
    "./shared"
    "./n8n/demo-data"
)

for dir in "${LOCAL_DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        log_info "Creating directory: $dir"
        mkdir -p "$dir"
        log_info "Directory created: $dir"
    else
        log_info "Directory exists: $dir"
    fi
done

# Display volume information
echo ""
log_info "Volume Information:"
echo "----------------------------------------"
docker volume ls | grep "$PROJECT_NAME" || log_warn "No volumes found for project: $PROJECT_NAME"

echo ""
log_info "Volume Mount Points:"
echo "----------------------------------------"
echo "- n8n_storage: /home/node/.n8n (config & credentials)"
echo "- n8n_data: /data (workflow JSON exports)"
echo "- n8n_scripts: /root/.n8n/scripts (Python environment scripts)"
echo "- postgres_storage: /var/lib/postgresql/data (database)"
echo "- ollama_storage: /root/.ollama (Ollama models)"
echo "- qdrant_storage: /qdrant/storage (vector database)"
echo "- redis_storage: Redis data"
echo "- minio_storage: /data (MinIO object storage - optional)"

echo ""
log_info "=== Volume Setup Complete ==="
log_info "Volumes are ready for use."
log_info "Start services with: docker compose up -d"

