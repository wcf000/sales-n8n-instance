# Setup Instructions

## Environment Configuration

Since `.env.example` is in `.gitignore`, create your `.env` file manually with the following template:

```bash
# PostgreSQL Database Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=changeme_strong_password_here
POSTGRES_DB=n8n

# n8n Configuration
N8N_ENCRYPTION_KEY=changeme_generate_with_openssl_rand_hex_16
N8N_USER_MANAGEMENT_JWT_SECRET=changeme_generate_with_openssl_rand_base64_32
N8N_DIAGNOSTICS_ENABLED=false
N8N_PERSONALIZATION_ENABLED=false

# n8n Webhook and Host Configuration
N8N_HOST=0.0.0.0
N8N_PORT=5678
WEBHOOK_URL=https://n8n.example.com/

# n8n Execution Mode (regular or queue for worker mode)
EXECUTIONS_MODE=regular

# n8n Community Nodes
N8N_COMMUNITY_PACKAGES_ENABLED=true
N8N_COMMUNITY_NODES_INCLUDE=

# Traefik Configuration
TRAEFIK_DOMAIN=n8n.example.com
TRAEFIK_EMAIL=admin@example.com

# Traefik Basic Auth - IMPORTANT: Escape $ signs with $$ (for Docker Compose)
# For development, use: $$apr1$$test$$test
# For production, generate with: htpasswd -nb admin password | sed -e s/\\$/\\$\\$/g
# Or use: openssl passwd -apr1 password (then escape $ with $$)
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
```

## Generating Required Values

### Encryption Keys

```bash
# Generate N8N_ENCRYPTION_KEY (32 characters)
openssl rand -hex 16

# Generate N8N_USER_MANAGEMENT_JWT_SECRET
openssl rand -base64 32
```

### Traefik Basic Auth Hash

**Option 1: Using htpasswd (if available)**
```bash
htpasswd -nb admin yourpassword | sed -e s/\\$/\\$\\$/g
```

**Option 2: Using openssl**
```bash
openssl passwd -apr1 yourpassword
```

**Option 3: Online generator**
Use an online htpasswd generator and copy the hash.

## Quick Setup Script

You can create a setup script to generate the `.env` file:

```bash
#!/bin/bash
# setup-env.sh

cat > .env <<EOF
POSTGRES_USER=n8n
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
POSTGRES_DB=n8n

N8N_ENCRYPTION_KEY=$(openssl rand -hex 16)
N8N_USER_MANAGEMENT_JWT_SECRET=$(openssl rand -base64 32)

N8N_DIAGNOSTICS_ENABLED=false
N8N_PERSONALIZATION_ENABLED=false

N8N_HOST=0.0.0.0
N8N_PORT=5678

EXECUTIONS_MODE=regular

N8N_COMMUNITY_PACKAGES_ENABLED=true

TRAEFIK_DOMAIN=n8n.example.com
TRAEFIK_EMAIL=admin@example.com
TRAEFIK_BASIC_AUTH_USER=admin
TRAEFIK_BASIC_AUTH_PASSWORD_HASH=

OLLAMA_HOST=ollama:11434
EOF

echo ".env file created!"
echo "Please update TRAEFIK_DOMAIN, TRAEFIK_EMAIL, and TRAEFIK_BASIC_AUTH_PASSWORD_HASH manually"
```

## First Run

1. Create `.env` file (see above)
2. Build custom n8n image: `docker compose build n8n`
3. Start services: `docker compose up -d`
4. Access n8n: `http://localhost:5678`
5. Validate Python: `./_debug/validate-python.sh`

For detailed instructions, see `_docs/QUICKSTART.md`

