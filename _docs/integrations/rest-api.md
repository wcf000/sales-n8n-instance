# REST API Bridge Guide

## Overview

The REST API Bridge provides HTTP endpoints for integrating with n8n workflows, vector search, and platform operations.

## Base URL

**Development**: `http://localhost:8000`  
**Production**: `https://your-domain.com/api`

## Authentication

Most endpoints require an API key:

```bash
# Set in environment
N8N_API_KEY=your-api-key

# Or pass in header
X-N8N-API-KEY: your-api-key
```

## Endpoints

### Health Check

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "api-bridge"
}
```

### List Workflows

```http
GET /api/v1/workflows
Headers: X-N8N-API-KEY: your-key
```

**Response:**
```json
{
  "data": [
    {
      "id": "workflow-123",
      "name": "My Workflow",
      "active": true,
      "nodes": 5
    }
  ]
}
```

### Trigger Workflow

```http
POST /api/v1/workflows/{workflow_id}/trigger
Headers: X-N8N-API-KEY: your-key
Content-Type: application/json

{
  "data": {
    "key": "value"
  },
  "headers": {
    "Custom-Header": "value"
  }
}
```

**Response:**
```json
{
  "execution_id": "exec-123",
  "status": "triggered",
  "workflow_id": "workflow-123",
  "started_at": "2025-01-11T12:00:00Z"
}
```

### Vector Search

```http
POST /api/v1/vector/search
Content-Type: application/json

{
  "query_vector": [0.1, 0.2, 0.3, ...],
  "limit": 10,
  "threshold": 0.7
}
```

**Response:**
```json
{
  "results": [
    {
      "id": 1,
      "content": "Sample text",
      "similarity": 0.95,
      "metadata": {"source": "n8n"}
    }
  ],
  "count": 1
}
```

### Insert Vector

```http
POST /api/v1/vector/insert
Content-Type: application/json

{
  "content": "Sample text",
  "embedding": [0.1, 0.2, 0.3, ...],
  "metadata": {"source": "n8n"}
}
```

**Response:**
```json
{
  "id": 1,
  "status": "inserted"
}
```

## Integration Examples

### Python

```python
import requests

# List workflows
response = requests.get(
    "http://localhost:8000/api/v1/workflows",
    headers={"X-N8N-API-KEY": "your-key"}
)
workflows = response.json()

# Trigger workflow
response = requests.post(
    "http://localhost:8000/api/v1/workflows/workflow-123/trigger",
    headers={"X-N8N-API-KEY": "your-key"},
    json={"data": {"key": "value"}}
)
execution = response.json()

# Vector search
response = requests.post(
    "http://localhost:8000/api/v1/vector/search",
    json={
        "query_vector": [0.1, 0.2, 0.3],
        "limit": 10
    }
)
results = response.json()
```

### JavaScript/Node.js

```javascript
const axios = require('axios');

// List workflows
const workflows = await axios.get('http://localhost:8000/api/v1/workflows', {
  headers: { 'X-N8N-API-KEY': 'your-key' }
});

// Trigger workflow
const execution = await axios.post(
  'http://localhost:8000/api/v1/workflows/workflow-123/trigger',
  { data: { key: 'value' } },
  { headers: { 'X-N8N-API-KEY': 'your-key' } }
);
```

### cURL

```bash
# List workflows
curl -X GET http://localhost:8000/api/v1/workflows \
  -H "X-N8N-API-KEY: your-key"

# Trigger workflow
curl -X POST http://localhost:8000/api/v1/workflows/workflow-123/trigger \
  -H "X-N8N-API-KEY: your-key" \
  -H "Content-Type: application/json" \
  -d '{"data": {"key": "value"}}'

# Vector search
curl -X POST http://localhost:8000/api/v1/vector/search \
  -H "Content-Type: application/json" \
  -d '{
    "query_vector": [0.1, 0.2, 0.3],
    "limit": 10
  }'
```

## Error Handling

All endpoints return standard HTTP status codes:

- `200 OK`: Success
- `400 Bad Request`: Invalid request
- `401 Unauthorized`: Missing or invalid API key
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

**Error Response Format:**
```json
{
  "detail": "Error message description"
}
```

## Rate Limiting

Rate limiting is recommended for production:
- Default: 100 requests/minute per IP
- Configurable via environment variables

## Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [REST API Best Practices](https://restfulapi.net/)

