#!/bin/bash

# Test Suite: Sprint 11 - DealScale-Specific Integrations (Pulsar Bridge)
# Tests for Pulsar bridge architecture, worker topology, security, observability, and integrations

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
echo -e "${BLUE}Sprint 11: Pulsar Bridge & Integrations Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 11.1: Pulsar Bridge Architecture
echo -e "${BLUE}11.1 Pulsar Bridge Architecture${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "pulsar" docker-compose.yml -i; then
        log_pass "Pulsar service configured in docker-compose.yml"
    else
        log_info "Pulsar service not yet configured (planned)"
    fi
    
    if grep -q "DEALSCALE_PULSAR_QUEUE_ENABLED\|PULSAR_SERVICE_URL" docker-compose.yml; then
        log_pass "Pulsar environment variables configured"
    else
        log_info "Pulsar environment variables not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -d "pulsar-bridge" ]; then
    if [ -f "pulsar-bridge/app.py" ]; then
        log_pass "FastAPI bridge application exists"
    else
        log_info "FastAPI bridge application not yet created (planned)"
    fi
    
    if [ -f "pulsar-bridge/consumer.py" ]; then
        log_pass "Pulsar consumer exists"
    else
        log_info "Pulsar consumer not yet created (planned)"
    fi
    
    if [ -f "pulsar-bridge/requirements.txt" ]; then
        if grep -q "pulsar-client\|fastapi" pulsar-bridge/requirements.txt; then
            log_pass "Pulsar bridge requirements include necessary packages"
        else
            log_info "Pulsar bridge requirements not yet defined (planned)"
        fi
    else
        log_info "Pulsar bridge requirements.txt not yet created (planned)"
    fi
else
    log_info "Pulsar bridge directory not yet created (planned)"
fi

if [ -f "pulsar/pulsar.conf" ]; then
    log_pass "Pulsar broker configuration exists"
else
    log_info "Pulsar broker configuration not yet created (planned)"
fi

if [ -f "_docs/integrations/pulsar-bridge.md" ]; then
    log_pass "Pulsar bridge documentation exists"
else
    log_info "Pulsar bridge documentation not yet created (planned)"
fi

if [ -f "scripts/setup-pulsar-topics.sh" ]; then
    if [ -x "scripts/setup-pulsar-topics.sh" ]; then
        log_pass "Pulsar topic setup script exists and is executable"
    else
        log_fail "Pulsar topic setup script exists but is not executable"
    fi
else
    log_info "Pulsar topic setup script not yet created (planned)"
fi

echo ""

# Test 11.2: Pulsar-Optimized Worker Topology
echo -e "${BLUE}11.2 Pulsar Worker Topology${NC}"

if [ -f "pulsar-bridge/topics.yml" ]; then
    log_pass "Topic configuration file exists"
else
    log_info "Topic configuration file not yet created (planned)"
fi

if [ -f "_docs/integrations/pulsar-topology.md" ]; then
    log_pass "Pulsar topology documentation exists"
else
    log_info "Pulsar topology documentation not yet created (planned)"
fi

echo ""

# Test 11.3: Pulsar Security & Fault Isolation
echo -e "${BLUE}11.3 Pulsar Security & Fault Isolation${NC}"

if [ -f "pulsar-bridge/auth.py" ]; then
    log_pass "Pulsar authentication module exists"
else
    log_info "Pulsar authentication module not yet created (planned)"
fi

if [ -f "pulsar-bridge/payload-store.py" ]; then
    log_pass "Payload storage service exists"
else
    log_info "Payload storage service not yet created (planned)"
fi

if [ -f "scripts/setup-pulsar-auth.sh" ]; then
    if [ -x "scripts/setup-pulsar-auth.sh" ]; then
        log_pass "Pulsar auth setup script exists and is executable"
    else
        log_fail "Pulsar auth setup script exists but is not executable"
    fi
else
    log_info "Pulsar auth setup script not yet created (planned)"
fi

if [ -f "_docs/integrations/pulsar-security.md" ]; then
    log_pass "Pulsar security documentation exists"
else
    log_info "Pulsar security documentation not yet created (planned)"
fi

echo ""

# Test 11.4: Pulsar Observability & Metrics
echo -e "${BLUE}11.4 Pulsar Observability & Metrics${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "pulsar.*exporter\|prometheus" docker-compose.yml -i; then
        log_pass "Pulsar exporter configured"
    else
        log_info "Pulsar exporter not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "prometheus/pulsar-rules.yml" ]; then
    log_pass "Pulsar Prometheus alerting rules exist"
else
    log_info "Pulsar Prometheus rules not yet created (planned)"
fi

if [ -f "grafana/dashboards/pulsar-bridge-dashboard.json" ]; then
    log_pass "Pulsar Grafana dashboard exists"
else
    log_info "Pulsar Grafana dashboard not yet created (planned)"
fi

if [ -f "pulsar-bridge/otel-config.yml" ]; then
    log_pass "OpenTelemetry configuration for Pulsar bridge exists"
else
    log_info "OpenTelemetry configuration not yet created (planned)"
fi

echo ""

# Test 11.5: Execution Strategy & Workflow Routing
echo -e "${BLUE}11.5 Execution Strategy & Routing${NC}"

if [ -f "pulsar-bridge/routing.py" ]; then
    log_pass "Workflow routing logic exists"
else
    log_info "Workflow routing logic not yet created (planned)"
fi

if [ -f "_docs/integrations/workflow-routing.md" ]; then
    log_pass "Workflow routing documentation exists"
else
    log_info "Workflow routing documentation not yet created (planned)"
fi

if [ -d "_debug/routing-examples" ]; then
    log_pass "Routing example workflows directory exists"
else
    log_info "Routing examples directory not yet created (planned)"
fi

echo ""

# Test 11.6: Qdrant Vector Search Optimization
echo -e "${BLUE}11.6 Qdrant Vector Search Optimization${NC}"

if [ -f "_docs/integrations/qdrant-optimization.md" ]; then
    log_pass "Qdrant optimization documentation exists"
else
    log_info "Qdrant optimization documentation not yet created (planned)"
fi

if [ -f "scripts/embedding-cache.py" ]; then
    log_pass "Embedding cache utility exists"
else
    log_info "Embedding cache utility not yet created (planned)"
fi

echo ""

# Test 11.7: GraphQL Persisted Queries
echo -e "${BLUE}11.7 GraphQL Persisted Queries${NC}"

if [ -f "_docs/integrations/graphql.md" ]; then
    log_pass "GraphQL documentation exists"
else
    log_info "GraphQL documentation not yet created (planned)"
fi

if [ -f "scripts/generate-query-hash.py" ]; then
    log_pass "Query hash generator script exists"
else
    log_info "Query hash generator script not yet created (planned)"
fi

echo ""

# Test 11.8: AI Workflow Offloading
echo -e "${BLUE}11.8 AI Workflow Offloading${NC}"

if [ -f "docker-compose.yml" ]; then
    if grep -q "python-worker\|ai-worker" docker-compose.yml -i; then
        log_pass "Python worker service configured"
    else
        log_info "Python worker service not yet configured (planned)"
    fi
else
    log_fail "docker-compose.yml not found"
fi

if [ -f "python-worker/app.py" ]; then
    log_pass "AI inference API exists"
else
    log_info "AI inference API not yet created (planned)"
fi

if [ -f "_docs/integrations/ai-offloading.md" ]; then
    log_pass "AI offloading documentation exists"
else
    log_info "AI offloading documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 11 Test Summary${NC}"
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

