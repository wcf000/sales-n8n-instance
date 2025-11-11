#!/bin/bash
# Run All Tests for the Epic
# Executes all sprint tests and provides summary

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_PASSED=0
TOTAL_FAILED=0
SPRINT_RESULTS=()

echo "=========================================="
echo "  n8n Platform - Complete Test Suite"
echo "=========================================="
echo ""

# Function to run sprint tests
run_sprint_test() {
    local sprint=$1
    local test_file=$2
    
    echo -e "${BLUE}Running $sprint tests...${NC}"
    echo "----------------------------------------"
    
    if [ -f "$test_file" ]; then
        if bash "$test_file"; then
            SPRINT_RESULTS+=("$sprint: PASSED")
            TOTAL_PASSED=$((TOTAL_PASSED + 1))
        else
            SPRINT_RESULTS+=("$sprint: FAILED")
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
    else
        echo -e "${RED}Test file not found: $test_file${NC}"
        SPRINT_RESULTS+=("$sprint: ERROR - Test file missing")
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
    echo ""
}

# Run Sprint 1 tests
run_sprint_test "Sprint 1: Foundation & Security" "tests/sprint1/test-foundation.sh"

# Run Sprint 2 tests
run_sprint_test "Sprint 2: Python Execution & Extensibility" "tests/sprint2/test-python-extensibility.sh"

# Run Sprint 3 tests
run_sprint_test "Sprint 3: Scalability & Reliability" "tests/sprint3/test-scalability-reliability.sh"

# Run Enhancement Plan Sprint 4 tests
run_sprint_test "Sprint 4: Storage & Infrastructure" "tests/sprint4/test-storage-infrastructure.sh"

# Run Enhancement Plan Sprint 5 tests
run_sprint_test "Sprint 5: Health & Monitoring" "tests/sprint5/test-health-monitoring.sh"

# Run Enhancement Plan Sprint 6 tests
run_sprint_test "Sprint 6: Security & Access" "tests/sprint6/test-security-access.sh"

# Run Enhancement Plan Sprint 7 tests
run_sprint_test "Sprint 7: Performance Optimizations" "tests/sprint7/test-performance.sh"

# Run Enhancement Plan Sprint 8 tests
run_sprint_test "Sprint 8: Developer Experience" "tests/sprint8/test-developer-experience.sh"

# Run Enhancement Plan Sprint 9 tests
run_sprint_test "Sprint 9: Observability & Monitoring" "tests/sprint9/test-observability.sh"

# Run Enhancement Plan Sprint 10 tests
run_sprint_test "Sprint 10: Workflow Enhancements" "tests/sprint10/test-workflow-enhancements.sh"

# Run Enhancement Plan Sprint 11 tests
run_sprint_test "Sprint 11: Pulsar Bridge & Integrations" "tests/sprint11/test-pulsar-integrations.sh"

# Run Integration Tests (pgvector, GraphQL, REST)
run_sprint_test "Integrations: pgvector, GraphQL, REST" "tests/integrations/test-pgvector-graphql-rest.sh"

# Epic-level integration tests
echo -e "${BLUE}Running Epic Integration Tests...${NC}"
echo "----------------------------------------"

EPIC_PASSED=0
EPIC_FAILED=0

