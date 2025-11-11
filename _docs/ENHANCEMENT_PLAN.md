# Enhancement Plan: Production-Grade Optimizations

This document outlines the next phase of enhancements to transform the self-hosted n8n platform into a production-grade, enterprise-ready system.

## Overview

Building on the completed foundation, this plan focuses on:
- Production-grade storage and backup strategies
- Enhanced security and access controls
- Performance optimizations and scalability
- Developer experience improvements
- Comprehensive observability
- Advanced workflow capabilities
- DealScale-specific integrations

---

## Sprint 4: Storage & Infrastructure Enhancements

### 4.1 Persistent + Externalized Storage

**Priority**: Critical  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` the n8n container is running
- `When` workflows and credentials are created
- `Then` data persists in external volumes:
  - `/home/node/.n8n` → config & credentials (mounted volume)
  - `/data` → workflow JSON exports (mounted volume)
  - `/root/.n8n/scripts` → Python environment scripts (mounted volume)
- `And` data survives container restarts and updates

#### Implementation Tasks
1. Configure external volume mounts in docker-compose.yml
2. Create volume directories on host
3. Set proper permissions for n8n user
4. Document volume structure and backup procedures
5. Test data persistence across container restarts

#### Files to Create/Modify
- `docker-compose.yml` - Add external volume mounts
- `_docs/storage-management.md` - Storage documentation
- `scripts/setup-volumes.sh` - Volume initialization script

---

### 4.2 Automated S3 Backup Integration

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` AWS credentials are configured
- `When` backup script runs
- `Then` PostgreSQL dump is created
- `And` backup is uploaded to S3 with timestamp
- `And` old backups are automatically pruned (30-day retention)
- `And` backup manifest includes S3 location

#### Implementation Tasks
1. Add boto3 to requirements.txt (already included)
2. Update `scripts/backup.sh` with S3 upload functionality
3. Add S3 configuration to `.env` template
4. Implement backup retention policy
5. Add S3 restore functionality to `scripts/restore.sh`
6. Create MinIO option for local S3-compatible storage

#### Files to Create/Modify
- `scripts/backup.sh` - Add S3 upload
- `scripts/restore.sh` - Add S3 download
- `docker-compose.yml` - Optional MinIO service
- `_docs/backup-recovery.md` - Update with S3 instructions

---

### 4.3 MinIO Local Object Storage (Optional)

**Priority**: Medium  
**Story Points**: 3  
**Status**: Planned

#### Acceptance Criteria
- `Given` MinIO is configured
- `When` backup script runs
- `Then` backups are stored in MinIO bucket
- `And` MinIO UI is accessible for backup management

#### Implementation Tasks
1. Add MinIO service to docker-compose.yml
2. Configure MinIO buckets
3. Update backup script to support MinIO
4. Document MinIO setup and usage

---

## Sprint 5: Base Image & Health Monitoring

### 5.1 Upgrade Base Image with Health Checks

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` the Dockerfile is updated
- `When` the image is built
- `Then` it extends `n8nio/n8n:latest`
- `And` Python 3.12+ is installed via apt-get
- `And` HEALTHCHECK is configured
- `And` health endpoint responds correctly

#### Implementation Tasks
1. Update Dockerfile to use apt-get (Debian-based) instead of apk (Alpine)
2. Add HEALTHCHECK instruction
3. Install curl for health checks
4. Test health check functionality
5. Update documentation

#### Files to Create/Modify
- `n8n/Dockerfile` - Switch to Debian base, add health check
- `_docs/deployment.md` - Update health check documentation

---

### 5.2 Prometheus Metrics Export

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` n8n is running with metrics enabled
- `When` Prometheus scrapes metrics endpoint
- `Then` execution metrics are available:
  - Execution count by status
  - Execution duration
  - Queue length
  - Error rates
- `And` Grafana dashboard displays metrics

#### Implementation Tasks
1. Enable n8n metrics: `N8N_METRICS=true`, `N8N_METRICS_PORT=5679`
2. Configure Prometheus service in docker-compose.yml
3. Create Prometheus scrape configuration
4. Set up Grafana service
5. Create Grafana dashboard for n8n metrics
6. Document metrics and alerting

