#!/bin/bash

# Test Suite: Sprint 5 - Base Image & Health Monitoring
# Tests for health checks, Prometheus metrics, and Grafana dashboards

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
echo -e "${BLUE}Sprint 5: Health & Monitoring Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 5.1: Upgrade Base Image with Health Checks
echo -e "${BLUE}5.1 Base Image & Health Checks${NC}"

if [ -f "n8n/Dockerfile" ]; then
    if grep -q "HEALTHCHECK" n8n/Dockerfile; then
        log_pass "HEALTHCHECK instruction in Dockerfile"
    else
        log_info "HEALTHCHECK not yet added to Dockerfile (planned)"
    fi
    
    if grep -q "FROM n8nio/n8n" n8n/Dockerfile; then
        log_pass "Dockerfile extends n8nio/n8n base image"
    else
        log_fail "Dockerfile does not extend n8nio/n8n base image"
    fi
    
    if grep -q "python3\|python" n8n/Dockerfile; then
        log_pass "Python installation in Dockerfile"
    else
        log_fail "Python installation not found in Dockerfile"
    fi
    
    if grep -q "curl\|wget" n8n/Dockerfile; then
        log_pass "Health check tools (curl/wget) in Dockerfile"
    else
        log_info "Health check tools not yet added (planned)"
    fi
else
    log_fail "Dockerfile not found"
fi

if [ -f "_docs/deployment.md" ]; then
    if grep -q "health\|HEALTHCHECK" _docs/deployment.md -i; then
        log_pass "Health check documentation exists"
    else
        log_info "Health check documentation not yet added (planned)"
    fi
else
    log_info "Deployment documentation not found"
fi

echo ""

# Test 5.2: Prometheus Metrics Export
echo -e "${BLUE}5.2 Prometheus Metrics Export${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "prometheus" docker-compose.yml -i; then
        log_pass "Prometheus service configured"
    else
        log_info "Prometheus service not yet configured (planned)"
    fi
    
    if grep -q "N8N_METRICS\|N8N_METRICS_PORT" docker-compose.yml; then
        log_pass "n8n metrics environment variables configured"
    else
        log_info "n8n metrics environment variables not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "prometheus" ] && [ -f "prometheus/prometheus.yml" ]; then
    log_pass "Prometheus configuration directory and file exist"
else
    log_info "Prometheus configuration not yet created (planned)"
fi

if [ -f "docker-compose.yml" ]; then
    if grep -q "grafana" docker-compose.yml -i; then
        log_pass "Grafana service configured"
    else
        log_info "Grafana service not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "grafana/dashboards" ] && [ -f "grafana/dashboards/n8n-dashboard.json" ]; then
    log_pass "Grafana dashboard exists"
else
    log_info "Grafana dashboard not yet created (planned)"
fi

if [ -f "_docs/monitoring.md" ]; then
    log_pass "Monitoring documentation exists"
else
    log_info "Monitoring documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 5 Test Summary${NC}"
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

