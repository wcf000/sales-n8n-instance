"""
FastAPI REST Bridge and GraphQL API
Provides REST endpoints and GraphQL interface for n8n platform integration
"""

from fastapi import FastAPI, HTTPException, Depends, Header
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
import os
import httpx
from datetime import datetime
import json

# GraphQL imports
from strawberry.fastapi import GraphQLRouter
import strawberry

app = FastAPI(
    title="n8n API Bridge",
    description="REST and GraphQL API bridge for n8n platform",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
N8N_URL = os.getenv("N8N_URL", "http://n8n:5678")
N8N_API_KEY = os.getenv("N8N_API_KEY", "")
POSTGRES_URL = os.getenv("POSTGRES_URL", "postgresql://n8n:n8n@postgres:5432/n8n")

# ============================================================================
# REST API Endpoints
# ============================================================================

class WorkflowTriggerRequest(BaseModel):
    workflow_id: str
    data: Optional[Dict[str, Any]] = None
    headers: Optional[Dict[str, str]] = None

class WorkflowResponse(BaseModel):
    execution_id: str
    status: str
    workflow_id: str
    started_at: datetime

class VectorSearchRequest(BaseModel):
    query_vector: List[float] = Field(..., description="Vector embedding for search")
    limit: int = Field(10, ge=1, le=100)
    threshold: float = Field(0.7, ge=0.0, le=1.0)

class VectorSearchResult(BaseModel):
    id: int
    content: str
    similarity: float
    metadata: Optional[Dict[str, Any]] = None

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "api-bridge"}

@app.get("/api/v1/workflows")
async def list_workflows(
    x_n8n_api_key: Optional[str] = Header(None, alias="X-N8N-API-KEY")
):
    """List all n8n workflows"""
    api_key = x_n8n_api_key or N8N_API_KEY
    if not api_key:
        raise HTTPException(status_code=401, detail="API key required")
    
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get(
                f"{N8N_URL}/api/v1/workflows",
                headers={"X-N8N-API-KEY": api_key},
                timeout=10.0
            )
            response.raise_for_status()
            return response.json()
        except httpx.HTTPError as e:
            raise HTTPException(status_code=500, detail=f"Failed to fetch workflows: {str(e)}")

@app.post("/api/v1/workflows/{workflow_id}/trigger")
async def trigger_workflow(
    workflow_id: str,
    request: WorkflowTriggerRequest,
    x_n8n_api_key: Optional[str] = Header(None, alias="X-N8N-API-KEY")
):
    """Trigger an n8n workflow via webhook"""
    api_key = x_n8n_api_key or N8N_API_KEY
    
    # Get webhook URL for workflow
    async with httpx.AsyncClient() as client:
        try:
            # Get workflow details
            workflow_response = await client.get(
                f"{N8N_URL}/api/v1/workflows/{workflow_id}",
                headers={"X-N8N-API-KEY": api_key},
                timeout=10.0
            )
            workflow_response.raise_for_status()
            workflow = workflow_response.json()
            
            # Find webhook URL
            webhook_url = None
            for node in workflow.get("nodes", []):
                if node.get("type") == "n8n-nodes-base.webhook":
                    webhook_path = node.get("parameters", {}).get("path")
                    if webhook_path:
                        webhook_url = f"{N8N_URL}/webhook/{webhook_path}"
                        break
            
            if not webhook_url:
                raise HTTPException(status_code=400, detail="Workflow does not have a webhook trigger")
            
            # Trigger webhook
            webhook_response = await client.post(
                webhook_url,
                json=request.data or {},
                headers=request.headers or {},
                timeout=30.0
            )
            webhook_response.raise_for_status()
            
            return {
                "execution_id": webhook_response.headers.get("X-Execution-Id", "unknown"),
                "status": "triggered",
                "workflow_id": workflow_id,
                "started_at": datetime.now()
            }
        except httpx.HTTPError as e:
            raise HTTPException(status_code=500, detail=f"Failed to trigger workflow: {str(e)}")

