# Troubleshooting Guide

## Common Issues and Solutions

### Services Not Starting

#### Problem: Container fails to start

**Symptoms:**
- Container exits immediately
- Error in `docker compose logs`

**Solutions:**
1. Check logs: `docker compose logs <service-name>`
2. Verify environment variables in `.env`
3. Check port conflicts: `netstat -tulpn | grep <port>`
4. Verify Docker resources (memory, disk space)
5. Check Docker daemon is running: `docker ps`

#### Problem: Port already in use

**Symptoms:**
- Error: "port is already allocated"

**Solutions:**
```bash
# Find process using port
lsof -i :5678
# or
netstat -tulpn | grep 5678

# Kill process or change port in docker-compose.yml
```

### Database Connection Issues

#### Problem: Cannot connect to PostgreSQL

**Symptoms:**
- n8n logs show database connection errors
- Workflows not saving

**Solutions:**
1. Verify PostgreSQL is running: `docker compose ps postgres`
2. Check database credentials in `.env`
3. Verify network connectivity: `docker compose exec n8n ping postgres`
4. Check PostgreSQL logs: `docker compose logs postgres`
5. Verify database exists: `docker compose exec postgres psql -U ${POSTGRES_USER} -l`

#### Problem: Database migration errors

**Symptoms:**
- n8n startup fails with migration errors

**Solutions:**
1. Check n8n version compatibility
2. Backup database before upgrading
3. Run migrations manually if needed
4. Check PostgreSQL version compatibility

### Python Environment Issues

#### Problem: Python not found

**Symptoms:**
- Execute Command node fails with "python: command not found"

**Solutions:**
1. Verify Dockerfile built correctly: `docker compose build n8n`
2. Check Python in container: `docker compose exec n8n python3 --version`
3. Rebuild image: `docker compose build --no-cache n8n`
4. Check Dockerfile syntax

#### Problem: Python package import errors

**Symptoms:**
- `ModuleNotFoundError` when importing packages

**Solutions:**
1. Verify package in `requirements.txt`
2. Check installation: `docker compose exec n8n pip list`
3. Rebuild image with updated requirements
4. Verify package name spelling

### Traefik Routing Issues

#### Problem: Cannot access n8n via Traefik

**Symptoms:**
- 404 or connection refused via domain
- Direct port access works

**Solutions:**
1. Check Traefik logs: `docker compose logs traefik`
2. Verify domain DNS points to server
3. Check Traefik configuration files
4. Verify routing rules in `traefik/dynamic/n8n.yml`
5. Check SSL certificate generation

#### Problem: SSL certificate errors

**Symptoms:**
- Browser shows SSL errors
- Certificate not trusted

**Solutions:**
1. For Let's Encrypt: Verify domain and email configured
2. Check certificate generation: `docker compose logs traefik | grep acme`
3. Verify ports 80/443 accessible
4. For self-signed: Accept certificate in browser
5. Check certificate expiration

### Webhook Issues

#### Problem: Webhook not receiving requests

**Symptoms:**
- External service cannot reach webhook
- 404 or timeout errors

**Solutions:**
1. Verify workflow is activated
2. Check webhook URL is correct
3. Verify Traefik routing to n8n
4. Check firewall rules
5. Test webhook locally first

#### Problem: Webhook authentication failures

**Symptoms:**
- 401 Unauthorized errors
- Authentication not working

**Solutions:**
1. Verify authentication configuration in webhook node
2. Check token/credentials are correct
3. Verify header names match
4. Test with curl to isolate issue

### Worker Mode Issues

#### Problem: Workers not processing jobs

**Symptoms:**
- Jobs stuck in queue
- No worker activity

**Solutions:**
1. Verify Redis is running: `docker compose ps redis`
2. Check Redis connection: `docker compose exec redis redis-cli ping`
3. Verify worker logs: `docker compose logs n8n-worker`
4. Check queue: `docker compose exec redis redis-cli LLEN bull:n8n:queue`
5. Verify `EXECUTIONS_MODE=queue` is set

#### Problem: Jobs stuck in queue

**Symptoms:**
- Queue length increasing
- No jobs being processed

