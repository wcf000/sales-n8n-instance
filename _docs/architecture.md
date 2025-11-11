# System Architecture

## Overview

This self-hosted n8n platform provides a comprehensive workflow automation environment with Python execution capabilities, reverse proxy security, and scalable worker architecture.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Traefik Reverse Proxy                    │
│              (SSL/TLS, Authentication, Routing)              │
└──────────────────────┬──────────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        │                             │
┌───────▼────────┐          ┌─────────▼─────────┐
│   n8n Main     │          │   n8n Workers     │
│   (UI/API)     │◄─────────┤  (Execution)      │
└───────┬────────┘  Queue   └───────────────────┘
        │
        ├──────────────────┬──────────────────┐
        │                  │                  │
┌───────▼──────┐  ┌────────▼──────┐  ┌───────▼──────┐
│  PostgreSQL  │  │     Redis     │  │    Ollama    │
│  (Database)  │  │    (Queue)    │  │   (LLM API)  │
└──────────────┘  └───────────────┘  └──────────────┘
                                           │
                                  ┌────────▼──────┐
                                  │    Qdrant     │
                                  │ (Vector DB)   │
                                  └───────────────┘
```

## Core Components

### 1. Traefik Reverse Proxy
- **Purpose**: SSL/TLS termination, authentication, and routing
- **Ports**: 80 (HTTP), 443 (HTTPS), 8080 (Dashboard)
- **Configuration**: File-based routing rules
- **Authentication**: Basic auth middleware + n8n user management

### 2. n8n Main Instance
- **Purpose**: Web UI, API endpoints, workflow management
- **Port**: 5678 (internal), exposed via Traefik
- **Database**: PostgreSQL for persistence
- **Python**: Python 3.11+ with curated packages installed

### 3. n8n Workers
- **Purpose**: Execute workflows in distributed mode
- **Mode**: Queue-based execution (Redis/Bull)
- **Scaling**: Multiple worker instances supported

### 4. PostgreSQL Database
- **Purpose**: Store workflows, credentials, execution history
- **Version**: 16-alpine
- **Persistence**: Docker volume
- **Backup**: Scheduled dumps via backup scripts

### 5. Redis
- **Purpose**: Queue management for worker mode
- **Usage**: Bull queue backend for workflow execution

### 6. Ollama
- **Purpose**: Local LLM inference
- **Port**: 11434
- **Profiles**: CPU, GPU-Nvidia, GPU-AMD

### 7. Qdrant
- **Purpose**: Vector database for embeddings
- **Port**: 6333
- **Usage**: AI workflows requiring vector search

## Data Flow

### Workflow Execution Flow
1. User creates/triggers workflow via n8n UI
2. n8n Main receives request
3. Workflow queued in Redis (if worker mode enabled)
4. n8n Worker picks up workflow from queue
5. Worker executes workflow nodes
6. Python scripts executed via Execute Command node
7. Results stored in PostgreSQL
8. User notified via UI

### Webhook Flow
1. External service sends HTTP request to Traefik
2. Traefik routes to n8n webhook endpoint
3. n8n triggers workflow
4. Execution follows standard workflow execution flow

## Network Architecture

### Docker Networks
- **demo**: Internal network connecting all services
- **Isolation**: Services communicate via service names

### Port Mapping
- **Traefik**: 80, 443, 8080 → Host
- **n8n**: Internal only (accessed via Traefik)
- **PostgreSQL**: Internal only
- **Redis**: Internal only
- **Ollama**: 11434 → Host (optional)
- **Qdrant**: 6333 → Host (optional)

## Security Architecture

### Authentication Layers
1. **Traefik Basic Auth**: First line of defense
2. **n8n User Management**: Application-level authentication
3. **JWT Tokens**: API authentication

### Encryption
- **TLS/SSL**: All external traffic encrypted
- **Database**: Credentials encrypted at rest
- **n8n Encryption Key**: Environment variable

## Python Execution Environment

### Installation
- Python 3.11+ installed in n8n container
- Packages managed via `requirements.txt`
- Accessible via Execute Command node

### Available Packages
- Data Processing: `pandas`, `numpy`
- HTTP: `requests`
- AI: `openai`
- Web Scraping: `beautifulsoup4`, `lxml`
- Database: `SQLAlchemy`, `psycopg2-binary`
- Cloud: `boto3`

## Scalability

### Horizontal Scaling
- Multiple n8n worker instances
- Redis queue distributes load
- PostgreSQL connection pooling

### Vertical Scaling
- Resource limits per service
- GPU support for Ollama
- Volume mounts for data persistence

## Monitoring & Observability

### Health Checks
- All services have health check endpoints
- Docker health checks configured
- Monitoring scripts in `_debug/monitoring/`

### Logging
- Container logs via Docker
- n8n execution logs in database
- Traefik access logs

## Backup & Recovery

### Backup Strategy
- PostgreSQL dumps (scheduled)
- n8n workflow/credential exports
- Volume snapshots
- Retention policy: 30 days

### Recovery Process
- Database restore from dump
- Workflow/credential import
- Volume restoration
- Service restart

