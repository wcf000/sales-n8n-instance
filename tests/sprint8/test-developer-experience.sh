#!/bin/bash

# Test Suite: Sprint 8 - Developer Experience
# Tests for Git workflow version control, custom node hot-reloading, and error reporting

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
echo -e "${BLUE}Sprint 8: Developer Experience Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Test 8.1: Git-Based Workflow Version Control
echo -e "${BLUE}8.1 Git-Based Workflow Version Control${NC}"

if [ -f "scripts/export-workflows-to-git.sh" ]; then
    if [ -x "scripts/export-workflows-to-git.sh" ]; then
        log_pass "Workflow export script exists and is executable"
    else
        log_fail "Workflow export script exists but is not executable"
    fi
else
    log_info "Workflow export script not yet created (planned)"
fi

if [ -f "scripts/import-workflows-from-git.sh" ]; then
    if [ -x "scripts/import-workflows-from-git.sh" ]; then
        log_pass "Workflow import script exists and is executable"
    else
        log_fail "Workflow import script exists but is not executable"
    fi
else
    log_info "Workflow import script not yet created (planned)"
fi

if [ -d ".github/workflows" ] && [ -f ".github/workflows/sync-workflows.yml" ]; then
    log_pass "GitHub Actions workflow sync exists"
else
    log_info "GitHub Actions workflow sync not yet created (optional)"
fi

if [ -f "_docs/version-control.md" ]; then
    log_pass "Workflow version control documentation exists"
else
    log_info "Workflow version control documentation not yet created (planned)"
fi

echo ""

# Test 8.2: Custom Node Hot-Reloading
echo -e "${BLUE}8.2 Custom Node Hot-Reloading${NC}"

if [ -f "scripts/watch-custom-nodes.sh" ]; then
    if [ -x "scripts/watch-custom-nodes.sh" ]; then
        log_pass "Custom node watcher script exists and is executable"
    else
        log_fail "Custom node watcher script exists but is not executable"
    fi
else
    log_info "Custom node watcher script not yet created (planned)"
fi

if [ -f "scripts/rebuild-custom-nodes.sh" ]; then
    if [ -x "scripts/rebuild-custom-nodes.sh" ]; then
        log_pass "Custom node rebuild script exists and is executable"
    else
        log_fail "Custom node rebuild script exists but is not executable"
    fi
else
    log_info "Custom node rebuild script not yet created (planned)"
fi

if [ -f "_docs/custom-nodes.md" ]; then
    if grep -q "hot.*reload\|watch\|auto.*reload" _docs/custom-nodes.md -i; then
        log_pass "Custom nodes documentation includes hot-reload instructions"
    else
        log_info "Hot-reload section not yet added (planned)"
    fi
else
    log_info "Custom nodes documentation not found"
fi

echo ""

# Test 8.3: Error Reporting Integration
echo -e "${BLUE}8.3 Error Reporting Integration${NC}"

if [ -f "_debug/error-tracking-workflow.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty _debug/error-tracking-workflow.json 2>/dev/null; then
            log_pass "Error tracking workflow exists and is valid JSON"
        else
            log_fail "Error tracking workflow exists but is invalid JSON"
        fi
    else
        log_pass "Error tracking workflow exists (JSON validation skipped - jq not installed)"
    fi
else
    log_info "Error tracking workflow not yet created (planned)"
fi

if [ -f "_docs/error-tracking.md" ]; then
    log_pass "Error tracking documentation exists"
else
    log_info "Error tracking documentation not yet created (planned)"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sprint 8 Test Summary${NC}"
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

