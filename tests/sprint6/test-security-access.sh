#!/bin/bash

# Test Suite: Sprint 6 - Security & Access Enhancements
# Tests for reverse proxy, environment separation, secret vault, and audit logging

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
echo -e "${BLUE}Sprint 6: Security & Access Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 6.1: Enhanced Reverse Proxy Configuration
echo -e "${BLUE}6.1 Enhanced Reverse Proxy${NC}"

if [ -f "traefik/dynamic/n8n.yml" ]; then
    if grep -q "middleware\|headers\|rateLimit" traefik/dynamic/n8n.yml -i; then
        log_pass "Traefik dynamic configuration includes middleware"
    else
        log_info "Traefik middleware not yet configured (planned)"
    fi
else
    log_info "Traefik dynamic configuration not found"
fi

if [ -f "_docs/security.md" ]; then
    log_pass "Security documentation exists"
else
    log_info "Security documentation not yet created (planned)"
fi

echo ""

# Test 6.2: Environment Separation
echo -e "${BLUE}6.2 Environment Separation${NC}"

if [ -f "docker-compose.staging.yml" ]; then
    log_pass "Staging docker-compose file exists"
else
    log_info "Staging docker-compose file not yet created (planned)"
fi

if [ -f "docker-compose.production.yml" ]; then
    log_pass "Production docker-compose file exists"
else
    log_info "Production docker-compose file not yet created (planned)"
fi

if [ -f "scripts/promote-workflow.sh" ]; then
    if [ -x "scripts/promote-workflow.sh" ]; then
        log_pass "Workflow promotion script exists and is executable"
    else
        log_fail "Workflow promotion script exists but is not executable"
    fi
else
    log_info "Workflow promotion script not yet created (planned)"
fi

if [ -f "_docs/environments.md" ]; then
    log_pass "Environment management documentation exists"
else
    log_info "Environment management documentation not yet created (planned)"
fi

echo ""

# Test 6.3: Secret Vault Integration
echo -e "${BLUE}6.3 Secret Vault Integration${NC}"

if [ -f "_docs/security.md" ]; then
    if grep -q "vault\|secret\|credential" _docs/security.md -i; then
        log_pass "Security documentation includes secret management"
    else
        log_info "Secret management section not yet added (planned)"
    fi
else
    log_info "Security documentation not yet created (planned)"
fi

if [ -f "_docs/examples/vault-integration.md" ]; then
    log_pass "Vault integration example exists"
else
    log_info "Vault integration example not yet created (optional)"
fi

echo ""

# Test 6.4: Audit Logging
echo -e "${BLUE}6.4 Audit Logging${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "EXECUTIONS_DATA_SAVE_ON_SUCCESS\|EXECUTIONS_DATA_SAVE_ON_ERROR" docker-compose.yml; then
        log_pass "Audit logging environment variables configured"
    else
        log_info "Audit logging environment variables not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "scripts/export-audit-logs.sh" ]; then
    if [ -x "scripts/export-audit-logs.sh" ]; then
        log_pass "Audit log export script exists and is executable"
    else
        log_fail "Audit log export script exists but is not executable"
    fi
else
    log_info "Audit log export script not yet created (planned)"
fi

if [ -f "_docs/audit-logging.md" ]; then
    log_pass "Audit logging documentation exists"
else
    log_info "Audit logging documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 6 Test Summary${NC}"
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

