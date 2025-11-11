# CI/CD Pipeline Documentation

This directory contains GitHub Actions workflows for continuous integration and deployment of the self-hosted n8n instance.

## Workflows

### 1. CI (`ci.yml`)

**Triggers:**
- Push to `develop` or `main` branches
- Pull requests to `develop` or `main` branches

**Jobs:**
- **Lint**: Runs Ruff linter and mypy type checker on Python code
- **Test**: Runs pytest tests with PostgreSQL service container
- **Build**: Builds Docker images for n8n and api-bridge services

**Dependencies:**
- Python 3.11+
- Docker Buildx
- PostgreSQL 16 (for testing)

### 2. Deploy (`deploy.yml`)

**Triggers:**
- Push to `develop` or `main` branches
- Manual workflow dispatch with environment selection

**Jobs:**
- **Determine Environment**: Automatically selects staging (develop) or production (main)
- **Deploy**: 
  - Builds and pushes Docker images to GitHub Container Registry
  - Backs up database before deployment
  - Deploys via SSH to target server
  - Runs database migrations (if configured)
  - Verifies deployment health

**Required Secrets:**

For each environment (staging/production), configure these secrets in GitHub:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `{ENV}_HOST` | SSH hostname or IP | `staging.example.com` |
| `{ENV}_SSH_USER` | SSH username | `deploy` |
| `{ENV}_SSH_KEY` | SSH private key | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `{ENV}_DEPLOY_PATH` | Deployment directory path | `/opt/n8n-starter-kit` |
| `{ENV}_POSTGRES_USER` | PostgreSQL username | `n8n` |
| `{ENV}_POSTGRES_DB` | PostgreSQL database name | `n8n` |

**Example:**
- `STAGING_HOST`
- `STAGING_SSH_USER`
- `STAGING_SSH_KEY`
- `STAGING_DEPLOY_PATH`
- `STAGING_POSTGRES_USER`
- `STAGING_POSTGRES_DB`

### 3. Backup (`backup.yml`)

**Triggers:**
- Daily at 2 AM UTC (scheduled)
- Manual workflow dispatch

**Jobs:**
- **Backup**: Creates compressed PostgreSQL database backup
- Cleans up backups older than 30 days
- Optionally uploads backup as artifact (manual runs only)

**Required Secrets:**
Same as Deploy workflow for the target environment.

## Setup Instructions

### 1. Configure GitHub Secrets

1. Go to your repository → Settings → Secrets and variables → Actions
2. Create environments: `staging` and `production`
3. Add the required secrets for each environment (see Deploy section above)

### 2. Configure SSH Access

Generate an SSH key pair for deployment:

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github-actions-deploy
```

Add the public key to your server's `~/.ssh/authorized_keys`:

```bash
cat ~/.ssh/github-actions-deploy.pub | ssh user@your-server "cat >> ~/.ssh/authorized_keys"
```

Add the private key to GitHub Secrets as `{ENV}_SSH_KEY`.

### 3. Update Deployment Path

Update the deployment path in `deploy.yml` if your project is located elsewhere:

```yaml
cd /opt/n8n-starter-kit || cd ${{ secrets[format('{0}_DEPLOY_PATH', env.ENVIRONMENT)] }}
```

### 4. Configure Docker Compose for Production

Ensure your `docker-compose.yml` uses image tags that match the registry:

```yaml
services:
  n8n:
    image: ghcr.io/your-org/n8n-custom:latest
  api-bridge:
    image: ghcr.io/your-org/api-bridge:latest
```

Or use environment-specific tags:

```yaml
services:
  n8n:
    image: ghcr.io/your-org/n8n-custom:${ENVIRONMENT}-latest
  api-bridge:
    image: ghcr.io/your-org/api-bridge:${ENVIRONMENT}-latest
```

### 5. Enable GitHub Container Registry

The workflows use GitHub Container Registry (GHCR). Ensure:
- Your repository has write permissions
- The `GITHUB_TOKEN` secret is available (automatically provided by GitHub Actions)

## Customization

### Adding Database Migrations

If you use Alembic or similar migration tool, uncomment and configure in `deploy.yml`:

```yaml
- name: Run database migrations
  run: |
    docker compose exec -T api-bridge alembic upgrade head
```

### Adding Notifications

Add notification steps to workflows (Slack, Discord, email, etc.):

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment to ${{ env.ENVIRONMENT }}: ${{ job.status }}'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Adjusting Backup Schedule

Modify the cron schedule in `backup.yml`:

```yaml
schedule:
  - cron: '0 2 * * *'  # Daily at 2 AM UTC
  # - cron: '0 */6 * * *'  # Every 6 hours
```

### Adding More Test Coverage

Add test files in `api-bridge/tests/` and update pytest configuration:

```python
# api-bridge/pytest.ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
```

## Troubleshooting

### Build Failures

- Check Dockerfile syntax
- Verify all dependencies in requirements.txt
- Check GitHub Actions logs for specific errors

### Deployment Failures

- Verify SSH key is correctly added to secrets
- Test SSH connection manually: `ssh -i key user@host`
- Check server disk space: `df -h`
- Verify Docker is running on target server: `docker ps`

### Backup Failures

- Verify PostgreSQL container is running
- Check database credentials in secrets
- Ensure backup directory has write permissions
- Check disk space on server

### Health Check Failures

- Verify services are listening on correct ports
- Check container logs: `docker compose logs n8n api-bridge`
- Ensure health endpoints are accessible: `/healthz` and `/health`

## Security Best Practices

1. **Never commit secrets**: All sensitive data should be in GitHub Secrets
2. **Use environment-specific secrets**: Separate staging and production credentials
3. **Rotate SSH keys regularly**: Update deployment keys periodically
4. **Limit SSH access**: Use dedicated deployment user with minimal permissions
5. **Enable branch protection**: Require CI to pass before merging to main
6. **Review deployment logs**: Monitor for unauthorized access attempts

## Monitoring

Monitor workflow runs in GitHub Actions tab:
- View logs for each job
- Set up notifications for workflow failures
- Review deployment history
- Check backup completion status