**Solutions:**
1. Check worker status: `docker compose ps n8n-worker`
2. Review worker logs for errors
3. Restart workers: `docker compose restart n8n-worker`
4. Clear stuck jobs if needed
5. Verify Redis connectivity

### Performance Issues

#### Problem: Slow workflow execution

**Symptoms:**
- Workflows take too long
- Timeout errors

**Solutions:**
1. Check resource usage: `docker stats`
2. Optimize workflow (reduce nodes, use batching)
3. Increase Docker resources
4. Enable worker mode for parallel execution
5. Check database performance

#### Problem: High memory usage

**Symptoms:**
- Containers using excessive memory
- Out of memory errors

**Solutions:**
1. Monitor memory: `docker stats`
2. Set resource limits in docker-compose.yml
3. Optimize workflows
4. Increase Docker memory allocation
5. Check for memory leaks in custom code

### Backup and Recovery Issues

#### Problem: Backup script fails

**Symptoms:**
- Backup script errors
- No backup files created

**Solutions:**
1. Check script permissions: `chmod +x scripts/backup.sh`
2. Verify Docker socket access
3. Check disk space: `df -h`
4. Verify database credentials
5. Check script logs

#### Problem: Restore fails

**Symptoms:**
- Database restore errors
- Data not restored correctly

**Solutions:**
1. Verify backup file integrity
2. Check database credentials
3. Stop services before restore
4. Verify backup file format
5. Check restore script logs

## Debugging Tools

### Container Inspection

```bash
# Enter container shell
docker compose exec n8n sh

# Check environment variables
docker compose exec n8n env

# View container processes
docker compose exec n8n ps aux
```

### Log Analysis

```bash
# View all logs
docker compose logs

# Follow logs
docker compose logs -f

# Filter logs
docker compose logs n8n | grep ERROR

# Last 100 lines
docker compose logs --tail=100 n8n
```

### Network Debugging

```bash
# Test connectivity
docker compose exec n8n ping postgres
docker compose exec n8n ping redis

# Check DNS resolution
docker compose exec n8n nslookup postgres

# Test port connectivity
docker compose exec n8n nc -zv postgres 5432
```

### Database Debugging

```bash
# Connect to database
docker compose exec postgres psql -U ${POSTGRES_USER} ${POSTGRES_DB}

# Check connections
docker compose exec postgres psql -U ${POSTGRES_USER} -c "SELECT count(*) FROM pg_stat_activity;"

# Check database size
docker compose exec postgres psql -U ${POSTGRES_USER} -c "SELECT pg_size_pretty(pg_database_size('${POSTGRES_DB}'));"
```

## Getting Help

### Log Collection

Before seeking help, collect:

1. **Service Logs**
   ```bash
   docker compose logs > logs.txt
   ```

2. **System Information**
   ```bash
   docker --version
   docker compose version
   docker compose ps
   docker stats --no-stream
   ```

3. **Configuration**
   - `.env` file (remove secrets)
   - `docker-compose.yml`
   - Relevant config files

### Community Resources

- [n8n Community Forum](https://community.n8n.io/)
- [n8n GitHub Issues](https://github.com/n8n-io/n8n/issues)
- [n8n Documentation](https://docs.n8n.io/)

### Diagnostic Scripts

Run diagnostic scripts in `_debug/`:

```bash
# Validate Python environment
./_debug/validate-python.sh

# Test webhook
./_debug/test-webhook.sh

# Health check
./_debug/monitoring/health-check.sh
```

## Prevention

### Regular Maintenance

1. **Update Regularly**
   - Keep Docker images updated
   - Update n8n version
   - Update Python packages

2. **Monitor Resources**
   - Check disk space regularly
   - Monitor memory usage
   - Review logs for errors

3. **Test Backups**
   - Verify backups are created
   - Test restore procedures
   - Check backup integrity

4. **Security Updates**
   - Apply security patches
   - Update dependencies
   - Review access controls

### Best Practices

1. **Documentation**
   - Document custom configurations
   - Keep change logs
   - Document known issues

2. **Testing**
   - Test changes in development first
   - Verify after updates
   - Test disaster recovery

3. **Monitoring**
   - Set up alerts
   - Monitor key metrics
   - Review logs regularly

