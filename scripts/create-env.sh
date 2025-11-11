#!/bin/bash
# Bash script to create .env file for Linux/Mac
# This properly escapes the $ characters for Docker Compose

cat > .env <<'EOF'
# PostgreSQL Database Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=n8n

# n8n Configuration
N8N_ENCRYPTION_KEY=$(openssl rand -hex 16)
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

N8N_DIAGNOSTICS_ENABLED=false
N8N_PERSONALIZATION_ENABLED=false

# n8n Webhook and Host Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
WEBHOOK_URL=

# n8n Execution Mode (regular or queue for worker mode)
EXECUTIONS_MODE=regular

# n8n Community Nodes
N8N_COMMUNITY_PACKAGES_ENABLED=true
N8N_COMMUNITY_NODES_INCLUDE=

# Traefik Configuration
TRAEFIK_DOMAIN=localhost
TRAEFIK_EMAIL=dev@localhost

# Traefik Basic Auth - Escaped $ signs ($$ becomes $ in Docker Compose)
# For development, you can leave this empty or use a simple value
TRAEFIK_BASIC_AUTH_USER=admin
TRAEFIK_BASIC_AUTH_PASSWORD_HASH=$$apr1$$test$$test

# Ollama Configuration
OLLAMA_HOST=ollama:11434

# Redis Configuration (for worker mode)
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_PASSWORD=
QUEUE_BULL_REDIS_DB=0

# CORS Configuration (optional)
N8N_CORS_ORIGIN=

# NPM Registry (for custom nodes, optional)
NPM_REGISTRY=
NPM_TOKEN=

# OpenRouter API (for LLM model access - optional but recommended)
# Get your key from: https://openrouter.ai/keys
OPENROUTER_API_KEY=
EOF

echo ".env file created successfully!"
echo ""
echo "Note: For local development, the TRAEFIK_BASIC_AUTH_PASSWORD_HASH is set to a test value."
echo "For production, generate a proper hash using: htpasswd -nb admin password"