@app.post("/api/v1/vector/search")
async def vector_search(request: VectorSearchRequest):
    """Search vectors using pgvector"""
    try:
        from sqlalchemy import create_engine, text
        from pgvector.sqlalchemy import Vector
        
        engine = create_engine(POSTGRES_URL)
        
        with engine.connect() as conn:
            # Convert list to PostgreSQL vector format
            vector_str = "[" + ",".join(map(str, request.query_vector)) + "]"
            
            query = text("""
                SELECT 
                    id,
                    content,
                    metadata,
                    1 - (embedding <=> :query_vector::vector) as similarity
                FROM embeddings
                WHERE 1 - (embedding <=> :query_vector::vector) >= :threshold
                ORDER BY embedding <=> :query_vector::vector
                LIMIT :limit
            """)
            
            result = conn.execute(
                query,
                {
                    "query_vector": vector_str,
                    "threshold": request.threshold,
                    "limit": request.limit
                }
            )
            
            results = []
            for row in result:
                results.append({
                    "id": row.id,
                    "content": row.content,
                    "similarity": float(row.similarity),
                    "metadata": row.metadata
                })
            
            return {"results": results, "count": len(results)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Vector search failed: {str(e)}")

@app.post("/api/v1/vector/insert")
async def insert_vector(
    content: str,
    embedding: List[float],
    metadata: Optional[Dict[str, Any]] = None
):
    """Insert a vector embedding"""
    try:
        from sqlalchemy import create_engine, text
        
        engine = create_engine(POSTGRES_URL)
        vector_str = "[" + ",".join(map(str, embedding)) + "]"
        
        with engine.connect() as conn:
            query = text("""
                INSERT INTO embeddings (content, embedding, metadata)
                VALUES (:content, :embedding::vector, :metadata::jsonb)
                RETURNING id
            """)
            
            result = conn.execute(
                query,
                {
                    "content": content,
                    "embedding": vector_str,
                    "metadata": json.dumps(metadata or {})
                }
            )
            conn.commit()
            
            row = result.fetchone()
            return {"id": row.id, "status": "inserted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Vector insert failed: {str(e)}")

# ============================================================================
# GraphQL Schema
# ============================================================================

@strawberry.type
class Workflow:
    id: str
    name: str
    active: bool
    nodes: int
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

@strawberry.type
class Execution:
    id: str
    workflow_id: str
    status: str
    started_at: str
    finished_at: Optional[str] = None

@strawberry.type
class VectorResult:
    id: int
    content: str
    similarity: float
    metadata: Optional[str] = None

@strawberry.type
class Query:
    @strawberry.field
    async def workflows(self) -> List[Workflow]:
        """Get all workflows"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    f"{N8N_URL}/api/v1/workflows",
                    headers={"X-N8N-API-KEY": N8N_API_KEY},
                    timeout=10.0
                )
                response.raise_for_status()
                workflows_data = response.json()
                
                workflows = []
                for wf in workflows_data.get("data", []):
                    workflows.append(Workflow(
                        id=str(wf.get("id", "")),
                        name=wf.get("name", ""),
                        active=wf.get("active", False),
                        nodes=len(wf.get("nodes", [])),
                        created_at=wf.get("createdAt"),
                        updated_at=wf.get("updatedAt")
                    ))
                return workflows
            except Exception as e:
                return []

    @strawberry.field
    async def vector_search(
        self,
        query_vector: List[float],
        limit: int = 10,
        threshold: float = 0.7
    ) -> List[VectorResult]:
        """Search vectors"""
        try:
            from sqlalchemy import create_engine, text
            
            engine = create_engine(POSTGRES_URL)
            vector_str = "[" + ",".join(map(str, query_vector)) + "]"
            
            with engine.connect() as conn:
                query = text("""
                    SELECT 
                        id,
                        content,
                        metadata,
                        1 - (embedding <=> :query_vector::vector) as similarity
                    FROM embeddings
                    WHERE 1 - (embedding <=> :query_vector::vector) >= :threshold
                    ORDER BY embedding <=> :query_vector::vector
                    LIMIT :limit
                """)
                
                result = conn.execute(
                    query,
                    {
                        "query_vector": vector_str,
                        "threshold": threshold,
                        "limit": limit
                    }
                )
                
                results = []
                for row in result:
                    results.append(VectorResult(
                        id=row.id,
                        content=row.content,
                        similarity=float(row.similarity),
                        metadata=json.dumps(row.metadata) if row.metadata else None
                    ))
                
                return results
        except Exception as e:
            return []

@strawberry.type
class Mutation:
    @strawberry.field
    async def trigger_workflow(
        self,
        workflow_id: str,
        data: Optional[str] = None
    ) -> Execution:
        """Trigger a workflow"""
        async with httpx.AsyncClient() as client:
            try:
                # Get workflow webhook URL
                workflow_response = await client.get(
                    f"{N8N_URL}/api/v1/workflows/{workflow_id}",
                    headers={"X-N8N-API-KEY": N8N_API_KEY},
                    timeout=10.0
                )
                workflow = workflow_response.json()
                
                webhook_url = None
                for node in workflow.get("nodes", []):
                    if node.get("type") == "n8n-nodes-base.webhook":
                        webhook_path = node.get("parameters", {}).get("path")
                        if webhook_path:
                            webhook_url = f"{N8N_URL}/webhook/{webhook_path}"
                            break
                
                if not webhook_url:
                    raise Exception("Workflow does not have webhook trigger")
                
                payload = json.loads(data) if data else {}
                response = await client.post(webhook_url, json=payload, timeout=30.0)
                response.raise_for_status()
                
                return Execution(
                    id=response.headers.get("X-Execution-Id", "unknown"),
                    workflow_id=workflow_id,
                    status="triggered",
                    started_at=datetime.now().isoformat()
                )
            except Exception as e:
                raise Exception(f"Failed to trigger workflow: {str(e)}")

# Create GraphQL schema
schema = strawberry.Schema(query=Query, mutation=Mutation)

# Add GraphQL endpoint
graphql_app = GraphQLRouter(schema)
app.include_router(graphql_app, prefix="/graphql")

@app.get("/")
async def root():
    """API root endpoint"""
    return {
        "service": "n8n API Bridge",
        "version": "1.0.0",
        "endpoints": {
            "rest": "/api/v1",
            "graphql": "/graphql",
            "health": "/health",
            "docs": "/docs"
        }
    }

