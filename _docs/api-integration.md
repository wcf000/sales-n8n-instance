# API Integration Guide

## Overview

This guide explains how to configure and use n8n webhooks and API endpoints for integrating external applications with your workflows.

## Webhook Configuration

### Basic Webhook Setup

1. Create workflow with Webhook trigger node
2. Configure webhook:
   - **HTTP Method**: GET, POST, PUT, DELETE, etc.
   - **Path**: Custom path (e.g., `/webhook/my-workflow`)
   - **Response Mode**: Return response immediately or wait for workflow completion
3. Save and activate workflow
4. Copy webhook URL from node

### Webhook URL Format

- **Via Traefik**: `https://<TRAEFIK_DOMAIN>/webhook/<path>`
- **Direct**: `http://<n8n-host>:5678/webhook/<path>`

### Authentication

#### Option 1: Webhook Authentication (Recommended)

Configure in Webhook node:
- **Authentication**: Header Auth, Query Auth, or Basic Auth
- **Header Name**: Custom header name
- **Value**: Secret token

Example request:
```bash
curl -X POST https://n8n.example.com/webhook/my-workflow \
  -H "X-Webhook-Token: your-secret-token" \
  -H "Content-Type: application/json" \
  -d '{"data": "value"}'
```

#### Option 2: n8n User Authentication

Use n8n API credentials:
1. Create API credentials in n8n
2. Use in requests:
```bash
curl -X POST https://n8n.example.com/webhook/my-workflow \
  -u "username:password" \
  -H "Content-Type: application/json" \
  -d '{"data": "value"}'
```

### CORS Configuration

If calling from browser, configure CORS in n8n:

Set environment variable:
```
N8N_CORS_ORIGIN=https://your-frontend.com
```

Or allow all origins (not recommended for production):
```
N8N_CORS_ORIGIN=*
```

## n8n API

### Authentication

n8n API uses API keys or user credentials.

#### Create API Key

1. Go to Settings → API
2. Create new API key
3. Copy key for use in requests

#### Using API Key

```bash
curl -X GET https://n8n.example.com/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key"
```

### Common API Endpoints

#### Workflows

- **List workflows**: `GET /api/v1/workflows`
- **Get workflow**: `GET /api/v1/workflows/:id`
- **Create workflow**: `POST /api/v1/workflows`
- **Update workflow**: `PUT /api/v1/workflows/:id`
- **Delete workflow**: `DELETE /api/v1/workflows/:id`
- **Activate workflow**: `POST /api/v1/workflows/:id/activate`
- **Deactivate workflow**: `POST /api/v1/workflows/:id/deactivate`

#### Executions

- **List executions**: `GET /api/v1/executions`
- **Get execution**: `GET /api/v1/executions/:id`
- **Delete execution**: `DELETE /api/v1/executions/:id`

#### Webhooks

- **Test webhook**: `POST /webhook-test/:id`

### Example API Usage

#### List All Workflows

```bash
curl -X GET https://n8n.example.com/api/v1/workflows \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json"
```

#### Trigger Workflow via API

```bash
curl -X POST https://n8n.example.com/api/v1/workflows/:id/execute \
  -H "X-N8N-API-KEY: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "input": "value"
    }
  }'
```

#### Export Workflow

```bash
curl -X GET https://n8n.example.com/api/v1/workflows/:id \
  -H "X-N8N-API-KEY: your-api-key" \
  -o workflow.json
```

## Webhook Examples

### Simple Data Processing

1. Create workflow with Webhook trigger
2. Add Process node to transform data
3. Add Response node to return result
4. Test with:

```bash
curl -X POST https://n8n.example.com/webhook/process \
  -H "Content-Type: application/json" \
  -d '{"numbers": [1, 2, 3, 4, 5]}'
```

### File Upload Webhook

1. Configure webhook to accept multipart/form-data
2. Use Read Binary File node
3. Process file content
4. Return result

### Scheduled Webhook

Combine Webhook with Cron trigger:
1. Cron trigger runs on schedule
2. Webhook node makes external API call
3. Process response data

## Testing Webhooks

### Using Test Script

Run test script:
```bash
./_debug/test-webhook.sh
```

### Manual Testing

#### Test Webhook Endpoint

```bash
# Simple GET request
curl https://n8n.example.com/webhook/test

# POST with JSON
curl -X POST https://n8n.example.com/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'

# POST with form data
curl -X POST https://n8n.example.com/webhook/test \
  -F "field1=value1" \
  -F "field2=value2"
```

#### Test with Authentication

```bash
curl -X POST https://n8n.example.com/webhook/test \
  -H "X-Webhook-Token: secret-token" \
  -H "Content-Type: application/json" \
  -d '{"data": "value"}'
```

### Using n8n Test Feature

1. Open workflow in n8n UI
2. Click "Test workflow" button
3. Enter test data
4. Execute and review results

## Webhook Response Modes

### Respond Immediately

- Webhook returns immediately
- Workflow continues in background
- Use for fire-and-forget scenarios

### Wait for Workflow

- Webhook waits for workflow completion
- Returns workflow result
- Use when response is needed

### Response Node

Use Response node to customize response:
- Status code
- Headers
- Body content

## Security Best Practices

### 1. Use Authentication

Always secure webhooks with authentication:
- Header tokens
- Query parameters
- Basic auth
- OAuth (for advanced use cases)

### 2. Validate Input

- Validate all incoming data
- Sanitize inputs
- Check data types and formats

### 3. Rate Limiting

Configure rate limiting in Traefik:
```yaml
middlewares:
  rate-limit:
    rateLimit:
      average: 100
      burst: 50
```

### 4. HTTPS Only

Always use HTTPS in production:
- SSL/TLS certificates via Traefik
- Redirect HTTP to HTTPS

### 5. IP Whitelisting

Restrict webhook access by IP in Traefik:
```yaml
middlewares:
  ip-whitelist:
    ipWhiteList:
      sourceRange:
        - "1.2.3.4/32"
```

## Troubleshooting

### Webhook Not Receiving Requests

1. Verify workflow is activated
2. Check webhook URL is correct
3. Verify Traefik routing configuration
4. Check n8n logs: `docker compose logs n8n`

### Authentication Failures

1. Verify authentication configuration
2. Check token/credentials are correct
3. Review authentication method in webhook node

### CORS Errors

1. Configure `N8N_CORS_ORIGIN` environment variable
2. Verify origin is allowed
3. Check browser console for specific error

### Timeout Issues

1. Increase webhook timeout in n8n settings
2. Optimize workflow execution time
3. Use "Respond Immediately" mode for long workflows

## Example Workflows

See `_debug/test-webhook.json` for example webhook workflows demonstrating:
- Basic webhook trigger
- Authentication
- Data processing
- Response formatting

## Resources

- [n8n Webhook Documentation](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)
- [n8n API Documentation](https://docs.n8n.io/api/)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