#### Files to Create/Modify
- `docker-compose.yml` - Add Prometheus and Grafana services
- `prometheus/prometheus.yml` - Prometheus configuration
- `grafana/dashboards/n8n-dashboard.json` - Grafana dashboard
- `_docs/monitoring.md` - Monitoring guide

---

## Sprint 6: Security & Access Enhancements

### 6.1 Enhanced Reverse Proxy Configuration

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` Traefik is configured
- `When` accessing n8n via public URL
- `Then` HTTPS is enforced (HTTP redirects to HTTPS)
- `And` basic authentication is required
- `And` security headers are set (X-Frame-Options, CSP, etc.)
- `And` rate limiting is active

#### Implementation Tasks
1. Enhance Traefik configuration with security headers
2. Configure rate limiting middleware
3. Set up IP whitelisting (optional)
4. Document security configuration
5. Test security headers

#### Files to Create/Modify
- `traefik/dynamic/n8n.yml` - Enhanced security middleware
- `_docs/security.md` - Security best practices

---

### 6.2 Environment Separation (Staging/Production)

**Priority**: Medium  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` staging and production environments
- `When` deploying to staging
- `Then` workflows can be tested safely
- `And` production data is not affected
- `And` workflows can be promoted from staging to production

#### Implementation Tasks
1. Create docker-compose.staging.yml
2. Create docker-compose.production.yml
3. Set up separate databases for staging/prod
4. Create workflow promotion script
5. Document environment management

#### Files to Create/Modify
- `docker-compose.staging.yml` - Staging configuration
- `docker-compose.production.yml` - Production configuration
- `scripts/promote-workflow.sh` - Workflow promotion script
- `_docs/environments.md` - Environment management guide

---

### 6.3 Secret Vault Integration

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` HashiCorp Vault is configured (optional)
- `When` n8n needs API keys
- `Then` secrets are retrieved from Vault
- `And` secrets are never stored in workflow JSON
- `And` secrets rotate automatically

#### Implementation Tasks
1. Document n8n environment variable secret management
2. Create Vault integration example (optional)
3. Update credential management documentation
4. Create secret rotation procedures

#### Files to Create/Modify
- `_docs/security.md` - Secret management section
- `_docs/examples/vault-integration.md` - Vault example (optional)

---

### 6.4 Audit Logging

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` audit logging is enabled
- `When` workflows execute
- `Then` full execution logs are saved
- `And` logs include user, timestamp, input/output data
- `And` logs are queryable for compliance

#### Implementation Tasks
1. Configure `EXECUTIONS_DATA_SAVE_ON_SUCCESS=true`
2. Configure `EXECUTIONS_DATA_SAVE_ON_ERROR=all`
3. Set up log retention policy
4. Create log query/export scripts
5. Document audit logging

#### Files to Create/Modify
- `docker-compose.yml` - Update environment variables
- `scripts/export-audit-logs.sh` - Log export script
- `_docs/audit-logging.md` - Audit logging guide

---

## Sprint 7: Performance Optimizations

### 7.1 Resource Limits & Autoscaling

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` docker-compose.yml is configured
- `When` services start
- `Then` resource limits are set:
  - Main process: ≤ 2 vCPU, 2GB RAM
  - Workers: scalable independently
- `And` workers can autoscale based on queue depth

#### Implementation Tasks
1. Add resource limits to docker-compose.yml
2. Configure worker autoscaling
3. Document resource planning
4. Create monitoring for resource usage
5. Test under load

#### Files to Create/Modify
- `docker-compose.yml` - Add resource limits
- `_docs/performance.md` - Performance tuning guide

---

### 7.2 Execution Data Pruning

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` execution pruning is enabled
- `When` executions are older than 7 days
- `Then` execution data is automatically pruned
- `And` database size remains manageable
- `And` execution metadata is preserved

#### Implementation Tasks
1. Configure `EXECUTIONS_DATA_PRUNE=true`
2. Set `EXECUTIONS_DATA_PRUNE_MAX_AGE=168` (7 days)
3. Create pruning schedule script
4. Monitor database size
5. Document pruning strategy

#### Files to Create/Modify
- `docker-compose.yml` - Add pruning environment variables
- `scripts/prune-executions.sh` - Manual pruning script
- `_docs/performance.md` - Pruning documentation

---

