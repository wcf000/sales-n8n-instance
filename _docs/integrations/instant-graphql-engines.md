# Instant GraphQL Engines Guide

## Overview

This platform supports multiple instant GraphQL engines that automatically generate GraphQL APIs from your PostgreSQL database schema. These tools require minimal to no coding for standard CRUD operations.

## Available Engines

### 1. Hasura GraphQL Engine (Primary)

**Status**: ✅ Active  
**Port**: 8080  
**Console**: http://localhost:8080/console

Hasura is a high-performance, open-source service that provides an instant, real-time GraphQL API over PostgreSQL.

#### Features

- **Auto-generated API**: Automatically creates GraphQL API from PostgreSQL schema
- **Admin UI**: Web-based console for managing database and API schema
- **Real-time Subscriptions**: Built-in support for GraphQL subscriptions
- **Authentication/Authorization**: Row-Level Security (RLS), roles, and grants
- **Custom Business Logic**: Remote schemas and serverless functions
- **Migrations**: Version-controlled database migrations
- **Actions**: Custom GraphQL actions for complex operations

#### Quick Start

1. **Start Hasura**:
   ```bash
   docker compose up -d hasura
   ```

2. **Access Console**:
   - Open http://localhost:8080/console
   - Admin Secret: Set via `HASURA_GRAPHQL_ADMIN_SECRET` in `.env`

3. **Track Tables**:
   - Go to Data → Add Table
   - Select tables to track
   - Hasura automatically generates GraphQL schema

4. **Query Example**:
   ```graphql
   query {
     workflows {
       id
       name
       active
       nodes
     }
   }
   ```

#### Configuration

**Environment Variables**:
```bash
HASURA_GRAPHQL_ADMIN_SECRET=your-secret-here
HASURA_GRAPHQL_DATABASE_URL=postgres://user:pass@postgres:5432/n8n
```

**Metadata Management**:
- Metadata stored in `hasura/metadata/`
- Migrations in `hasura/migrations/`
- Use Hasura CLI for version control

#### Hasura CLI

```bash
# Install Hasura CLI
npm install -g hasura-cli

# Initialize project (already done)
hasura init

# Apply metadata
hasura metadata apply

# Generate migrations
hasura migrate create "add_workflows_table" --from-server

# Apply migrations
hasura migrate apply
```

#### Advanced Features

**Row-Level Security (RLS)**:
```sql
-- Enable RLS on table
ALTER TABLE workflows ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view own workflows"
  ON workflows FOR SELECT
  USING (user_id = current_user_id());
```

**Custom Actions**:
```yaml
# hasura/metadata/actions.yaml
actions:
  - name: triggerWorkflow
    definition:
      kind: synchronous
      handler: http://api-bridge:8000/actions/trigger-workflow
      forward_client_headers: true
```

**Remote Schemas**:
- Connect external GraphQL APIs
- Merge multiple GraphQL schemas
- Use in `hasura/metadata/remote_schemas.yaml`

#### API Endpoints

- **GraphQL**: http://localhost:8080/v1/graphql
- **GraphiQL**: http://localhost:8080/console/api-explorer
- **Health**: http://localhost:8080/healthz
- **Metadata**: http://localhost:8080/v1/metadata

---

### 2. PostGraphile (Alternative)

**Status**: ✅ Available (via profile)  
**Port**: 5000  
**GraphiQL**: http://localhost:5000/graphiql

PostGraphile is an open-source tool that instantly spins up a GraphQL API server by analyzing your PostgreSQL schema.

#### Features

- **Zero Configuration**: Works out of the box with PostgreSQL
- **Postgres-First**: Leverages native Postgres features (RLS, functions, etc.)
- **Automatic Schema**: Reflects database schema automatically
- **Real-time**: Built-in subscriptions support
- **Performance**: Optimized query generation

#### Quick Start

1. **Start PostGraphile**:
   ```bash
   docker compose --profile graphql-alternative up -d postgraphile
   ```

2. **Access GraphiQL**:
   - Open http://localhost:5000/graphiql
   - Start querying immediately

3. **Query Example**:
   ```graphql
   query {
     allWorkflows {
       nodes {
         id
         name
         active
       }
     }
   }
   ```

#### Configuration

