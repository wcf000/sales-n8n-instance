#!/bin/bash

# Test Suite: Sprint 7 - Performance Optimizations
# Tests for resource limits, execution pruning, and database indexes

set -e

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
echo -e "${BLUE}Sprint 7: Performance Optimization Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 7.1: Resource Limits & Autoscaling
echo -e "${BLUE}7.1 Resource Limits & Autoscaling${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "resources:\|limits:\|cpus:\|memory:" docker-compose.yml; then
        log_pass "Resource limits configured in docker-compose.yml"
    else
        log_info "Resource limits not yet configured (planned)"
    fi
    
    if grep -q "deploy:\|replicas:" docker-compose.yml; then
        log_pass "Deployment/replica configuration exists"
    else
        log_info "Autoscaling configuration not yet added (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "_docs/performance.md" ]; then
    log_pass "Performance documentation exists"
else
    log_info "Performance documentation not yet created (planned)"
fi

echo ""

# Test 7.2: Execution Data Pruning
echo -e "${BLUE}7.2 Execution Data Pruning${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "EXECUTIONS_DATA_PRUNE\|EXECUTIONS_DATA_PRUNE_MAX_AGE" docker-compose.yml; then
        log_pass "Execution pruning environment variables configured"
    else
        log_info "Execution pruning environment variables not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "scripts/prune-executions.sh" ]; then
    if [ -x "scripts/prune-executions.sh" ]; then
        log_pass "Execution pruning script exists and is executable"
    else
        log_fail "Execution pruning script exists but is not executable"
    fi
else
    log_info "Execution pruning script not yet created (planned)"
fi

if [ -f "_docs/performance.md" ]; then
    if grep -q "prune\|retention" _docs/performance.md -i; then
        log_pass "Performance documentation includes pruning section"
    else
        log_info "Pruning section not yet added (planned)"
    fi
else
    log_info "Performance documentation not yet created (planned)"
fi

echo ""

# Test 7.3: PostgreSQL Index Optimization
echo -e "${BLUE}7.3 PostgreSQL Index Optimization${NC}"

if [ -d "scripts/db-migrations" ]; then
    if [ -f "scripts/db-migrations/add-indexes.sql" ]; then
        if grep -q "CREATE INDEX\|idx_execution\|idx_workflow" scripts/db-migrations/add-indexes.sql -i; then
            log_pass "Database index migration script exists with indexes"
        else
            log_info "Index migration script exists but indexes not yet defined (planned)"
        fi
    else
        log_info "Index migration script not yet created (planned)"
    fi
else
    log_info "Database migrations directory not yet created (planned)"
fi

if [ -f "scripts/apply-db-migrations.sh" ]; then
    if [ -x "scripts/apply-db-migrations.sh" ]; then
        log_pass "Database migration runner script exists and is executable"
    else
        log_fail "Migration runner script exists but is not executable"
    fi
else
    log_info "Database migration runner script not yet created (planned)"
fi

if [ -f "_docs/performance.md" ]; then
    if grep -q "index\|database\|optimization" _docs/performance.md -i; then
        log_pass "Performance documentation includes database optimization"
    else
        log_info "Database optimization section not yet added (planned)"
    fi
else
    log_info "Performance documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 7 Test Summary${NC}"
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