# Test: All documentation exists
echo -e "${GREEN}[TEST]${NC} Epic Integration: Documentation completeness"
DOC_COUNT=$(find _docs -name "*.md" -type f | wc -l)
if [ "$DOC_COUNT" -ge 10 ]; then
    echo -e "${GREEN}[PASS]${NC} Documentation files: $DOC_COUNT"
    EPIC_PASSED=$((EPIC_PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Expected at least 10 documentation files, found: $DOC_COUNT"
    EPIC_FAILED=$((EPIC_FAILED + 1))
fi

# Test: All scripts are executable
echo -e "${GREEN}[TEST]${NC} Epic Integration: Script executability"
SCRIPT_COUNT=0
EXECUTABLE_COUNT=0
for script in scripts/*.sh _debug/*.sh _debug/monitoring/*.sh; do
    if [ -f "$script" ]; then
        SCRIPT_COUNT=$((SCRIPT_COUNT + 1))
        if [ -x "$script" ]; then
            EXECUTABLE_COUNT=$((EXECUTABLE_COUNT + 1))
        fi
    fi
done

if [ "$SCRIPT_COUNT" -eq "$EXECUTABLE_COUNT" ] && [ "$SCRIPT_COUNT" -gt 0 ]; then
    echo -e "${GREEN}[PASS]${NC} All $SCRIPT_COUNT scripts are executable"
    EPIC_PASSED=$((EPIC_PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} $EXECUTABLE_COUNT/$SCRIPT_COUNT scripts are executable"
    EPIC_FAILED=$((EPIC_FAILED + 1))
fi

# Test: Docker Compose includes all required services
echo -e "${GREEN}[TEST]${NC} Epic Integration: Docker Compose services"
REQUIRED_SERVICES=("postgres" "n8n" "traefik" "qdrant" "redis" "n8n-main" "n8n-worker")
SERVICES_FOUND=0
for service in "${REQUIRED_SERVICES[@]}"; do
    if grep -q "^\s*${service}:" docker-compose.yml; then
        SERVICES_FOUND=$((SERVICES_FOUND + 1))
    fi
done

if [ "$SERVICES_FOUND" -ge 4 ]; then
    echo -e "${GREEN}[PASS]${NC} Found $SERVICES_FOUND required services in docker-compose.yml"
    EPIC_PASSED=$((EPIC_PASSED + 1))
else
    echo -e "${RED}[FAIL]${NC} Only found $SERVICES_FOUND of required services"
    EPIC_FAILED=$((EPIC_FAILED + 1))
fi

# Test: Python packages in requirements.txt
echo -e "${GREEN}[TEST]${NC} Epic Integration: Python packages"
if [ -f "n8n/requirements.txt" ]; then
    PKG_COUNT=$(wc -l < n8n/requirements.txt | tr -d ' ')
    if [ "$PKG_COUNT" -ge 8 ]; then
        echo -e "${GREEN}[PASS]${NC} Found $PKG_COUNT packages in requirements.txt"
        EPIC_PASSED=$((EPIC_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} Expected at least 8 packages, found: $PKG_COUNT"
        EPIC_FAILED=$((EPIC_FAILED + 1))
    fi
else
    echo -e "${RED}[FAIL]${NC} requirements.txt not found"
    EPIC_FAILED=$((EPIC_FAILED + 1))
fi

# Test: Test workflows are valid JSON
echo -e "${GREEN}[TEST]${NC} Epic Integration: Test workflow validity"
if command -v jq >/dev/null 2>&1; then
    VALID_WORKFLOWS=0
    TOTAL_WORKFLOWS=0
    for workflow in _debug/*.json; do
        if [ -f "$workflow" ]; then
            TOTAL_WORKFLOWS=$((TOTAL_WORKFLOWS + 1))
            if jq empty "$workflow" 2>/dev/null; then
                VALID_WORKFLOWS=$((VALID_WORKFLOWS + 1))
            fi
        fi
    done
    
    if [ "$VALID_WORKFLOWS" -eq "$TOTAL_WORKFLOWS" ] && [ "$TOTAL_WORKFLOWS" -gt 0 ]; then
        echo -e "${GREEN}[PASS]${NC} All $TOTAL_WORKFLOWS test workflows are valid JSON"
        EPIC_PASSED=$((EPIC_PASSED + 1))
    else
        echo -e "${RED}[FAIL]${NC} $VALID_WORKFLOWS/$TOTAL_WORKFLOWS workflows are valid JSON"
        EPIC_FAILED=$((EPIC_FAILED + 1))
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} jq not available, skipping JSON validation"
fi

echo ""
echo "=========================================="
echo "  Epic Integration Test Summary"
echo "=========================================="
echo "Passed: $EPIC_PASSED"
echo "Failed: $EPIC_FAILED"
echo ""

TOTAL_PASSED=$((TOTAL_PASSED + EPIC_PASSED))
TOTAL_FAILED=$((TOTAL_FAILED + EPIC_FAILED))

# Final Summary
echo "=========================================="
echo "  COMPLETE TEST SUITE SUMMARY"
echo "=========================================="
echo ""
echo "Sprint Results:"
for result in "${SPRINT_RESULTS[@]}"; do
    if [[ "$result" == *"PASSED"* ]]; then
        echo -e "  ${GREEN}✓${NC} $result"
    else
        echo -e "  ${RED}✗${NC} $result"
    fi
done
echo ""
echo "Epic Integration:"
if [ $EPIC_FAILED -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} All integration tests passed"
else
    echo -e "  ${RED}✗${NC} Some integration tests failed"
fi
echo ""
echo "Overall Statistics:"
echo "  Total Passed: $TOTAL_PASSED"
echo "  Total Failed: $TOTAL_FAILED"
echo "  Total Tests:  $((TOTAL_PASSED + TOTAL_FAILED))"
echo ""

if [ $TOTAL_FAILED -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo "  ALL TESTS PASSED! ✓"
    echo "==========================================${NC}"
    exit 0
else
    echo -e "${RED}=========================================="
    echo "  SOME TESTS FAILED! ✗"
    echo "==========================================${NC}"
    exit 1
fi

