#!/bin/bash
# Sprint 3 Tests: Scalability & Reliability
# Tests: Worker mode, backup/restore, monitoring

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASSED=0
FAILED=0

log_test() {
    echo -e "${GREEN}[TEST]${NC} $1"
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
echo "Sprint 3 Tests: Scalability & Reliability"
echo "=========================================="
echo ""

# Test 1: Redis service configuration
log_test "Test 3.1: Redis service for worker mode"
if grep -q "redis:" docker-compose.yml; then
    log_pass "Redis service is defined"
    
    # Check Redis image
    if grep -q "redis:" docker-compose.yml | grep -q "image:"; then
        log_pass "  Redis image is specified"
    fi
    
    # Check Redis health check
    if grep -A 10 "^\s*redis:" docker-compose.yml | grep -q "healthcheck"; then
        log_pass "  Redis health check is configured"
    else
        log_fail "  Redis health check not found"
    fi
else
    log_fail "Redis service not found in docker-compose.yml"
fi

# Test 2: Worker mode services
log_test "Test 3.2: Worker mode services"
if grep -q "n8n-main:" docker-compose.yml; then
    log_pass "n8n-main service is defined"
else
    log_fail "n8n-main service not found"
fi

if grep -q "n8n-worker:" docker-compose.yml; then
    log_pass "n8n-worker service is defined"
    
    # Check worker command
    if grep -A 3 "n8n-worker:" docker-compose.yml | grep -q "worker"; then
        log_pass "  Worker command is configured"
    else
        log_fail "  Worker command not found"
    fi
else
    log_fail "n8n-worker service not found"
fi

# Test 3: Worker mode environment variables
log_test "Test 3.3: Worker mode environment variables"
if grep -q "EXECUTIONS_MODE" docker-compose.yml; then
    log_pass "EXECUTIONS_MODE is configured"
else
    log_fail "EXECUTIONS_MODE not found"
fi

REDIS_VARS=("QUEUE_BULL_REDIS_HOST" "QUEUE_BULL_REDIS_PORT" "QUEUE_BULL_REDIS_DB")
for var in "${REDIS_VARS[@]}"; do
    if grep -q "$var" docker-compose.yml; then
        log_pass "  $var is configured"
    else
        log_fail "  $var not found"
    fi
done

# Test 4: Worker mode profiles
log_test "Test 3.4: Worker mode profiles"
if grep -q "profiles:" docker-compose.yml && grep -A 1 "profiles:" docker-compose.yml | grep -q "worker"; then
    log_pass "Worker profile is configured"
else
    log_fail "Worker profile not found"
fi

# Test 5: Backup script exists
log_test "Test 3.5: Backup script exists"
if [ -f "scripts/backup.sh" ]; then
    log_pass "scripts/backup.sh exists"
    if [ -x "scripts/backup.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
    
    # Check for key backup features
    if grep -q "pg_dump" "scripts/backup.sh"; then
        log_pass "  Database backup functionality exists"
    else
        log_fail "  Database backup functionality missing"
    fi
    
    if grep -q "docker volume" "scripts/backup.sh" || grep -q "volume" "scripts/backup.sh"; then
        log_pass "  Volume backup functionality exists"
    else
        log_fail "  Volume backup functionality missing"
    fi
else
    log_fail "scripts/backup.sh not found"
fi

# Test 6: Restore script exists
log_test "Test 3.6: Restore script exists"
if [ -f "scripts/restore.sh" ]; then
    log_pass "scripts/restore.sh exists"
    if [ -x "scripts/restore.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
    
    # Check for restore functionality
    if grep -q "psql" "scripts/restore.sh" || grep -q "restore" "scripts/restore.sh"; then
        log_pass "  Database restore functionality exists"
    else
        log_fail "  Database restore functionality missing"
    fi
else
    log_fail "scripts/restore.sh not found"
fi

# Test 7: Monitoring scripts
log_test "Test 3.7: Monitoring scripts exist"
if [ -f "_debug/monitoring/health-check.sh" ]; then
    log_pass "_debug/monitoring/health-check.sh exists"
    if [ -x "_debug/monitoring/health-check.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
else
    log_fail "_debug/monitoring/health-check.sh not found"
fi

if [ -f "_debug/monitoring/resource-usage.sh" ]; then
    log_pass "_debug/monitoring/resource-usage.sh exists"
    if [ -x "_debug/monitoring/resource-usage.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
else
    log_fail "_debug/monitoring/resource-usage.sh not found"
fi

# Test 8: Worker mode documentation
log_test "Test 3.8: Worker mode documentation"
if [ -f "_docs/worker-mode.md" ]; then
    log_pass "_docs/worker-mode.md exists"
    
    # Check for key sections
    KEY_SECTIONS=("Redis" "worker" "queue" "scaling")
    for section in "${KEY_SECTIONS[@]}"; do
        if grep -qi "$section" "_docs/worker-mode.md"; then
            log_pass "  Section '$section' found in documentation"
        else
            log_fail "  Section '$section' not found in documentation"
        fi
    done
else
    log_fail "_docs/worker-mode.md not found"
fi

# Test 9: Backup/recovery documentation
log_test "Test 3.9: Backup/recovery documentation"
if [ -f "_docs/backup-recovery.md" ]; then
    log_pass "_docs/backup-recovery.md exists"
    
    # Check for key sections
    KEY_SECTIONS=("backup" "restore" "PostgreSQL" "volume")
    for section in "${KEY_SECTIONS[@]}"; do
        if grep -qi "$section" "_docs/backup-recovery.md"; then
            log_pass "  Section '$section' found in documentation"
        else
            log_fail "  Section '$section' not found in documentation"
        fi
    done
else
    log_fail "_docs/backup-recovery.md not found"
fi

# Test 10: Redis volume
log_test "Test 3.10: Redis volume configuration"
if grep -q "redis_storage:" docker-compose.yml; then
    log_pass "Redis volume is defined"
else
    log_fail "Redis volume not found"
fi

# Test 11: Backup script includes manifest
log_test "Test 3.11: Backup script creates manifest"
if grep -q "manifest" "scripts/backup.sh" || grep -q "MANIFEST" "scripts/backup.sh"; then
    log_pass "Backup script includes manifest creation"
else
    log_fail "Backup script missing manifest creation"
fi

# Test 12: Health check script checks services
log_test "Test 3.12: Health check script validates services"
if [ -f "_debug/monitoring/health-check.sh" ]; then
    if grep -q "postgres" "_debug/monitoring/health-check.sh" && grep -q "n8n" "_debug/monitoring/health-check.sh"; then
        log_pass "Health check script validates key services"
    else
        log_fail "Health check script missing service validation"
    fi
else
    log_fail "Health check script not found"
fi

# Summary
echo ""
echo "=========================================="
echo "Sprint 3 Test Summary"
echo "=========================================="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All Sprint 3 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some Sprint 3 tests failed!${NC}"
    exit 1
fi

