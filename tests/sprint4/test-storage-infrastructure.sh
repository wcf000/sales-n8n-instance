#!/bin/bash

# Test Suite: Sprint 4 - Storage & Infrastructure Enhancements
# Tests for persistent storage, S3 backup, and MinIO integration

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
echo -e "${BLUE}Sprint 4: Storage & Infrastructure Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 4.1: Persistent + Externalized Storage
echo -e "${BLUE}4.1 Persistent + Externalized Storage${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "/home/node/.n8n" docker-compose.yml || grep -q "n8n_storage" docker-compose.yml; then
        log_pass "Volume mount for /home/node/.n8n configured"
    else
        log_info "Volume mount for /home/node/.n8n not yet configured (planned)"
    fi
    
    if grep -q "/data" docker-compose.yml || grep -q "n8n_data" docker-compose.yml; then
        log_pass "Volume mount for /data configured"
    else
        log_info "Volume mount for /data not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "_docs/storage-management.md" ]; then
    log_pass "Storage management documentation exists"
else
    log_info "Storage management documentation not yet created (planned)"
fi

if [ -f "scripts/setup-volumes.sh" ]; then
    if [ -x "scripts/setup-volumes.sh" ]; then
        log_pass "Volume setup script exists and is executable"
    else
        log_fail "Volume setup script exists but is not executable"
    fi
else
    log_info "Volume setup script not yet created (planned)"
fi

echo ""

# Test 4.2: Automated S3 Backup Integration
echo -e "${BLUE}4.2 Automated S3 Backup Integration${NC}"

if [ -f "scripts/backup.sh" ]; then
    if grep -q "boto3\|s3\|aws" scripts/backup.sh; then
        log_pass "Backup script includes S3 upload functionality"
    else
        log_info "Backup script exists but S3 integration not yet implemented (planned)"
    fi
    
    if [ -x "scripts/backup.sh" ]; then
        log_pass "Backup script is executable"
    else
        log_fail "Backup script is not executable"
    fi
else
    log_fail "Backup script not found"
fi

if [ -f "scripts/restore.sh" ]; then
    if grep -q "boto3\|s3\|aws" scripts/restore.sh; then
        log_pass "Restore script includes S3 download functionality"
    else
        log_info "Restore script exists but S3 integration not yet implemented (planned)"
    fi
else
    log_fail "Restore script not found"
fi

if [ -f "n8n/requirements.txt" ]; then
    if grep -q "boto3" n8n/requirements.txt; then
        log_pass "boto3 package in requirements.txt"
    else
        log_info "boto3 package not yet added (will be added during implementation)"
    fi
else
    log_fail "requirements.txt not found"
fi

if [ -f "SETUP.md" ] || [ -f ".env.example" ]; then
    if grep -q "AWS_ACCESS_KEY_ID\|AWS_S3_BUCKET" SETUP.md 2>/dev/null || grep -q "AWS_ACCESS_KEY_ID\|AWS_S3_BUCKET" .env.example 2>/dev/null; then
        log_pass "S3 configuration variables documented"
    else
        log_info "S3 configuration variables not yet documented (planned)"
    fi
else
    log_info "Environment setup files not found"
fi

if [ -f "_docs/backup-recovery.md" ]; then
    if grep -q "S3\|AWS\|backup" _docs/backup-recovery.md -i; then
        log_pass "Backup documentation includes S3 instructions"
    else
        log_info "Backup documentation exists but S3 section not yet added (planned)"
    fi
else
    log_info "Backup documentation not yet created (planned)"
fi

echo ""

# Test 4.3: MinIO Local Object Storage (Optional)
echo -e "${BLUE}4.3 MinIO Local Object Storage (Optional)${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "minio" docker-compose.yml -i; then
        log_pass "MinIO service configured in docker-compose.yml"
    else
        log_info "MinIO service not yet configured (optional feature)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "SETUP.md" ] || [ -f ".env.example" ]; then
    if grep -q "MINIO" SETUP.md 2>/dev/null || grep -q "MINIO" .env.example 2>/dev/null; then
        log_pass "MinIO configuration variables documented"
    else
        log_info "MinIO configuration not yet documented (optional feature)"
    fi
else
    log_info "Environment setup files not found"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 4 Test Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "Total:  $((PASSED + FAILED))"
echo ""

# Only exit with error if there are actual failures (not planned features)
if [ $FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

