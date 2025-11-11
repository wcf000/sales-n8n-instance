#!/bin/bash
# Initialize pgvector extension in PostgreSQL
# This script can be run manually or as part of database setup

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check if PostgreSQL is running
if ! docker compose ps postgres | grep -q "Up"; then
    log_error "PostgreSQL container is not running"
    exit 1
fi

log_info "Initializing pgvector extension..."

# Get database credentials from environment or use defaults
DB_USER="${POSTGRES_USER:-n8n}"
DB_NAME="${POSTGRES_DB:-n8n}"

# Create extension
if docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "CREATE EXTENSION IF NOT EXISTS vector;" 2>/dev/null; then
    log_info "pgvector extension created successfully"
else
    log_error "Failed to create pgvector extension"
    exit 1
fi

# Verify extension
if docker compose exec -T postgres psql -U "$DB_USER" -d "$DB_NAME" -c "\dx vector" | grep -q "vector"; then
    log_info "pgvector extension verified"
else
    log_warn "Could not verify pgvector extension"
fi

log_info "pgvector initialization complete"

