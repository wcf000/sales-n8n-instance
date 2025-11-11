#!/usr/bin/env python3
"""
GraphQL Query Hash Generator
Generates SHA256 hash for GraphQL persisted queries
"""

import hashlib
import json
import sys
from pathlib import Path

def generate_query_hash(query: str) -> str:
    """Generate SHA256 hash for a GraphQL query"""
    return hashlib.sha256(query.encode('utf-8')).hexdigest()

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 generate-query-hash.py <query-file.graphql>")
        sys.exit(1)
    
    query_file = Path(sys.argv[1])
    
    if not query_file.exists():
        print(f"Error: Query file not found: {query_file}")
        sys.exit(1)
    
    # Read query
    query = query_file.read_text()
    
    # Generate hash
    query_hash = generate_query_hash(query)
    
    # Output result
    print(f"Query: {query_file.name}")
    print(f"Hash: {query_hash}")
    print(f"\nUse in GraphQL request:")
    print(json.dumps({
        "extensions": {
            "persistedQuery": {
                "version": 1,
                "sha256Hash": query_hash
            }
        }
    }, indent=2))
    
    # Save hash mapping (optional)
    hash_file = query_file.parent / f"{query_file.stem}.hash"
    hash_file.write_text(query_hash)
    print(f"\nHash saved to: {hash_file}")

if __name__ == "__main__":
    main()