### 7.3 PostgreSQL Index Optimization

**Priority**: Medium  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` PostgreSQL is running
- `When` execution history queries run
- `Then` queries use indexes
- `And` query performance is improved
- `And` indexes are maintained automatically

#### Implementation Tasks
1. Create database migration script
2. Add indexes on execution_entity table
3. Add indexes on workflow_entity table
4. Test query performance
5. Document index strategy

#### Files to Create/Modify
- `scripts/db-migrations/add-indexes.sql` - Index creation script
- `scripts/apply-db-migrations.sh` - Migration runner
- `_docs/performance.md` - Database optimization section

---

## Sprint 8: Developer Experience

### 8.1 Git-Based Workflow Version Control

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` workflows are created in n8n
- `When` workflows are saved
- `Then` workflows are automatically exported to Git
- `And` workflows are version controlled
- `And` changes can be reviewed via Git history

#### Implementation Tasks
1. Create workflow export script
2. Set up Git repository for workflows
3. Create cron job for automatic exports
4. Add workflow import from Git
5. Document Git workflow

#### Files to Create/Modify
- `scripts/export-workflows-to-git.sh` - Export script
- `scripts/import-workflows-from-git.sh` - Import script
- `.github/workflows/sync-workflows.yml` - GitHub Actions (optional)
- `_docs/version-control.md` - Workflow version control guide

---

### 8.2 Custom Node Hot-Reloading

**Priority**: Medium  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` custom nodes are in development
- `When` node code changes
- `Then` nodes are automatically rebuilt
- `And` n8n reloads nodes without restart
- `And` development workflow is streamlined

#### Implementation Tasks
1. Create custom node development setup
2. Set up file watching for node changes
3. Create auto-rebuild script
4. Configure n8n to watch custom nodes directory
5. Document hot-reload workflow

#### Files to Create/Modify
- `scripts/watch-custom-nodes.sh` - File watcher script
- `scripts/rebuild-custom-nodes.sh` - Rebuild script
- `_docs/custom-nodes.md` - Update with hot-reload instructions

---

### 8.3 Error Reporting Integration

**Priority**: Medium  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` PostHog or Sentry is configured
- `When` workflow errors occur
- `Then` errors are sent to error tracking service
- `And` errors include context and stack traces
- `And` errors are queryable and alertable

#### Implementation Tasks
1. Create error webhook workflow template
2. Configure PostHog/Sentry integration
3. Set up error alerting
4. Document error tracking setup

#### Files to Create/Modify
- `_debug/error-tracking-workflow.json` - Error tracking template
- `_docs/error-tracking.md` - Error tracking guide

---

## Sprint 9: Observability & Monitoring

### 9.1 OpenTelemetry Integration

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` OpenTelemetry is configured
- `When` workflows execute
- `Then` traces are generated
- `And` traces span n8n → FastAPI → Pulsar
- `And` traces are viewable in tracing UI

#### Implementation Tasks
1. Configure OpenTelemetry in n8n
2. Set up OpenTelemetry collector
3. Configure trace export to Tempo/Jaeger
4. Create trace visualization
5. Document distributed tracing

#### Files to Create/Modify
- `docker-compose.yml` - Add OpenTelemetry services
- `otel/otel-collector-config.yml` - Collector configuration
- `_docs/observability.md` - Observability guide

---

### 9.2 Enhanced Logging & Log Aggregation

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` logging is configured
- `When` services generate logs
- `Then` logs are aggregated in Loki
- `And` logs are queryable via Grafana
- `And` log retention is configurable

#### Implementation Tasks
1. Configure Loki for log aggregation
2. Set up Promtail for log collection
3. Create Grafana log queries
4. Configure log retention
5. Document logging setup

#### Files to Create/Modify
- `docker-compose.yml` - Add Loki and Promtail
- `promtail/promtail-config.yml` - Promtail configuration
- `_docs/observability.md` - Logging section

---

## Sprint 10: Workflow Engine Enhancements

