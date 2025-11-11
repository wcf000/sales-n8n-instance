# Monitoring Guide

## Overview

This guide covers monitoring setup for the n8n platform using Prometheus and Grafana.

## Architecture

```
n8n (port 5679) → Prometheus (port 9090) → Grafana (port 3000)
```

## Prerequisites

- Docker Compose with monitoring profile
- n8n metrics enabled (`N8N_METRICS=true`)

## Quick Start

### 1. Enable Monitoring

```bash
# Start monitoring stack
docker compose --profile monitoring up -d prometheus grafana

# Verify services
docker compose ps prometheus grafana
```

### 2. Access Dashboards

- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000
  - Default login: `admin` / `admin`
  - Change password on first login

### 3. View n8n Metrics

In Prometheus, query:
```
rate(n8n_executions_total[5m])
```

## n8n Metrics

### Available Metrics

n8n exposes the following metrics on port 5679:

- `n8n_executions_total` - Total number of executions
- `n8n_executions_failed_total` - Failed executions
- `n8n_execution_duration_seconds` - Execution duration histogram
- `n8n_queue_size` - Current queue size
- `n8n_workflows_active` - Active workflows count

### Metrics Endpoint

```bash
# View raw metrics
curl http://localhost:5679/metrics

# From within Docker network
docker compose exec n8n curl http://localhost:5679/metrics
```

## Prometheus Configuration

### Scrape Configuration

Prometheus is configured to scrape:
- **n8n**: Every 30 seconds from `n8n:5679`
- **Prometheus itself**: For self-monitoring

### Alert Rules

Alert rules are defined in `prometheus/rules/n8n-alerts.yml`:

- **N8nDown**: Alert when n8n is down
- **N8nHighErrorRate**: Alert on high error rates
- **N8nHighExecutionTime**: Alert on slow executions
- **N8nQueueBacklog**: Alert on queue backlog

### View Alerts

1. Access Prometheus: http://localhost:9090
2. Navigate to "Alerts" tab
3. View active alerts and their status

## Grafana Dashboards

### Pre-configured Dashboard

The **n8n Platform Monitoring** dashboard includes:

1. **Execution Status**: Total executions per second
2. **Error Rate**: Failed executions per second
3. **Queue Size**: Current queue backlog
4. **Execution Duration**: 95th percentile execution time
5. **Executions by Status**: Pie chart of execution statuses

### Access Dashboard

1. Login to Grafana: http://localhost:3000
2. Navigate to "Dashboards" → "n8n"
3. Select "n8n Platform Monitoring"

### Custom Dashboards

Create custom dashboards:
1. Click "+" → "Create Dashboard"
2. Add panels with Prometheus queries
3. Save dashboard to `grafana/dashboards/`

## Key Metrics to Monitor

### Execution Metrics

```promql
# Execution rate
rate(n8n_executions_total[5m])

# Error rate
rate(n8n_executions_failed_total[5m])

# Success rate
rate(n8n_executions_total{status="success"}[5m]) / rate(n8n_executions_total[5m])
```

### Performance Metrics

```promql
# 95th percentile execution time
histogram_quantile(0.95, rate(n8n_execution_duration_seconds_bucket[5m]))

# Average execution time
rate(n8n_execution_duration_seconds_sum[5m]) / rate(n8n_execution_duration_seconds_count[5m])
```

### Queue Metrics

```promql
# Current queue size
n8n_queue_size

# Queue growth rate
rate(n8n_queue_size[5m])
```

## Alerting

### Configure Alertmanager (Optional)

1. Add Alertmanager service to docker-compose.yml
2. Configure notification channels (email, Slack, etc.)
3. Update Prometheus configuration to use Alertmanager

### Alert Examples

**High Error Rate Alert:**
```yaml
- alert: N8nHighErrorRate
  expr: rate(n8n_executions_failed_total[5m]) > 0.1
  for: 5m
  annotations:
    summary: "High error rate in n8n"
```

**Queue Backlog Alert:**
```yaml
- alert: N8nQueueBacklog
  expr: n8n_queue_size > 100
  for: 5m
  annotations:
    summary: "High queue backlog"
```

## Troubleshooting

### Metrics Not Appearing

1. **Check n8n metrics are enabled:**
   ```bash
   docker compose exec n8n env | grep N8N_METRICS
   ```

2. **Verify metrics endpoint:**
   ```bash
   docker compose exec n8n curl http://localhost:5679/metrics
   ```

3. **Check Prometheus targets:**
   - Access Prometheus: http://localhost:9090
   - Navigate to "Status" → "Targets"
   - Verify n8n target is "UP"

### Grafana Not Loading Dashboards

1. **Check dashboard files:**
   ```bash
   ls -la grafana/dashboards/
   ```

2. **Verify provisioning:**
   ```bash
   docker compose exec grafana cat /etc/grafana/provisioning/dashboards/dashboards.yml
   ```

3. **Check Grafana logs:**
   ```bash
   docker compose logs grafana
   ```

### Prometheus Not Scraping

1. **Check Prometheus configuration:**
   ```bash
   docker compose exec prometheus cat /etc/prometheus/prometheus.yml
   ```

2. **Verify network connectivity:**
   ```bash
   docker compose exec prometheus ping n8n
   ```

3. **Check Prometheus logs:**
   ```bash
   docker compose logs prometheus
   ```

## Best Practices

### Retention

Configure Prometheus retention in `prometheus/prometheus.yml`:
```yaml
global:
  storage.tsdb.retention.time: 30d
```

### Resource Limits

Set resource limits for monitoring services:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
      cpus: '1'
```

### Backup

Backup Grafana dashboards and Prometheus data:
```bash
# Backup Grafana
docker compose exec grafana tar czf /tmp/grafana-backup.tar.gz /var/lib/grafana

# Backup Prometheus
docker compose exec prometheus tar czf /tmp/prometheus-backup.tar.gz /prometheus
```

## Resources

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [n8n Metrics Documentation](https://docs.n8n.io/hosting/configuration/#metrics)

