# Community Nodes Installation

## Overview

Community nodes are third-party n8n nodes developed by the community. This guide explains how to install and manage community nodes in your self-hosted n8n instance.

## Configuration File

Community nodes are configured via `n8n/community-nodes.json`:

```json
{
  "packages": [
    {
      "name": "@n8n/n8n-nodes-langchain",
      "version": "latest"
    },
    {
      "name": "n8n-nodes-example",
      "version": "1.0.0"
    }
  ]
}
```

## Installation Methods

### Method 1: Configuration File (Recommended)

1. Edit `n8n/community-nodes.json`
2. Add package entries with name and version
3. Restart n8n:

```bash
docker compose restart n8n
```

### Method 2: Environment Variable

Set in `.env`:

```
N8N_COMMUNITY_NODES_INCLUDE=@n8n/n8n-nodes-langchain@latest,n8n-nodes-example@1.0.0
```

### Method 3: Manual Installation

```bash
docker compose exec n8n npm install @n8n/n8n-nodes-langchain@latest
docker compose restart n8n
```

## Finding Community Nodes

### Official n8n Nodes

- [n8n-nodes-langchain](https://www.npmjs.com/package/@n8n/n8n-nodes-langchain): LangChain integration
- [n8n-nodes-base](https://www.npmjs.com/package/n8n-nodes-base): Core nodes (included by default)

### Community Repository

Search NPM for `n8n-nodes-*` packages:
- [NPM Search](https://www.npmjs.com/search?q=keywords:n8n-node)

### n8n Community Forum

- [Community Nodes Discussion](https://community.n8n.io/c/community-nodes/5)

## Version Management

### Latest Version

```json
{
  "name": "package-name",
  "version": "latest"
}
```

### Specific Version

```json
{
  "name": "package-name",
  "version": "1.2.3"
}
```

### Version Range

Use semantic versioning ranges:
- `^1.2.3`: Compatible with 1.x.x
- `~1.2.3`: Compatible with 1.2.x
- `>=1.2.3`: Version 1.2.3 or higher

## Updating Nodes

### Update All Nodes

1. Update versions in `community-nodes.json`
2. Restart n8n:

```bash
docker compose restart n8n
```

### Update Single Node

```bash
docker compose exec n8n npm update package-name
docker compose restart n8n
```

## Removing Nodes

1. Remove from `community-nodes.json`
2. Uninstall package:

```bash
docker compose exec n8n npm uninstall package-name
docker compose restart n8n
```

## Private Registry Support

### Configure Private Registry

Set in `.env`:

```
NPM_REGISTRY=https://your-registry.com
NPM_TOKEN=your-auth-token
```

Or configure in container:

```bash
docker compose exec n8n npm config set registry https://your-registry.com
docker compose exec n8n npm config set //your-registry.com/:_authToken YOUR_TOKEN
```

## Troubleshooting

### Nodes Not Appearing

1. Check package name and version
2. Verify package exists on NPM
3. Check n8n logs: `docker compose logs n8n`
4. Verify `N8N_COMMUNITY_PACKAGES_ENABLED=true` in environment

### Installation Errors

1. Check network connectivity
2. Verify NPM registry access
3. Check package compatibility with n8n version
4. Review error logs: `docker compose logs n8n`

### Version Conflicts

1. Check for conflicting dependencies
2. Update n8n to latest version
3. Use compatible node versions
4. Check node documentation for requirements

## Best Practices

### 1. Version Pinning

Pin specific versions for production:
```json
{
  "name": "package-name",
  "version": "1.2.3"
}
```

### 2. Regular Updates

- Review and update nodes quarterly
- Test updates in development first
- Check changelogs for breaking changes

### 3. Security

- Only install from trusted sources
- Review package code when possible
- Keep nodes updated for security patches

### 4. Documentation

- Document why each node is installed
- Note any custom configurations
- Keep list of installed nodes in README

## Example Configuration

Complete `community-nodes.json` example:

```json
{
  "packages": [
    {
      "name": "@n8n/n8n-nodes-langchain",
      "version": "latest",
      "description": "LangChain integration for AI workflows"
    },
    {
      "name": "n8n-nodes-custom-api",
      "version": "1.0.0",
      "description": "Custom API integration"
    }
  ]
}
```

## Verification

After installation, verify nodes are available:

1. Open n8n UI
2. Create new workflow
3. Search for node name in node palette
4. Verify node appears and can be added

## Resources

- [n8n Community Nodes Documentation](https://docs.n8n.io/integrations/community-nodes/)
- [Creating Custom Nodes](../custom-nodes.md)
- [NPM Package Search](https://www.npmjs.com/)