### 10.1 Retry Logic & Error Handling

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` a workflow with retry logic
- `When` a node fails
- `Then` workflow retries with exponential backoff
- `And` retry attempts are logged
- `And` final failure is handled gracefully

#### Implementation Tasks
1. Create retry sub-workflow template
2. Document retry patterns
3. Create error handling examples
4. Test retry logic

#### Files to Create/Modify
- `_docs/examples/retry-patterns.md` - Retry documentation
- `_debug/retry-workflow-template.json` - Retry template

---

### 10.2 Parallelization & Concurrency

**Priority**: Medium  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` a workflow with batch processing
- `When` Split-In-Batches node is used
- `Then` batches process in parallel
- `And` concurrency limits are respected
- `And` performance is improved

#### Implementation Tasks
1. Document parallelization patterns
2. Create example workflows
3. Test concurrency limits
4. Optimize batch sizes

#### Files to Create/Modify
- `_docs/performance.md` - Parallelization section
- `_debug/parallel-processing-example.json` - Example workflow

---

### 10.3 Python Sandbox Memory Limits

**Priority**: Medium  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` Python scripts run in workflows
- `When` scripts consume excessive memory
- `Then` memory is limited via resource.setrlimit()
- `And` scripts are terminated if limit exceeded
- `And` errors are logged

#### Implementation Tasks
1. Create Python wrapper script with memory limits
2. Update Execute Command node documentation
3. Test memory limits
4. Document memory management

#### Files to Create/Modify
- `scripts/python-executor.sh` - Memory-limited Python executor
- `_docs/python-environment.md` - Memory limits section

---

### 10.4 Redis Caching Integration

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` Redis is configured
- `When` workflows need cached data
- `Then` data is stored in Redis
- `And` cache TTL is configurable
- `And` cache invalidation works

#### Implementation Tasks
1. Add Redis Python client to requirements.txt
2. Create caching utility functions
3. Document caching patterns
4. Create example workflows

#### Files to Create/Modify
- `n8n/requirements.txt` - Add redis package
- `_docs/examples/caching-patterns.md` - Caching guide
- `_debug/caching-example.json` - Example workflow

---

## Sprint 11: DealScale-Specific Integrations

### 11.1 Replace n8n Queue with Pulsar Bridge Architecture

**Priority**: Critical  
**Story Points**: 13  
**Status**: Planned

#### Overview
Replace n8n's internal BullMQ/Redis queue with a Pulsar bridge for distributed, scalable execution. Keep n8n's built-in queue for UI and short-running flows, use Pulsar for async, long-running, or distributed workloads.

#### Architecture Pattern
```
[n8n-main]  →  [REST bridge / Pulsar publisher]
[n8n-worker] ←  [Pulsar consumer → n8n Webhook trigger]
```

#### Acceptance Criteria
- `Given` Pulsar is configured as message bus
- `When` long-running workflows are triggered
- `Then` executions are routed through Pulsar bridge
- `And` n8n's internal queue handles short synchronous workflows
- `And` Pulsar handles async, distributed, and heavy workloads
- `And` execution routing is configurable per workflow type
- `And` backpressure and retries are handled by Pulsar
- `And` distributed tracing spans n8n → Pulsar → workers

#### Implementation Tasks
1. Configure queue-optimized settings:
   - `EXECUTIONS_MODE=queue` (keep for internal Redis queue)
   - `QUEUE_BULL_REDIS_ENABLED=false` (if not using Redis)
   - `DEALSCALE_PULSAR_QUEUE_ENABLED=true` (custom flag)
2. Create FastAPI REST bridge service (`/pulsar/publish` endpoint)
3. Implement Pulsar publisher in FastAPI bridge
4. Create Pulsar consumer service that triggers n8n webhooks
5. Set up Pulsar topic structure:
   - `dealscale.workflow.short`
   - `dealscale.workflow.long`
   - `dealscale.ai.inference`
   - `dealscale.analytics.events`
   - `dealscale.deadletter.<topic>` (for failed messages)
6. Implement message routing logic (short vs long workflows)
7. Add execution_id and tenant_id to Pulsar message metadata
8. Configure Pulsar retention (24h) and dead-letter queues
9. Test bidirectional communication (n8n → Pulsar → n8n)
10. Document routing strategy and configuration

