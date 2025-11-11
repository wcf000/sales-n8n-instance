#!/usr/bin/env python3
"""
Example: Using gRPC with Qdrant Vector Database
Qdrant supports both REST and gRPC APIs
"""

import grpc
import sys
import json

# Qdrant gRPC configuration
QDRANT_HOST = "qdrant"  # Service name in docker-compose
QDRANT_GRPC_PORT = 6334  # Qdrant gRPC port

def query_qdrant_grpc(collection_name, query_vector, limit=10):
    """
    Query Qdrant using gRPC
    
    Note: This requires Qdrant gRPC stubs generated from Qdrant's .proto files
    For now, this is a template showing the structure
    """
    channel = grpc.insecure_channel(f'{QDRANT_HOST}:{QDRANT_GRPC_PORT}')
    
    try:
        # In a real implementation:
        # from qdrant_grpc import qdrant_pb2, qdrant_pb2_grpc
        # stub = qdrant_pb2_grpc.QdrantStub(channel)
        # 
        # request = qdrant_pb2.SearchPoints(
        #     collection_name=collection_name,
        #     vector=query_vector,
        #     limit=limit
        # )
        # response = stub.Search(request)
        
        # For demonstration:
        result = {
            "status": "success",
            "collection": collection_name,
            "results": [
                {"id": "1", "score": 0.95, "payload": {}},
                {"id": "2", "score": 0.87, "payload": {}}
            ],
            "message": "Qdrant gRPC query would be executed here"
        }
        
        return result
    finally:
        channel.close()


def main():
    """Main function for n8n integration"""
    try:
        input_data = json.load(sys.stdin)
        
        collection_name = input_data.get("collection", "default")
        query_vector = input_data.get("vector", [])
        limit = input_data.get("limit", 10)
        
        result = query_qdrant_grpc(collection_name, query_vector, limit)
        print(json.dumps(result))
        
    except Exception as e:
        error_result = {
            "status": "error",
            "error": str(e)
        }
        print(json.dumps(error_result))
        sys.exit(1)


if __name__ == "__main__":
    main()

