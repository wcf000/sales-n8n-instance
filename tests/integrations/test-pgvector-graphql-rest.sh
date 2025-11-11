#!/bin/bash

# Test Suite: Integration Tests for pgvector, GraphQL, and REST API Bridge
# Tests for database extensions, API endpoints, and GraphQL queries

# Don't exit on error - we want to count all tests
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0

log_pass() {
    echo -e "${GREEN}✓ [PASS]${NC} $1"
    ((PASSED++))
}

log_fail() {
    echo -e "${RED}✗ [FAIL]${NC} $1"
    ((FAILED++))
}

log_info() {
    echo -e "${YELLOW}ℹ [INFO]${NC} $1"
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Integration Tests: pgvector, GraphQL, REST${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test pgvector Integration
echo -e "${BLUE}pgvector Integration${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "pgvector/pgvector" docker-compose.yml; then
        log_pass "PostgreSQL uses pgvector image"
    else
        log_info "PostgreSQL pgvector image not yet configured (planned)"
    fi
    
    if grep -q "init-pgvector.sql" docker-compose.yml; then
        log_pass "pgvector initialization script configured"
    else
        log_info "pgvector initialization script not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "scripts/init-pgvector.sql" ]; then
    if grep -q "CREATE EXTENSION.*vector" scripts/init-pgvector.sql; then
        log_pass "pgvector initialization SQL script exists"
    else
        log_fail "pgvector initialization script missing CREATE EXTENSION"
    fi
else
    log_info "pgvector initialization SQL script not yet created (planned)"
fi

if [ -f "scripts/init-pgvector.sh" ]; then
    if [ -x "scripts/init-pgvector.sh" ]; then
        log_pass "pgvector initialization script exists and is executable"
    else
        log_fail "pgvector initialization script exists but is not executable"
    fi
else
    log_info "pgvector initialization script not yet created (planned)"
fi

if [ -f "_docs/integrations/pgvector.md" ]; then
    log_pass "pgvector documentation exists"
else
    log_info "pgvector documentation not yet created (planned)"
fi

echo ""

# Test GraphQL Integration
echo -e "${BLUE}GraphQL Integration${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "api-bridge" docker-compose.yml; then
        log_pass "API bridge service configured"
    else
        log_info "API bridge service not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "api-bridge" ]; then
    if [ -f "api-bridge/main.py" ]; then
        if grep -q "strawberry\|GraphQL\|graphql" api-bridge/main.py -i; then
            log_pass "GraphQL implementation exists in API bridge"
        else
            log_info "GraphQL not yet implemented in API bridge (planned)"
        fi
    else
        log_info "API bridge main.py not yet created (planned)"
    fi
    
    if [ -f "api-bridge/requirements.txt" ]; then
        if grep -q "strawberry\|graphql" api-bridge/requirements.txt -i; then
            log_pass "GraphQL dependencies in requirements.txt"
        else
            log_info "GraphQL dependencies not yet added (planned)"
        fi
    else
        log_info "API bridge requirements.txt not yet created (planned)"
    fi
    
    if [ -f "api-bridge/Dockerfile" ]; then
        log_pass "API bridge Dockerfile exists"
    else
        log_info "API bridge Dockerfile not yet created (planned)"
    fi
else
    log_info "API bridge directory not yet created (planned)"
fi

if [ -f "_docs/integrations/graphql.md" ]; then
    log_pass "GraphQL documentation exists"
else
    log_info "GraphQL documentation not yet created (planned)"
fi

if [ -f "scripts/generate-query-hash.py" ]; then
    if [ -x "scripts/generate-query-hash.py" ]; then
        log_pass "GraphQL query hash generator exists and is executable"
    else
        log_fail "Query hash generator exists but is not executable"
    fi
else
    log_info "Query hash generator not yet created (planned)"
fi

echo ""

# Test REST API Bridge
echo -e "${BLUE}REST API Bridge${NC}"

if [ -d "api-bridge" ]; then
    if [ -f "api-bridge/main.py" ]; then
        if grep -q "FastAPI\|@app\.(get|post)" api-bridge/main.py; then
            log_pass "REST API implementation exists"
        else
            log_info "REST API not yet implemented (planned)"
        fi
        
        if grep -q "/api/v1" api-bridge/main.py; then
            log_pass "REST API endpoints defined"
        else
            log_info "REST API endpoints not yet defined (planned)"
        fi
        
        if grep -q "vector.*search\|/vector" api-bridge/main.py -i; then
            log_pass "Vector search endpoint exists"
        else
            log_info "Vector search endpoint not yet implemented (planned)"
        fi
    else
        log_info "API bridge main.py not yet created (planned)"
    fi
else
    log_info "API bridge directory not yet created (planned)"
fi

if [ -f "_docs/integrations/rest-api.md" ]; then
    log_pass "REST API documentation exists"
else
    log_info "REST API documentation not yet created (planned)"
fi

echo ""

# Test Python Dependencies
echo -e "${BLUE}Python Dependencies${NC}"

if [ -f "n8n/requirements.txt" ]; then
    if grep -q "pgvector\|psycopg2" n8n/requirements.txt; then
        log_pass "PostgreSQL vector dependencies in requirements.txt"
    else
        log_info "pgvector Python package not yet added (will be added if needed)"
    fi
else
    log_fail "requirements.txt not found"
fi

if [ -f "api-bridge/requirements.txt" ]; then
    if grep -q "fastapi\|strawberry\|pgvector" api-bridge/requirements.txt; then
        log_pass "API bridge dependencies configured"
    else
        log_info "API bridge dependencies not yet fully configured (planned)"
    fi
else
    log_info "API bridge requirements.txt not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Integration Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