#### Files to Create/Modify
- `docker-compose.yml` - Add Pulsar service and FastAPI bridge
- `pulsar-bridge/app.py` - FastAPI REST bridge with Pulsar publisher
- `pulsar-bridge/consumer.py` - Pulsar consumer that triggers n8n webhooks
- `pulsar-bridge/requirements.txt` - Python dependencies (pulsar-client, fastapi)
- `pulsar/pulsar.conf` - Pulsar broker configuration
- `_docs/integrations/pulsar-bridge.md` - Comprehensive Pulsar bridge guide
- `_debug/pulsar-bridge-example.json` - Example workflow using Pulsar
- `scripts/setup-pulsar-topics.sh` - Topic initialization script

---

### 11.2 Pulsar-Optimized Worker Topology

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` Pulsar topics are configured
- `When` workflows are executed
- `Then` topics are organized by workflow domain
- `And` each topic has 1 producer (n8n/FastAPI)
- `And` each topic has 1+ consumers (Python workers, enrichment bots)
- `And` failed messages are routed to dead-letter topics
- `And` topics support infinite scaling

#### Implementation Tasks
1. Create topic initialization script
2. Configure topic retention policies
3. Set up consumer groups for each topic
4. Implement dead-letter queue routing
5. Configure topic partitioning for scalability
6. Test multi-consumer scenarios
7. Document topic architecture

#### Files to Create/Modify
- `scripts/setup-pulsar-topics.sh` - Topic setup script
- `pulsar-bridge/topics.yml` - Topic configuration
- `_docs/integrations/pulsar-topology.md` - Topic architecture guide

---

### 11.3 Pulsar Security & Fault Isolation

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` Pulsar messages are published
- `When` messages contain sensitive data
- `Then` messages are signed using HMAC or JWT
- `And` tenant_id and execution_id are included in claims
- `And` execution payloads are stored in Postgres (not in Pulsar)
- `And` only execution IDs are passed in Pulsar messages
- `And` OAuth2 service accounts authenticate n8n ↔ Pulsar bridge
- `And` message retention prevents payload bloat

#### Implementation Tasks
1. Implement HMAC/JWT signing for Pulsar messages
2. Create payload storage service (Postgres-backed)
3. Update bridge to store payloads and pass IDs only
4. Configure OAuth2 service accounts
5. Set up JWT token validation in consumers
6. Implement tenant isolation in message routing
7. Configure message retention policies
8. Test security and isolation

#### Files to Create/Modify
- `pulsar-bridge/auth.py` - Authentication and signing
- `pulsar-bridge/payload-store.py` - Postgres payload storage
- `scripts/setup-pulsar-auth.sh` - Authentication setup
- `_docs/integrations/pulsar-security.md` - Security guide

---

### 11.4 Pulsar Observability & Metrics

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` Pulsar is running
- `When` metrics are collected
- `Then` Pulsar metrics are exported to Prometheus
- `And` metrics include: message rate, backlog, consumer lag
- `And` n8n metrics are exported (execution times, queue size)
- `And` FastAPI bridge metrics are exported (API latency, 2xx/5xx)
- `And` OpenTelemetry traces correlate n8n execution IDs with Pulsar message IDs
- `And` Grafana dashboards display unified metrics

#### Implementation Tasks
1. Configure Pulsar exporter for Prometheus (port 8080)
2. Configure n8n-prometheus-exporter (port 5679)
3. Add prometheus-fastapi-instrumentator to FastAPI bridge (port 8000)
4. Set up OpenTelemetry instrumentation for n8n → Pulsar → workers
5. Create Grafana dashboard for Pulsar metrics
6. Create unified dashboard combining n8n + Pulsar + FastAPI metrics
7. Configure alerting rules for backlog and consumer lag
8. Document observability setup

#### Files to Create/Modify
- `docker-compose.yml` - Add Pulsar exporter service
- `prometheus/pulsar-rules.yml` - Pulsar alerting rules
- `grafana/dashboards/pulsar-bridge-dashboard.json` - Unified dashboard
- `pulsar-bridge/otel-config.yml` - OpenTelemetry configuration
- `_docs/observability.md` - Update with Pulsar metrics section

---

### 11.5 Execution Strategy & Workflow Routing

**Priority**: High  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` workflows are created
- `When` workflows are executed
- `Then` routing strategy is applied:
  - Short synchronous (CRM sync, webhook reply) → Native n8n queue
  - Long asynchronous (AI enrichment, data pipelines) → Pulsar-routed
  - Multi-tenant orchestration → Pulsar topics per tenant/workspace
