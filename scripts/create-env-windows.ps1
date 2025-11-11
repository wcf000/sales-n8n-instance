# PowerShell script to create .env file for Windows
# This properly escapes the $ characters for Docker Compose

$envContent = @"
# PostgreSQL Database Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=dev_password_123
POSTGRES_DB=n8n

# n8n Configuration
N8N_ENCRYPTION_KEY=$(([System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(16))).Substring(0,32))
N8N_USER_MANAGEMENT_JWT_SECRET=$([System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32)))

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

# Traefik Basic Auth - Use single quotes or escape $ signs
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

# AWS S3 Backup Configuration (optional)
# For automated backup uploads to S3
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
AWS_REGION=us-east-1

# MinIO Configuration (optional - local S3-compatible storage)
# Enable with: docker compose --profile minio up -d
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin
MINIO_BUCKET=n8n-backups
MINIO_ENDPOINT_URL=http://minio:9000
"@

$envContent | Out-File -FilePath ".env" -Encoding utf8 -NoNewline
Write-Host ".env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Note: For local development, the TRAEFIK_BASIC_AUTH_PASSWORD_HASH is set to a test value." -ForegroundColor Yellow
Write-Host "For production, generate a proper hash using: htpasswd -nb admin password" -ForegroundColor Yellow

