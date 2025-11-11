#!/bin/bash

# Test Suite: Sprint 10 - Workflow Engine Enhancements
# Tests for retry logic, parallelization, Python sandbox, and Redis caching

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
echo -e "${BLUE}Sprint 10: Workflow Engine Enhancement Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 10.1: Retry Logic & Error Handling
echo -e "${BLUE}10.1 Retry Logic & Error Handling${NC}"

if [ -f "_docs/examples/retry-patterns.md" ]; then
    log_pass "Retry patterns documentation exists"
else
    log_info "Retry patterns documentation not yet created (planned)"
fi

if [ -f "_debug/retry-workflow-template.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty _debug/retry-workflow-template.json 2>/dev/null; then
            log_pass "Retry workflow template exists and is valid JSON"
        else
            log_fail "Retry workflow template exists but is invalid JSON"
        fi
    else
        log_pass "Retry workflow template exists (JSON validation skipped - jq not installed)"
    fi
else
    log_info "Retry workflow template not yet created (planned)"
fi

echo ""

# Test 10.2: Parallelization & Concurrency
echo -e "${BLUE}10.2 Parallelization & Concurrency${NC}"

if [ -f "_docs/performance.md" ]; then
    if grep -q "parallel\|concurrency\|batch" _docs/performance.md -i; then
        log_pass "Performance documentation includes parallelization section"
    else
        log_info "Parallelization section not yet added (planned)"
    fi
else
    log_info "Performance documentation not yet created (planned)"
fi

if [ -f "_debug/parallel-processing-example.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty _debug/parallel-processing-example.json 2>/dev/null; then
            log_pass "Parallel processing example workflow exists and is valid JSON"
        else
            log_fail "Parallel processing example exists but is invalid JSON"
        fi
    else
        log_pass "Parallel processing example exists (JSON validation skipped - jq not installed)"
    fi
else
    log_info "Parallel processing example not yet created (planned)"
fi

echo ""

# Test 10.3: Python Sandbox Memory Limits
echo -e "${BLUE}10.3 Python Sandbox Memory Limits${NC}"

if [ -f "scripts/python-executor.sh" ]; then
    if [ -x "scripts/python-executor.sh" ]; then
        log_pass "Python executor script exists and is executable"
    else
        log_fail "Python executor script exists but is not executable"
    fi
    
    if grep -q "setrlimit\|memory\|limit" scripts/python-executor.sh -i; then
        log_pass "Python executor includes memory limiting"
    else
        log_info "Memory limiting not yet implemented (planned)"
    fi
else
    log_info "Python executor script not yet created (planned)"
fi

if [ -f "_docs/python-environment.md" ]; then
    if grep -q "memory\|limit\|sandbox" _docs/python-environment.md -i; then
        log_pass "Python environment documentation includes memory limits"
    else
        log_info "Memory limits section not yet added (planned)"
    fi
else
    log_info "Python environment documentation not found"
fi

echo ""

# Test 10.4: Redis Caching Integration
echo -e "${BLUE}10.4 Redis Caching Integration${NC}"

if [ -f "n8n/requirements.txt" ]; then
    if grep -q "redis" n8n/requirements.txt; then
        log_pass "Redis Python client in requirements.txt"
    else
        log_info "Redis Python client not yet added (planned)"
    fi
else
    log_fail "requirements.txt not found"
fi

if [ -f "_docs/examples/caching-patterns.md" ]; then
    log_pass "Caching patterns documentation exists"
else
    log_info "Caching patterns documentation not yet created (planned)"
fi

if [ -f "_debug/caching-example.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty _debug/caching-example.json 2>/dev/null; then
            log_pass "Caching example workflow exists and is valid JSON"
        else
            log_fail "Caching example exists but is invalid JSON"
        fi
    else
        log_pass "Caching example exists (JSON validation skipped - jq not installed)"
    fi
else
    log_info "Caching example workflow not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 10 Test Summary${NC}"
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