- `And` routing is configurable per workflow
- `And` routing decisions are logged

#### Implementation Tasks
1. Create workflow routing configuration system
2. Implement routing decision logic
3. Add workflow metadata for routing (short/long/tenant)
4. Create routing examples and templates
5. Document routing strategy
6. Test routing with various workflow types

#### Files to Create/Modify
- `pulsar-bridge/routing.py` - Routing decision logic
- `_docs/integrations/workflow-routing.md` - Routing guide
- `_debug/routing-examples/` - Example workflows by type

---

### 11.6 Qdrant Vector Search Optimization

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` vector embeddings are generated
- `When` embeddings are cached in Redis
- `Then` Qdrant queries are faster (5-10× speedup)
- `And` cache invalidation works correctly
- `And` performance is monitored

#### Implementation Tasks
1. Create embedding cache layer
2. Implement cache invalidation
3. Document caching strategy
4. Test performance improvements
5. Monitor cache hit rates

#### Files to Create/Modify
- `_docs/integrations/qdrant-optimization.md` - Optimization guide
- `scripts/embedding-cache.py` - Caching utility

---

### 11.7 GraphQL Persisted Queries

**Priority**: Medium  
**Story Points**: 5  
**Status**: Planned

#### Acceptance Criteria
- `Given` GraphQL queries are used
- `When` queries are persisted
- `Then` queries use short hashes
- `And` payload size is reduced
- `And` security is improved

#### Implementation Tasks
1. Document persisted query pattern
2. Create query hash generation script
3. Update FastAPI integration docs
4. Test query optimization

#### Files to Create/Modify
- `_docs/integrations/graphql.md` - GraphQL guide
- `scripts/generate-query-hash.py` - Hash generator

---

### 11.8 AI Workflow Offloading

**Priority**: High  
**Story Points**: 8  
**Status**: Planned

#### Acceptance Criteria
- `Given` AI inference tasks are heavy
- `When` workflows need AI processing
- `Then` tasks are offloaded to Python worker container
- `And` n8n remains responsive
- `And` latency is consistent

#### Implementation Tasks
1. Create Python worker service
2. Set up task queue for AI jobs
3. Create AI inference API
4. Document offloading pattern
5. Test performance

#### Files to Create/Modify
- `docker-compose.yml` - Add Python worker service
- `python-worker/app.py` - AI inference API
- `_docs/integrations/ai-offloading.md` - Offloading guide

---

## Implementation Priority Matrix

| Sprint | Features | Priority | Story Points | Estimated Effort |
|--------|----------|----------|--------------|------------------|
| Sprint 4 | Storage & S3 Backup | Critical | 16 | 2-3 weeks |
| Sprint 5 | Health Checks & Metrics | High | 13 | 2 weeks |
| Sprint 6 | Security Enhancements | High | 26 | 3-4 weeks |
| Sprint 7 | Performance Optimizations | High | 18 | 2-3 weeks |
| Sprint 8 | Developer Experience | Medium | 21 | 2-3 weeks |
| Sprint 9 | Observability | High | 13 | 2 weeks |
| Sprint 10 | Workflow Enhancements | High | 26 | 3-4 weeks |
| Sprint 11 | DealScale Integrations (Pulsar Bridge) | Critical | 50 | 5-6 weeks |

**Total**: 183 story points across 8 sprints

---

## Quick Reference: Environment Variables to Add

```bash
# Storage
N8N_USER_FOLDER=/data/n8n
N8N_EXPORT_FOLDER=/data/exports

# Performance
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_PRUNE_MAX_AGE=168
N8N_METRICS=true
N8N_METRICS_PORT=5679

# Security
EXECUTIONS_DATA_SAVE_ON_SUCCESS=true
EXECUTIONS_DATA_SAVE_ON_ERROR=all
N8N_BASIC_AUTH_ACTIVE=true

# S3 Backup
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
AWS_REGION=

# MinIO (optional)
MINIO_ACCESS_KEY=
MINIO_SECRET_KEY=
MINIO_BUCKET=

