# Quick Setup Guide for CI/CD Pipeline

This guide will help you set up the CI/CD pipeline for your n8n instance in under 10 minutes.

## Prerequisites

- GitHub repository with Actions enabled
- Server with Docker and Docker Compose installed
- SSH access to your deployment server
- Basic understanding of GitHub Secrets

## Step 1: Configure GitHub Secrets (5 minutes)

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** or **New environment secret**

### Create Environments

First, create two environments:
1. Click **New environment** → Name it `staging`
2. Click **New environment** → Name it `production`

### Add Secrets for Each Environment

For **staging** environment, add:

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `STAGING_HOST` | Your server IP or domain | `your-staging-server.com` |
| `STAGING_SSH_USER` | SSH username | Usually `root` or `deploy` |
| `STAGING_SSH_KEY` | SSH private key | See Step 2 below |
| `STAGING_DEPLOY_PATH` | Project directory | `/opt/n8n-starter-kit` |
| `STAGING_POSTGRES_USER` | PostgreSQL user | From your `.env` file |
| `STAGING_POSTGRES_DB` | Database name | Usually `n8n` |

Repeat for **production** environment with `PRODUCTION_*` prefix.

## Step 2: Generate SSH Key for Deployment (2 minutes)

On your local machine:

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "github-actions-deploy" -f ~/.ssh/github-actions-deploy

# Display the private key (copy this to GitHub Secret)
cat ~/.ssh/github-actions-deploy

# Display the public key (add this to your server)
cat ~/.ssh/github-actions-deploy.pub
```

### Add Public Key to Server

```bash
# Copy public key to server
ssh-copy-id -i ~/.ssh/github-actions-deploy.pub user@your-server

# Or manually add to authorized_keys
cat ~/.ssh/github-actions-deploy.pub | ssh user@your-server "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

### Add Private Key to GitHub

1. Copy the entire private key content (including `-----BEGIN` and `-----END` lines)
2. Go to GitHub → Settings → Secrets → Actions
3. Select the environment (staging/production)
4. Add secret: `{ENV}_SSH_KEY` with the private key content

## Step 3: Update Docker Compose for Production (2 minutes)

Update your `docker-compose.yml` to use the container registry images:

```yaml
services:
  n8n:
    # Replace build section with image
    image: ghcr.io/YOUR_GITHUB_USERNAME/n8n-custom:latest
    # Remove or comment out:
    # build:
    #   context: ./n8n
    #   dockerfile: Dockerfile

  api-bridge:
    image: ghcr.io/YOUR_GITHUB_USERNAME/api-bridge:latest
    # Remove or comment out:
    # build:
    #   context: ./api-bridge
    #   dockerfile: Dockerfile
```

Replace `YOUR_GITHUB_USERNAME` with your GitHub username or organization name.

## Step 4: Test the Pipeline (1 minute)

1. Push a commit to the `develop` branch:
   ```bash
   git checkout develop
   git commit --allow-empty -m "Test CI/CD pipeline"
   git push origin develop
   ```

2. Go to GitHub → **Actions** tab
3. Watch the workflows run:
   - `CI` workflow should run first (lint, test, build)
   - `Deploy` workflow should run after CI passes

## Step 5: Verify Deployment

SSH into your server and check:

```bash
# Check running containers
docker compose ps

# Check logs
docker compose logs n8n
docker compose logs api-bridge

# Verify health endpoints
curl http://localhost:5678/healthz  # n8n
curl http://localhost:8000/health   # API bridge
```

## Troubleshooting

### CI Workflow Fails

**Issue**: Tests fail
- **Solution**: Add tests to `api-bridge/tests/` or make tests optional in `ci.yml`

**Issue**: Linting fails
- **Solution**: Run `ruff check api-bridge/` locally and fix issues
- Or set `continue-on-error: true` in the lint job

### Deploy Workflow Fails

**Issue**: SSH connection fails
- **Solution**: 
  - Verify SSH key is correct in GitHub Secrets
  - Test SSH manually: `ssh -i ~/.ssh/github-actions-deploy user@host`
  - Check server firewall allows SSH

**Issue**: Docker pull fails
- **Solution**:
  - Verify GitHub Container Registry permissions
  - Check image tags match in `docker-compose.yml`
  - Ensure `GITHUB_TOKEN` is available (auto-provided)

**Issue**: Health check fails
- **Solution**:
  - Check container logs: `docker compose logs`
  - Verify services are running: `docker compose ps`
  - Increase timeout in health check step

### Backup Workflow Fails

**Issue**: Backup fails
- **Solution**:
  - Verify PostgreSQL container is running
  - Check database credentials
  - Ensure backup directory exists and is writable

## Next Steps

1. **Add more tests**: Expand test coverage in `api-bridge/tests/`
2. **Configure notifications**: Add Slack/Discord/email notifications
3. **Set up monitoring**: Integrate with Prometheus/Grafana
4. **Add database migrations**: Configure Alembic if needed
5. **Enable branch protection**: Require CI to pass before merging

## Security Checklist

- [ ] SSH keys are stored in GitHub Secrets (not in code)
- [ ] Different keys for staging and production
- [ ] Deployment user has minimal permissions
- [ ] Database credentials are in secrets
- [ ] Branch protection rules enabled
- [ ] Regular backup verification

## Support

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review `.github/workflows/README.md` for detailed documentation
3. Check server logs: `docker compose logs`

