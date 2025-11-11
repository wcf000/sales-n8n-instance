# pgvector Integration Guide

## Overview

pgvector is a PostgreSQL extension that enables vector similarity search directly in PostgreSQL. This integration allows you to store and query vector embeddings alongside your n8n workflow data.

## Features

- **Vector Storage**: Store embeddings directly in PostgreSQL
- **Similarity Search**: Fast cosine similarity search using HNSW or IVFFlat indexes
- **Integration**: Works seamlessly with n8n workflows
- **Performance**: Optimized for high-dimensional vectors (up to 16,000 dimensions)

## Setup

### 1. Enable pgvector

The pgvector extension is automatically enabled when PostgreSQL starts. To manually enable:

```bash
./scripts/init-pgvector.sh
```

Or connect to PostgreSQL and run:

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

### 2. Verify Installation

```bash
docker compose exec postgres psql -U n8n -d n8n -c "\dx vector"
```

## Usage

### Creating Vector Tables

```sql
-- Create table with vector column
CREATE TABLE embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536),  -- OpenAI ada-002 dimension
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for fast similarity search
CREATE INDEX embeddings_vector_idx ON embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

### Inserting Vectors

```python
# Python example (in n8n Execute Command node)
import psycopg2
import json

conn = psycopg2.connect(
    host="postgres",
    database="n8n",
    user="n8n",
    password="your-password"
)

cursor = conn.cursor()

# Insert vector
embedding = [0.1, 0.2, 0.3, ...]  # Your vector
cursor.execute(
    "INSERT INTO embeddings (content, embedding, metadata) VALUES (%s, %s, %s)",
    ("Sample text", str(embedding), json.dumps({"source": "n8n"}))
)

conn.commit()
```

### Vector Similarity Search

```sql
-- Cosine similarity search
SELECT 
    id,
    content,
    1 - (embedding <=> '[0.1,0.2,0.3,...]'::vector) as similarity
FROM embeddings
WHERE 1 - (embedding <=> '[0.1,0.2,0.3,...]'::vector) > 0.7
ORDER BY embedding <=> '[0.1,0.2,0.3,...]'::vector
LIMIT 10;
```

### Using via REST API

```bash
# Search vectors
curl -X POST http://localhost:8000/api/v1/vector/search \
  -H "Content-Type: application/json" \
  -d '{
    "query_vector": [0.1, 0.2, 0.3, ...],
    "limit": 10,
    "threshold": 0.7
  }'

# Insert vector
curl -X POST http://localhost:8000/api/v1/vector/insert \
  -H "Content-Type: application/json" \
  -d '{
    "content": "Sample text",
    "embedding": [0.1, 0.2, 0.3, ...],
    "metadata": {"source": "n8n"}
  }'
```

## Index Types

### IVFFlat (Recommended for large datasets)

```sql
CREATE INDEX ON embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);
```

- **Lists**: Number of clusters (typically rows / 1000)
- **Best for**: Large datasets (> 100K vectors)
- **Trade-off**: Faster queries, slower index building

### HNSW (Recommended for high recall)

```sql
CREATE INDEX ON embeddings 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);
```

- **m**: Number of connections per layer
- **ef_construction**: Size of candidate list during construction
- **Best for**: High recall requirements
- **Trade-off**: Slower index building, faster queries

## Integration with n8n

### Workflow Example: Store Embeddings

1. **Generate Embedding** (using OpenAI/OpenRouter node)
2. **Execute Command** node:
   ```python
   import psycopg2
   import json
   import sys
   
   data = json.load(sys.stdin)
   embedding = data['embedding']
   content = data['content']
   
   conn = psycopg2.connect(
       host="postgres",
       database="n8n",
       user="n8n",
       password="{{ $env.POSTGRES_PASSWORD }}"
   )
   
   cursor = conn.cursor()
   cursor.execute(
       "INSERT INTO embeddings (content, embedding) VALUES (%s, %s::vector)",
       (content, str(embedding))
   )
   conn.commit()
   ```

### Workflow Example: Vector Search

1. **Generate Query Embedding**
2. **HTTP Request** node → `POST http://api-bridge:8000/api/v1/vector/search`
3. **Process Results**

## Performance Tips

1. **Index Selection**: Use IVFFlat for large datasets, HNSW for high recall
2. **Dimension Matching**: Ensure vector dimensions match your embedding model
3. **Batch Inserts**: Insert multiple vectors in a single transaction
4. **Connection Pooling**: Use connection pooling for high-throughput applications

## Resources

- [pgvector Documentation](https://github.com/pgvector/pgvector)
- [Vector Similarity Search](https://www.postgresql.org/docs/current/pgvector.html)
- [OpenAI Embeddings](https://platform.openai.com/docs/guides/embeddings)