# Pulsar Bridge
DEALSCALE_PULSAR_QUEUE_ENABLED=true
PULSAR_SERVICE_URL=pulsar://pulsar:6650
PULSAR_HTTP_URL=http://pulsar:8080
PULSAR_TENANT=dealscale
PULSAR_NAMESPACE=workflows
PULSAR_AUTH_TOKEN=
PULSAR_OAUTH2_ISSUER_URL=
PULSAR_OAUTH2_AUDIENCE=

# FastAPI Bridge
FASTAPI_BRIDGE_PORT=8000
FASTAPI_BRIDGE_WEBHOOK_URL=http://n8n:5678/webhook/pulsar-trigger
```

---

## Next Steps

1. **Review and Prioritize**: Review this plan and prioritize sprints based on business needs
2. **Create Issues**: Break down each sprint into GitHub issues
3. **Start with Sprint 4**: Begin with storage enhancements as foundation
4. **Iterate**: Implement sprints incrementally, testing as you go

---

## Related Documentation

- [Current Implementation Status](COMPLETION_STATUS.md)
- [Architecture Overview](architecture.md)
- [Deployment Guide](deployment.md)
- [Performance Guide](performance.md) - To be created
- [Security Guide](security.md) - To be created
- [Observability Guide](observability.md) - To be created

---

**Plan Created**: 2025-01-11  
**Status**: Ready for Implementation  
**Estimated Timeline**: 18-26 weeks for full implementation

---

## Sprint 11 Deep Dive: Pulsar Bridge Architecture

### Why Pulsar Instead of BullMQ?

While n8n officially supports Redis/BullMQ for job queuing, Pulsar provides:
- **Infinite Scalability**: Beyond Redis memory limits
- **Durability**: Persistent message storage with retention
- **Multi-tenancy**: Native tenant/namespace isolation
- **Dead-letter Queues**: Built-in error handling
- **Distributed Tracing**: Better observability across services
- **Topic-based Routing**: Organize by workflow domain

### Execution Strategy Matrix

| Workflow Type | Queue System | Why |
|--------------|--------------|-----|
| Short synchronous (CRM sync, webhook reply) | Native n8n queue (Redis/BullMQ) | Needs fast return, low latency |
| Long asynchronous (AI enrichment, data pipelines) | Pulsar-routed | Heavy compute, retries, scaling |
| Multi-tenant orchestration | Pulsar topics per tenant/workspace | Isolation, replayability |
| Real-time UI updates | Native n8n queue | Immediate feedback |
| Batch processing | Pulsar-routed | Throughput, backpressure handling |

### Pulsar Topic Structure

```
dealscale.workflow.short      # Fast, synchronous workflows
dealscale.workflow.long       # Long-running async workflows
dealscale.ai.inference        # AI/ML inference tasks
dealscale.analytics.events    # Analytics and event processing
dealscale.deadletter.<topic>  # Failed message handling
```

### Message Flow Example

1. **n8n Workflow** → HTTP Request node → `POST /pulsar/publish`
2. **FastAPI Bridge** → Validates request → Stores payload in Postgres → Publishes to Pulsar topic with execution_id
3. **Pulsar** → Routes message to consumer → Handles retries/backpressure
4. **Pulsar Consumer** → Retrieves payload from Postgres → Calls n8n webhook → Triggers workflow
5. **n8n Webhook** → Receives trigger → Executes workflow → Returns result

### Security Architecture

- **Message Signing**: HMAC or JWT with tenant_id, execution_id claims
- **Payload Storage**: Postgres (not in Pulsar messages) to prevent bloat
- **Authentication**: OAuth2 service accounts for n8n ↔ Pulsar bridge
- **Tenant Isolation**: Separate topics/namespaces per tenant
- **Retention**: 24h message retention + dead-letter queues

### Observability Stack

```
n8n (port 5679) → Prometheus → Grafana
     ↓
Pulsar (port 8080) → Prometheus → Grafana
     ↓
FastAPI Bridge (port 8000) → Prometheus → Grafana
     ↓
OpenTelemetry → Tempo/Jaeger → Distributed Traces
```

### Key Metrics to Monitor

- **n8n**: Execution times, queue size, error rates
- **Pulsar**: Message rate, backlog, consumer lag, throughput
- **FastAPI Bridge**: API latency, 2xx/5xx counts, request rate
- **Correlation**: Execution IDs → Pulsar message IDs → Worker execution IDs

