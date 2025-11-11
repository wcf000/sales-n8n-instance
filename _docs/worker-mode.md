# Worker Mode Configuration

## Overview

Worker mode enables distributed workflow execution by separating the n8n main instance (UI/API) from worker instances (execution only). This allows horizontal scaling and improved performance.

## Architecture

```
┌─────────────────┐
│   n8n Main      │  UI, API, Workflow Management
│   (Port 5678)   │
└────────┬────────┘
         │
         │ Queue Jobs
         │
┌────────▼────────┐
│     Redis       │  Job Queue (Bull)
│   (Port 6379)   │
└────────┬────────┘
         │
    ┌────┴────┬──────────┬──────────┐
    │         │          │          │
┌───▼───┐ ┌──▼───┐  ┌───▼───┐  ┌───▼───┐
│Worker1│ │Worker2│  │Worker3│  │WorkerN│
└───────┘ └───────┘  └───────┘  └───────┘
```

## Configuration

### 1. Enable Worker Mode

Set environment variables in `.env`:

```bash
# Execution mode
EXECUTIONS_MODE=queue

# Redis configuration
QUEUE_BULL_REDIS_HOST=redis
QUEUE_BULL_REDIS_PORT=6379
QUEUE_BULL_REDIS_PASSWORD=
QUEUE_BULL_REDIS_DB=0
```

### 2. Docker Compose Configuration

Update `docker-compose.yml` to include:

- Redis service
- n8n-main service (UI/API)
- n8n-worker service(s) (execution)

### 3. Service Configuration

#### n8n Main Service

```yaml
n8n-main:
  environment:
    - EXECUTIONS_MODE=queue
    - QUEUE_BULL_REDIS_HOST=redis
    - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
  depends_on:
    - postgres
    - redis
```

#### n8n Worker Service

```yaml
n8n-worker:
  environment:
    - EXECUTIONS_MODE=queue
    - QUEUE_BULL_REDIS_HOST=redis
    - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
    - N8N_DIAGNOSTICS_ENABLED=false
  command: worker
  depends_on:
    - postgres
    - redis
```

## Starting Services

### Start All Services

```bash
docker compose up -d n8n-main n8n-worker redis
```

### Scale Workers

```bash
# Start multiple workers
docker compose up -d --scale n8n-worker=3
```

### Verify Worker Mode

1. Check n8n UI shows "Queue" execution mode
2. Trigger a workflow
3. Verify execution shows worker instance in logs

## Execution Flow

### 1. Workflow Trigger

- User triggers workflow via UI or webhook
- n8n-main receives request

### 2. Job Queuing

- Workflow execution job added to Redis queue
- Job includes workflow data and execution context

### 3. Worker Processing

- Available worker picks up job from queue
- Worker executes workflow nodes
- Results stored in PostgreSQL

### 4. Completion

- Worker marks job as complete
- n8n-main updates UI with results
- User sees execution in history

## Monitoring

### Check Queue Status

```bash
# Connect to Redis
docker compose exec redis redis-cli

# Check queue length
LLEN bull:n8n:queue

# List jobs
KEYS bull:n8n:*
```

### View Worker Logs

```bash
# Main instance logs
docker compose logs -f n8n-main

# Worker logs
docker compose logs -f n8n-worker

# All n8n logs
docker compose logs -f n8n-main n8n-worker
```

### Health Checks

All services include health checks:
- n8n-main: HTTP health endpoint
- n8n-worker: Process health check
- Redis: Redis ping

## Scaling

### Horizontal Scaling

Add more worker instances:

```bash
docker compose up -d --scale n8n-worker=5
```

### Resource Limits

Configure resource limits per service:

```yaml
n8n-worker:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        cpus: '1'
        memory: 1G
```

### Load Balancing

Workers automatically balance load via Redis queue:
- First available worker picks up job
- No manual load balancing needed
- Automatic failover if worker fails

## Performance Tuning

### Redis Configuration

Optimize Redis for queue performance:

```yaml
redis:
  command: redis-server --maxmemory 512mb --maxmemory-policy allkeys-lru
```

### Worker Configuration

Tune worker concurrency:

```bash
# Process multiple jobs concurrently per worker
EXECUTIONS_PROCESS=main
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
```

### Database Connection Pooling

Configure PostgreSQL connection pool:

```bash
DB_POSTGRESDB_POOL_SIZE=20
DB_POSTGRESDB_TIMEOUT=30000
```

## Troubleshooting

### Workers Not Processing Jobs

1. Verify Redis is running: `docker compose ps redis`
2. Check Redis connection: `docker compose exec redis redis-cli ping`
3. Verify worker logs for errors
4. Check queue for stuck jobs

### Jobs Stuck in Queue

1. Check Redis queue: `docker compose exec redis redis-cli LLEN bull:n8n:queue`
2. Verify workers are running: `docker compose ps n8n-worker`
3. Check worker logs for errors
4. Clear stuck jobs if needed

### High Memory Usage

1. Monitor worker memory: `docker stats`
2. Reduce worker concurrency
3. Increase worker resources
4. Optimize workflow execution

### Connection Issues

1. Verify network connectivity between services
2. Check Redis host/port configuration
3. Verify database connection
4. Review service logs

## Best Practices

### 1. Resource Allocation

- Allocate sufficient resources to workers
- Monitor resource usage
- Scale based on load

### 2. Error Handling

- Configure error handling in workflows
- Set up alerts for failed executions
- Review error logs regularly

### 3. Queue Management

- Monitor queue length
- Set up alerts for queue backlog
- Scale workers based on queue depth

### 4. Database Optimization

- Use connection pooling
- Optimize database queries
- Regular database maintenance

## Migration from Single Instance

### Step 1: Backup

```bash
./scripts/backup.sh
```

### Step 2: Update Configuration

1. Add Redis service
2. Update docker-compose.yml
3. Set `EXECUTIONS_MODE=queue`

### Step 3: Deploy

```bash
docker compose down
docker compose up -d
```

### Step 4: Verify

1. Check execution mode in UI
2. Test workflow execution
3. Verify worker processing

## Disabling Worker Mode

To return to single instance mode:

1. Set `EXECUTIONS_MODE=regular`
2. Stop worker services
3. Restart main service

```bash
docker compose stop n8n-worker
docker compose up -d n8n-main
```

## Resources

- [n8n Worker Mode Documentation](https://docs.n8n.io/hosting/installation/worker-mode/)
- [Redis Documentation](https://redis.io/docs/)
- [Bull Queue Documentation](https://github.com/OptimalBits/bull)

