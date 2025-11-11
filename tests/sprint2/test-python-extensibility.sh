#!/bin/bash
# Sprint 2 Tests: Python Execution & Extensibility
# Tests: Python environment, custom nodes, community nodes, webhooks

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
echo "Sprint 2 Tests: Python Execution & Extensibility"
echo "=========================================="
echo ""

# Test 1: Python validation script exists
log_test "Test 2.1: Python validation script exists"
if [ -f "_debug/validate-python.sh" ]; then
    log_pass "_debug/validate-python.sh exists"
    if [ -x "_debug/validate-python.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
else
    log_fail "_debug/validate-python.sh not found"
fi

# Test 2: Test workflows exist
log_test "Test 2.2: Test workflows exist"
if [ -f "_debug/test-python-execution.json" ]; then
    log_pass "_debug/test-python-execution.json exists"
    
    # Validate JSON syntax
    if command -v jq >/dev/null 2>&1; then
        if jq empty "_debug/test-python-execution.json" 2>/dev/null; then
            log_pass "  JSON syntax is valid"
        else
            log_fail "  JSON syntax is invalid"
        fi
    fi
else
    log_fail "_debug/test-python-execution.json not found"
fi

if [ -f "_debug/test-webhook.json" ]; then
    log_pass "_debug/test-webhook.json exists"
else
    log_fail "_debug/test-webhook.json not found"
fi

# Test 3: Webhook test script exists
log_test "Test 2.3: Webhook test script exists"
if [ -f "_debug/test-webhook.sh" ]; then
    log_pass "_debug/test-webhook.sh exists"
    if [ -x "_debug/test-webhook.sh" ]; then
        log_pass "  Script is executable"
    else
        log_fail "  Script is not executable"
    fi
else
    log_fail "_debug/test-webhook.sh not found"
fi

# Test 4: Custom nodes documentation and template
log_test "Test 2.4: Custom nodes template exists"
if [ -f "_docs/custom-nodes.md" ]; then
    log_pass "_docs/custom-nodes.md exists"
else
    log_fail "_docs/custom-nodes.md not found"
fi

TEMPLATE_FILES=(
    "_docs/examples/custom-node-template/package.json"
    "_docs/examples/custom-node-template/tsconfig.json"
    "_docs/examples/custom-node-template/nodes/ExampleNode/ExampleNode.node.ts"
    "_docs/examples/custom-node-template/README.md"
)

for file in "${TEMPLATE_FILES[@]}"; do
    if [ -f "$file" ]; then
        log_pass "  $file exists"
    else
        log_fail "  $file not found"
    fi
done

# Test 5: Community nodes configuration
log_test "Test 2.5: Community nodes configuration"
if [ -f "n8n/community-nodes.json" ]; then
    log_pass "n8n/community-nodes.json exists"
    
    # Validate JSON syntax
    if command -v jq >/dev/null 2>&1; then
        if jq empty "n8n/community-nodes.json" 2>/dev/null; then
            log_pass "  JSON syntax is valid"
            
            # Check for packages array
            if jq -e '.packages' "n8n/community-nodes.json" >/dev/null 2>&1; then
                log_pass "  Packages array exists"
            else
                log_fail "  Packages array not found"
            fi
        else
            log_fail "  JSON syntax is invalid"
        fi
    fi
else
    log_fail "n8n/community-nodes.json not found"
fi

# Test 6: Docker Compose includes community nodes mount
log_test "Test 2.6: Community nodes volume mount"
if grep -q "community-nodes.json" docker-compose.yml; then
    log_pass "Community nodes configuration is mounted"
else
    log_fail "Community nodes configuration not mounted in docker-compose.yml"
fi

# Test 7: Environment variables for community nodes
log_test "Test 2.7: Community nodes environment variables"
if grep -q "N8N_COMMUNITY_PACKAGES_ENABLED" docker-compose.yml; then
    log_pass "N8N_COMMUNITY_PACKAGES_ENABLED is configured"
else
    log_fail "N8N_COMMUNITY_PACKAGES_ENABLED not found"
fi

if grep -q "N8N_COMMUNITY_NODES_INCLUDE" docker-compose.yml; then
    log_pass "N8N_COMMUNITY_NODES_INCLUDE is configured"
else
    log_fail "N8N_COMMUNITY_NODES_INCLUDE not found"
fi

# Test 8: Webhook configuration in docker-compose.yml
log_test "Test 2.8: Webhook configuration"
if grep -q "WEBHOOK_URL" docker-compose.yml; then
    log_pass "WEBHOOK_URL environment variable is configured"
else
    log_fail "WEBHOOK_URL not found in docker-compose.yml"
fi

# Test 9: API integration documentation
log_test "Test 2.9: API integration documentation"
if [ -f "_docs/api-integration.md" ]; then
    log_pass "_docs/api-integration.md exists"
    
    # Check for key sections
    if grep -q "Webhook" "_docs/api-integration.md" && grep -q "API" "_docs/api-integration.md"; then
        log_pass "  Documentation includes webhook and API sections"
    else
        log_fail "  Documentation missing key sections"
    fi
else
    log_fail "_docs/api-integration.md not found"
fi

# Test 10: Python environment documentation
log_test "Test 2.10: Python environment documentation"
if [ -f "_docs/python-environment.md" ]; then
    log_pass "_docs/python-environment.md exists"
    
    # Check for key sections
    KEY_SECTIONS=("pandas" "requests" "openai" "Execute Command")
    for section in "${KEY_SECTIONS[@]}"; do
        if grep -qi "$section" "_docs/python-environment.md"; then
            log_pass "  Section '$section' found in documentation"
        else
            log_fail "  Section '$section' not found in documentation"
        fi
    done
else
    log_fail "_docs/python-environment.md not found"
fi

# Test 11: Dockerfile installs Python packages
log_test "Test 2.11: Dockerfile Python package installation"
if [ -f "n8n/Dockerfile" ]; then
    if grep -q "requirements.txt" "n8n/Dockerfile" && grep -q "pip install" "n8n/Dockerfile"; then
        log_pass "Dockerfile installs packages from requirements.txt"
    else
        log_fail "Dockerfile missing pip install step"
    fi
else
    log_fail "n8n/Dockerfile not found"
fi

# Summary
echo ""
echo "=========================================="
echo "Sprint 2 Test Summary"
echo "=========================================="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All Sprint 2 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some Sprint 2 tests failed!${NC}"
    exit 1
fi

