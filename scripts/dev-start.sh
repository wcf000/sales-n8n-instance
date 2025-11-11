#!/bin/bash
# Development Startup Script
# Quick script to start the n8n development environment

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== n8n Local Development Startup ===${NC}"
echo ""

# Check if .env exists
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}Warning: .env file not found${NC}"
    echo "Creating a basic .env file for development..."
    
    cat > .env <<EOF
POSTGRES_USER=n8n
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=n8n

N8N_ENCRYPTION_KEY=$(openssl rand -hex 16 2>/dev/null || echo "dev_key_123456789012345678901234567890")
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32 2>/dev/null || echo "dev_jwt_secret_123456789012345678901234567890")

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
    
    echo -e "${GREEN}.env file created${NC}"
    echo ""
fi

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running${NC}"
    echo "Please start Docker Desktop or Docker daemon"
    exit 1
fi

# Check if n8n image exists
if ! docker images | grep -q "self-hosted-ai-starter-kit-n8n\|n8n.*latest"; then
    echo -e "${YELLOW}n8n image not found. Building custom n8n image...${NC}"
    echo "This will take 5-10 minutes on first run..."
    echo ""
    docker compose build n8n
    echo ""
fi

# Start services
echo -e "${GREEN}Starting services...${NC}"
echo ""

# Check if user wants Traefik
read -p "Start with Traefik? (y/n, default: n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Starting all services including Traefik..."
    docker compose up -d
    echo ""
    echo -e "${GREEN}Services started!${NC}"
    echo ""
    echo "Access n8n at:"
    echo "  - Direct: http://localhost:5678"
    echo "  - Via Traefik: http://localhost"
else
    echo "Starting services without Traefik..."
    docker compose up -d postgres n8n qdrant
    echo ""
    echo -e "${GREEN}Services started!${NC}"
    echo ""
    echo "Access n8n at: http://localhost:5678"
fi

echo ""
echo "View logs with: docker compose logs -f"
echo "Stop services with: docker compose down"
echo ""

# Wait a moment for services to start
sleep 3

# Check service status
echo "Service status:"
docker compose ps

echo ""
echo -e "${GREEN}Setup complete!${NC}"

