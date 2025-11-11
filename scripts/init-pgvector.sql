-- Initialize pgvector extension
-- This script runs automatically when PostgreSQL container starts for the first time

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Create a sample table for vector storage (optional - for testing)
CREATE TABLE IF NOT EXISTS embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536),  -- OpenAI ada-002 dimension
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for vector similarity search
CREATE INDEX IF NOT EXISTS embeddings_vector_idx ON embeddings 
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Grant permissions to n8n user
GRANT ALL PRIVILEGES ON TABLE embeddings TO CURRENT_USER;
GRANT USAGE, SELECT ON SEQUENCE embeddings_id_seq TO CURRENT_USER;