**Environment Variables**:
```bash
DATABASE_URL=postgres://user:pass@postgres:5432/n8n
POSTGRAPHILE_SCHEMA=public
POSTGRAPHILE_WATCH=true
```

**Features Enabled**:
- `--watch`: Auto-reload on schema changes
- `--enhance-graphql`: Enhanced GraphQL features
- `--subscriptions`: Real-time subscriptions
- `--dynamic-json`: Dynamic JSON support

#### PostGraphile Schema Conventions

PostGraphile follows naming conventions:
- Tables → Types (e.g., `workflows` → `Workflow`)
- Columns → Fields
- Foreign keys → Relations
- Functions → Queries/Mutations

**Example**:
```sql
-- Table
CREATE TABLE workflows (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

-- Automatically available as:
-- type Workflow { id: Int!, name: String! }
-- query { allWorkflows { nodes { id name } } }
```

---

### 3. pg_graphql Extension (Documentation Only)

**Status**: 📚 Documented (requires PostgreSQL extension)

pg_graphql is a PostgreSQL extension that enables a GraphQL API directly within the database server.

#### Features

- **Database-Native**: No additional server layer
- **Direct Access**: Any language can use via PostgreSQL connection
- **Used by Supabase**: Production-tested solution

#### Installation

```sql
-- Install extension (requires PostgreSQL 14+)
CREATE EXTENSION pg_graphql;

-- Query via SQL
SELECT graphql.resolve($$
  {
    workflows {
      id
      name
    }
  }
$$);
```

#### Usage

```python
# Python example
import psycopg2

conn = psycopg2.connect("postgresql://user:pass@postgres:5432/n8n")
cursor = conn.cursor()

cursor.execute("""
  SELECT graphql.resolve($$
    {
      workflows {
        id
        name
      }
    }
  $$);
""")

result = cursor.fetchone()
```

**Note**: This extension is not currently installed in the default PostgreSQL setup. To use it, you would need to:
1. Use a PostgreSQL image that supports extensions
2. Install the extension manually
3. Configure access controls

---

## Comparison

| Feature | Hasura | PostGraphile | pg_graphql |
|---------|--------|--------------|------------|
| **Setup Complexity** | Medium | Low | High |
| **Admin UI** | ✅ Yes | ❌ No | ❌ No |
| **Real-time** | ✅ Yes | ✅ Yes | ❌ No |
| **Custom Logic** | ✅ Actions | ✅ Functions | ✅ Functions |
| **Migrations** | ✅ Built-in | ⚠️ Manual | ❌ No |
| **RLS Support** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Production Ready** | ✅ Yes | ✅ Yes | ✅ Yes |

## Integration with n8n

### Using Hasura in n8n

1. **HTTP Request Node**:
   - Method: `POST`
   - URL: `http://hasura:8080/v1/graphql`
   - Headers: `X-Hasura-Admin-Secret: your-secret`
   - Body: GraphQL query

2. **Example Workflow**:
   ```
   Webhook → HTTP Request (Hasura) → Process Data → Next Node
   ```

### Using PostGraphile in n8n

1. **HTTP Request Node**:
   - Method: `POST`
   - URL: `http://postgraphile:5000/graphql`
   - Body: GraphQL query

2. **Example Workflow**:
   ```
   Webhook → HTTP Request (PostGraphile) → Process Data → Next Node
   ```

## Best Practices

1. **Choose Based on Needs**:
   - **Hasura**: If you need admin UI and migrations
   - **PostGraphile**: If you prefer Postgres-native approach
   - **pg_graphql**: If you want database-native solution

2. **Security**:
   - Always use RLS for row-level security
   - Set strong admin secrets
   - Use environment variables for credentials
   - Enable authentication/authorization

3. **Performance**:
   - Use indexes on frequently queried columns
   - Enable query caching where appropriate
   - Monitor query performance
   - Use connection pooling

4. **Development**:
   - Use migrations for schema changes
   - Version control metadata
   - Test queries in GraphiQL/console
   - Document custom types and actions

## Resources

- [Hasura Documentation](https://hasura.io/docs/)
- [PostGraphile Documentation](https://www.graphile.org/postgraphile/)
- [pg_graphql Extension](https://github.com/supabase/pg_graphql)
- [GraphQL Best Practices](https://graphql.org/learn/best-practices/)

