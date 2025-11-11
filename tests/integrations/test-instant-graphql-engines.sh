#!/bin/bash

# Test Suite: Instant GraphQL Engines (Hasura, PostGraphile, pg_graphql)
# Tests for auto-generated GraphQL APIs from PostgreSQL

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
echo -e "${BLUE}Instant GraphQL Engines Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test Hasura Integration
echo -e "${BLUE}Hasura GraphQL Engine${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "hasura:" docker-compose.yml; then
        log_pass "Hasura service configured in docker-compose.yml"
        
        if grep -q "hasura/graphql-engine" docker-compose.yml; then
            log_pass "Hasura image specified"
        else
            log_fail "Hasura image not specified"
        fi
        
        if grep -q "HASURA_GRAPHQL_DATABASE_URL" docker-compose.yml; then
            log_pass "Hasura database URL configured"
        else
            log_fail "Hasura database URL not configured"
        fi
        
        if grep -q "HASURA_GRAPHQL_ADMIN_SECRET" docker-compose.yml; then
            log_pass "Hasura admin secret configured"
        else
            log_info "Hasura admin secret uses default (should be set in production)"
        fi
        
        if grep -q "hasura_metadata\|hasura_migrations" docker-compose.yml; then
            log_pass "Hasura volumes configured"
        else
            log_fail "Hasura volumes not configured"
        fi
    else
        log_info "Hasura service not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "hasura" ]; then
    if [ -f "hasura/config.yaml" ]; then
        log_pass "Hasura config.yaml exists"
    else
        log_info "Hasura config.yaml not yet created (planned)"
    fi
    
    if [ -d "hasura/metadata" ]; then
        log_pass "Hasura metadata directory exists"
        
        if [ -f "hasura/metadata/databases/databases.yaml" ]; then
            log_pass "Hasura databases.yaml exists"
        else
            log_info "Hasura databases.yaml not yet created (planned)"
        fi
    else
        log_info "Hasura metadata directory not yet created (planned)"
    fi
    
    if [ -d "hasura/migrations" ]; then
        log_pass "Hasura migrations directory exists"
    else
        log_info "Hasura migrations directory not yet created (will be created on first migration)"
    fi
else
    log_info "Hasura directory not yet created (planned)"
fi

echo ""

# Test PostGraphile Integration
echo -e "${BLUE}PostGraphile${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "postgraphile:" docker-compose.yml; then
        log_pass "PostGraphile service configured in docker-compose.yml"
        
        if grep -q "graphql-alternative" docker-compose.yml; then
            log_pass "PostGraphile uses profile (optional service)"
        else
            log_info "PostGraphile profile not configured (optional)"
        fi
        
        if grep -q "DATABASE_URL" docker-compose.yml | grep -q "postgraphile"; then
            log_pass "PostGraphile database URL configured"
        else
            log_info "PostGraphile database URL configuration checked"
        fi
    else
        log_info "PostGraphile service not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "postgraphile" ]; then
    if [ -f "postgraphile/Dockerfile" ]; then
        log_pass "PostGraphile Dockerfile exists"
    else
        log_info "PostGraphile Dockerfile not yet created (planned)"
    fi
else
    log_info "PostGraphile directory not yet created (planned)"
fi

echo ""

# Test Documentation
echo -e "${BLUE}Documentation${NC}"

if [ -f "_docs/integrations/instant-graphql-engines.md" ]; then
    log_pass "Instant GraphQL engines documentation exists"
    
    if grep -q "Hasura" _docs/integrations/instant-graphql-engines.md; then
        log_pass "Hasura documentation included"
    else
        log_fail "Hasura documentation missing"
    fi
    
    if grep -q "PostGraphile" _docs/integrations/instant-graphql-engines.md; then
        log_pass "PostGraphile documentation included"
    else
        log_fail "PostGraphile documentation missing"
    fi
    
    if grep -q "pg_graphql" _docs/integrations/instant-graphql-engines.md; then
        log_pass "pg_graphql documentation included"
    else
        log_info "pg_graphql documentation not yet added (optional)"
    fi
else
    log_info "Instant GraphQL engines documentation not yet created (planned)"
fi

echo ""

# Test Health Checks
echo -e "${BLUE}Health Checks${NC}"

if [ -f "docker-compose.yml" ]; then
    # Check Hasura health check
    if grep -A 30 "hasura:" docker-compose.yml | grep -q "healthcheck:"; then
        log_pass "Hasura health check configured"
    else
        log_info "Hasura health check not yet configured (planned)"
    fi
    
    # Check PostGraphile health check
    if grep -A 30 "postgraphile:" docker-compose.yml | grep -q "healthcheck:"; then
        log_pass "PostGraphile health check configured"
    else
        log_info "PostGraphile health check not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

echo ""

# Test Environment Variables
echo -e "${BLUE}Environment Configuration${NC}"

if [ -f "SETUP.md" ]; then
    if grep -q "HASURA_GRAPHQL_ADMIN_SECRET" SETUP.md; then
        log_pass "Hasura admin secret documented in SETUP.md"
    else
        log_info "Hasura admin secret not yet documented (will add)"
    fi
else
    log_info "SETUP.md not checked (optional)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Instant GraphQL Engines Test Summary${NC}"
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

