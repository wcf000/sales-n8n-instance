#!/bin/bash
# Health Check Script for n8n Platform
# This script checks the health of all services

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_info() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo "=== n8n Platform Health Check ==="
echo "Timestamp: $(date)"
echo ""

FAILED=0

# Check Docker
echo "1. Checking Docker..."
if command -v docker >/dev/null 2>&1; then
    DOCKER_VERSION=$(docker --version)
    log_info "Docker: $DOCKER_VERSION"
else
    log_error "Docker not found"
    FAILED=1
fi

# Check Docker Compose
echo ""
echo "2. Checking Docker Compose..."
if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    COMPOSE_VERSION=$(docker compose version --short)
    log_info "Docker Compose: $COMPOSE_VERSION"
else
    log_error "Docker Compose not found"
    FAILED=1
fi

# Check services status
echo ""
echo "3. Checking service status..."
SERVICES=("postgres" "n8n" "traefik" "qdrant")

for service in "${SERVICES[@]}"; do
    if docker compose ps "$service" 2>/dev/null | grep -q "Up"; then
        STATUS=$(docker compose ps "$service" --format "{{.Status}}")
        log_info "$service: $STATUS"
    else
        log_error "$service: Not running"
        FAILED=1
    fi
done

# Check PostgreSQL
echo ""
echo "4. Checking PostgreSQL..."
if docker compose exec -T postgres pg_isready -U "${POSTGRES_USER:-n8n}" >/dev/null 2>&1; then
    log_info "PostgreSQL is ready"
    
    # Check database connection
    if docker compose exec -T postgres psql -U "${POSTGRES_USER:-n8n}" -d "${POSTGRES_DB:-n8n}" -c "SELECT 1;" >/dev/null 2>&1; then
        log_info "Database connection successful"
    else
        log_error "Database connection failed"
        FAILED=1
    fi
else
    log_error "PostgreSQL is not ready"
    FAILED=1
fi

# Check n8n
echo ""
echo "5. Checking n8n..."
if docker compose ps n8n | grep -q "Up"; then
    # Check if n8n is responding
    if curl -s -f http://localhost:5678/healthz >/dev/null 2>&1 || curl -s -f http://localhost:5678 >/dev/null 2>&1; then
        log_info "n8n is responding"
    else
        log_warn "n8n container is running but not responding on port 5678"
    fi
    
    # Check Python in n8n
    if docker compose exec -T n8n python3 --version >/dev/null 2>&1; then
        PYTHON_VERSION=$(docker compose exec -T n8n python3 --version 2>&1)
        log_info "Python in n8n: $PYTHON_VERSION"
    else
        log_error "Python not found in n8n container"
        FAILED=1
    fi
else
    log_error "n8n is not running"
    FAILED=1
fi

# Check Traefik
echo ""
echo "6. Checking Traefik..."
if docker compose ps traefik | grep -q "Up"; then
    if curl -s -f http://localhost:8080/api/overview >/dev/null 2>&1; then
        log_info "Traefik dashboard is accessible"
    else
        log_warn "Traefik is running but dashboard not accessible"
    fi
else
    log_warn "Traefik is not running (optional for development)"
fi

# Check Redis (if worker mode)
echo ""
echo "7. Checking Redis (worker mode)..."
if docker compose ps redis 2>/dev/null | grep -q "Up"; then
    if docker compose exec -T redis redis-cli ping >/dev/null 2>&1; then
        log_info "Redis is ready"
    else
        log_error "Redis is not responding"
        FAILED=1
    fi
else
    log_info "Redis not running (worker mode not enabled)"
fi

# Check disk space
echo ""
echo "8. Checking disk space..."
DISK_USAGE=$(df -h . | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -lt 80 ]; then
    log_info "Disk usage: ${DISK_USAGE}%"
elif [ "$DISK_USAGE" -lt 90 ]; then
    log_warn "Disk usage: ${DISK_USAGE}% (getting high)"
else
    log_error "Disk usage: ${DISK_USAGE}% (critical)"
    FAILED=1
fi

# Check memory
echo ""
echo "9. Checking memory..."
if command -v free >/dev/null 2>&1; then
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$MEM_USAGE" -lt 80 ]; then
        log_info "Memory usage: ${MEM_USAGE}%"
    elif [ "$MEM_USAGE" -lt 90 ]; then
        log_warn "Memory usage: ${MEM_USAGE}% (getting high)"
    else
        log_error "Memory usage: ${MEM_USAGE}% (critical)"
        FAILED=1
    fi
fi

# Check volumes
echo ""
echo "10. Checking Docker volumes..."
VOLUMES=(
    "self-hosted-ai-starter-kit_n8n_storage"
    "self-hosted-ai-starter-kit_postgres_storage"
)

for volume in "${VOLUMES[@]}"; do
    if docker volume inspect "$volume" >/dev/null 2>&1; then
        VOLUME_SIZE=$(docker system df -v | grep "$volume" | awk '{print $3}' || echo "unknown")
        log_info "Volume $volume: $VOLUME_SIZE"
    else
        log_warn "Volume not found: $volume"
    fi
done

# Summary
echo ""
echo "=== Health Check Summary ==="
if [ $FAILED -eq 0 ]; then
    log_info "All critical checks passed"
    exit 0
else
    log_error "Some checks failed. Review the output above."
    exit 1
fi

