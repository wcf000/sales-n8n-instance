# GraphQL Integration Guide

## Overview

The API Bridge provides a GraphQL interface for querying n8n workflows, executions, and vector data. This enables flexible, efficient data access with a single endpoint.

## Access

**GraphQL Endpoint**: `http://localhost:8000/graphql`  
**GraphQL Playground**: `http://localhost:8000/graphql` (interactive query interface)

## Schema

### Types

#### Workflow
```graphql
type Workflow {
  id: String!
  name: String!
  active: Boolean!
  nodes: Int!
  created_at: String
  updated_at: String
}
```

#### Execution
```graphql
type Execution {
  id: String!
  workflow_id: String!
  status: String!
  started_at: String!
  finished_at: String
}
```

#### VectorResult
```graphql
type VectorResult {
  id: Int!
  content: String!
  similarity: Float!
  metadata: String
}
```

## Queries

### List All Workflows

```graphql
query {
  workflows {
    id
    name
    active
    nodes
    created_at
    updated_at
  }
}
```

### Vector Search

```graphql
query {
  vectorSearch(
    queryVector: [0.1, 0.2, 0.3, ...]
    limit: 10
    threshold: 0.7
  ) {
    id
    content
    similarity
    metadata
  }
}
```

## Mutations

### Trigger Workflow

```graphql
mutation {
  triggerWorkflow(
    workflowId: "workflow-123"
    data: "{\"key\": \"value\"}"
  ) {
    id
    workflow_id
    status
    started_at
  }
}
```

## Persisted Queries

### Concept

Persisted queries allow you to store GraphQL queries on the server and reference them by hash. This reduces payload size and improves security.

### Generate Query Hash

```bash
# Use the query hash generator script
python3 scripts/generate-query-hash.py queries/my-query.graphql
```

### Example Query File

```graphql
# queries/workflow-list.graphql
query WorkflowList {
  workflows {
    id
    name
    active
  }
}
```

### Using Persisted Queries

```bash
# Send query hash instead of full query
curl -X POST http://localhost:8000/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "abc123..."
      }
    }
  }'
```

## Integration with n8n

### HTTP Request Node

1. Add **HTTP Request** node
2. Method: `POST`
3. URL: `http://api-bridge:8000/graphql`
4. Headers: `Content-Type: application/json`
5. Body:
   ```json
   {
     "query": "query { workflows { id name active } }"
   }
   ```

### Example Workflow

**Query Workflows via GraphQL:**
1. HTTP Request node → GraphQL endpoint
2. Process response
3. Use workflow data in subsequent nodes

## Best Practices

1. **Use Variables**: Parameterize queries for reusability
2. **Selective Fields**: Only request needed fields
3. **Error Handling**: Handle GraphQL errors appropriately
4. **Caching**: Cache query results when possible
5. **Persisted Queries**: Use for production to reduce payload size

## Security

- **API Key**: Set `N8N_API_KEY` environment variable
- **Authentication**: Add authentication middleware for production
- **Rate Limiting**: Implement rate limiting for public endpoints
- **Query Complexity**: Limit query depth and complexity

## Resources

- [GraphQL Documentation](https://graphql.org/learn/)
- [Strawberry GraphQL](https://strawberry.rocks/)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

