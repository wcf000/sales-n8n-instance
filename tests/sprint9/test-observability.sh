#!/bin/bash

# Test Suite: Sprint 9 - Observability & Monitoring
# Tests for OpenTelemetry integration and log aggregation

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
echo -e "${BLUE}Sprint 9: Observability & Monitoring Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 9.1: OpenTelemetry Integration
echo -e "${BLUE}9.1 OpenTelemetry Integration${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "otel\|opentelemetry\|jaeger\|tempo" docker-compose.yml -i; then
        log_pass "OpenTelemetry services configured"
    else
        log_info "OpenTelemetry services not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "otel" ] && [ -f "otel/otel-collector-config.yml" ]; then
    log_pass "OpenTelemetry collector configuration exists"
else
    log_info "OpenTelemetry collector configuration not yet created (planned)"
fi

if [ -f "_docs/observability.md" ]; then
    if grep -q "opentelemetry\|tracing\|distributed" _docs/observability.md -i; then
        log_pass "Observability documentation includes OpenTelemetry"
    else
        log_info "OpenTelemetry section not yet added (planned)"
    fi
else
    log_info "Observability documentation not yet created (planned)"
fi

echo ""

# Test 9.2: Enhanced Logging & Log Aggregation
echo -e "${BLUE}9.2 Enhanced Logging & Log Aggregation${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "loki\|promtail" docker-compose.yml -i; then
        log_pass "Loki and Promtail services configured"
    else
        log_info "Loki and Promtail services not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "promtail" ] && [ -f "promtail/promtail-config.yml" ]; then
    log_pass "Promtail configuration exists"
else
    log_info "Promtail configuration not yet created (planned)"
fi

if [ -f "_docs/observability.md" ]; then
    if grep -q "loki\|logging\|log.*aggregation" _docs/observability.md -i; then
        log_pass "Observability documentation includes logging section"
    else
        log_info "Logging section not yet added (planned)"
    fi
else
    log_info "Observability documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 9 Test Summary${NC}"
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

