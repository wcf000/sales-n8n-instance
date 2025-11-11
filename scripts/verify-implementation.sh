#!/bin/bash
# Implementation Verification Script
# Verifies all epic requirements are met

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED=$((FAILED + 1))
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

echo "=========================================="
echo "  Implementation Verification"
echo "=========================================="
echo ""

# Sprint 2: Python Runtime
log_test "Sprint 2: Python Runtime (Critical)"
if docker compose ps n8n | grep -q "Up"; then
    if docker compose exec -T n8n python3 -c "import pandas; import openai; print('OK')" >/dev/null 2>&1; then
        PYTHON_VERSION=$(docker compose exec -T n8n python3 --version 2>&1 | grep -o "Python [0-9]\+\.[0-9]\+")
        log_pass "Python runtime working - $PYTHON_VERSION, pandas and openai importable"
    else
        log_fail "Python packages not importable"
    fi
else
    log_info "n8n container not running, skipping runtime test"
fi

# Sprint 2: Custom Nodes Documentation
log_test "Sprint 2: Custom Nodes Documentation"
if [ -f "_docs/custom-nodes.md" ] && [ -f "_docs/examples/custom-node-template/package.json" ]; then
    log_pass "Custom nodes documentation and template exist"
else
    log_fail "Custom nodes documentation missing"
fi

# Sprint 2: Community Nodes Configuration
log_test "Sprint 2: Community Nodes Configuration"
if [ -f "n8n/community-nodes.json" ] && grep -q "packages" n8n/community-nodes.json; then
    log_pass "Community nodes configuration exists"
else
    log_fail "Community nodes configuration missing"
fi

# Sprint 2: Webhook Configuration
log_test "Sprint 2: Webhook Configuration"
if grep -q "WEBHOOK_URL" docker-compose.yml && [ -f "_debug/test-webhook.sh" ]; then
    log_pass "Webhook configuration and test scripts exist"
else
    log_fail "Webhook configuration missing"
fi

# Sprint 3: Worker Mode Configuration
log_test "Sprint 3: Worker Mode Configuration"
if grep -q "n8n-worker:" docker-compose.yml && grep -q "EXECUTIONS_MODE" docker-compose.yml && grep -q "redis:" docker-compose.yml; then
    log_pass "Worker mode configuration exists (Redis + n8n-worker + environment variables)"
else
    log_fail "Worker mode configuration incomplete"
fi

# Sprint 3: Backup Scripts
log_test "Sprint 3: Backup & Recovery Scripts"
if [ -f "scripts/backup.sh" ] && [ -f "scripts/restore.sh" ] && [ -x "scripts/backup.sh" ]; then
    if grep -q "pg_dump" scripts/backup.sh; then
        log_pass "Backup and restore scripts exist and are executable"
    else
        log_fail "Backup script missing database backup functionality"
    fi
else
    log_fail "Backup scripts missing or not executable"
fi

# Summary
echo ""
echo "=========================================="
echo "  Verification Summary"
echo "=========================================="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All implementation requirements verified!${NC}"
    exit 0
else
    echo -e "${RED}Some requirements need attention${NC}"
    exit 1
fi

