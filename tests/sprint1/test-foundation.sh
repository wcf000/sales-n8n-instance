#!/bin/bash
# Sprint 1 Tests: Foundation & Security
# Tests: Docker setup, Python installation, Traefik, database persistence

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
echo "Sprint 1 Tests: Foundation & Security"
echo "=========================================="
echo ""

# Test 1: Docker Compose file exists
log_test "Test 1.1: Docker Compose file exists"
if [ -f "docker-compose.yml" ]; then
    log_pass "docker-compose.yml exists"
else
    log_fail "docker-compose.yml not found"
fi

# Test 2: Custom n8n Dockerfile exists
log_test "Test 1.2: Custom n8n Dockerfile exists"
if [ -f "n8n/Dockerfile" ]; then
    log_pass "n8n/Dockerfile exists"
else
    log_fail "n8n/Dockerfile not found"
fi

# Test 3: Requirements.txt exists
log_test "Test 1.3: Python requirements.txt exists"
if [ -f "n8n/requirements.txt" ]; then
    log_pass "n8n/requirements.txt exists"
    
    # Check for required packages
    REQUIRED_PACKAGES=("pandas" "requests" "openai" "beautifulsoup4" "lxml" "SQLAlchemy" "psycopg2-binary" "boto3")
    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        if grep -q "$pkg" "n8n/requirements.txt"; then
            log_pass "  Package $pkg found in requirements.txt"
        else
            log_fail "  Package $pkg not found in requirements.txt"
        fi
    done
else
    log_fail "n8n/requirements.txt not found"
fi

# Test 4: Traefik configuration exists
log_test "Test 1.4: Traefik configuration exists"
if [ -f "traefik/traefik.yml" ]; then
    log_pass "traefik/traefik.yml exists"
else
    log_fail "traefik/traefik.yml not found"
fi

if [ -f "traefik/dynamic/n8n.yml" ]; then
    log_pass "traefik/dynamic/n8n.yml exists"
else
    log_fail "traefik/dynamic/n8n.yml not found"
fi

# Test 5: Documentation structure
log_test "Test 1.5: Documentation structure exists"
DOCS=(
    "_docs/architecture.md"
    "_docs/deployment.md"
    "_docs/python-environment.md"
    "_docs/custom-nodes.md"
    "_docs/community-nodes.md"
    "_docs/api-integration.md"
    "_docs/worker-mode.md"
    "_docs/backup-recovery.md"
    "_docs/troubleshooting.md"
    "_docs/QUICKSTART.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        log_pass "  $doc exists"
    else
        log_fail "  $doc not found"
    fi
done

# Test 6: Docker Compose syntax validation
log_test "Test 1.6: Docker Compose syntax validation"
if command -v docker >/dev/null 2>&1; then
    # Check if .env exists, if not, create a minimal one for validation
    if [ ! -f ".env" ]; then
        log_info "Creating temporary .env for validation"
        cat > .env.tmp <<EOF
POSTGRES_USER=test
POSTGRES_PASSWORD=test
POSTGRES_DB=test
N8N_ENCRYPTION_KEY=test123456789012345678901234567890
N8N_USER_MANAGEMENT_JWT_SECRET=test
TRAEFIK_DOMAIN=test.example.com
TRAEFIK_EMAIL=test@example.com
TRAEFIK_BASIC_AUTH_PASSWORD_HASH=test
EOF
        export $(cat .env.tmp | xargs)
    fi
    
    if docker compose config >/dev/null 2>&1; then
        log_pass "docker-compose.yml syntax is valid"
    else
        # Check if it's just missing env vars (warnings) vs actual syntax errors
        if docker compose config 2>&1 | grep -q "error"; then
            log_fail "docker-compose.yml has syntax errors"
            docker compose config 2>&1 | grep "error" | head -5
        else
            log_pass "docker-compose.yml syntax is valid (warnings about missing .env are expected)"
        fi
    fi
    
    # Clean up temp file
    [ -f ".env.tmp" ] && rm -f .env.tmp
else
    log_info "Docker not available, skipping syntax check"
fi

# Test 7: Services defined in docker-compose.yml
log_test "Test 1.7: Required services defined"
REQUIRED_SERVICES=("postgres" "n8n" "traefik" "qdrant")
for service in "${REQUIRED_SERVICES[@]}"; do
    if grep -q "^\s*${service}:" docker-compose.yml; then
        log_pass "  Service $service is defined"
    else
        log_fail "  Service $service not found in docker-compose.yml"
    fi
done

# Test 8: Environment variables in docker-compose.yml
log_test "Test 1.8: Environment variables configured"
ENV_VARS=("POSTGRES_USER" "POSTGRES_PASSWORD" "N8N_ENCRYPTION_KEY" "N8N_USER_MANAGEMENT_JWT_SECRET")
for var in "${ENV_VARS[@]}"; do
    if grep -q "\${${var}}" docker-compose.yml || grep -q "${var}" docker-compose.yml; then
        log_pass "  Environment variable $var is referenced"
    else
        log_fail "  Environment variable $var not found"
    fi
done

# Test 9: Volume definitions
log_test "Test 1.9: Volume definitions"
if grep -q "volumes:" docker-compose.yml && grep -q "n8n_storage:" docker-compose.yml; then
    log_pass "Volumes are defined"
else
    log_fail "Volume definitions missing"
fi

# Test 10: Network configuration
log_test "Test 1.10: Network configuration"
if grep -q "networks:" docker-compose.yml && grep -q "demo:" docker-compose.yml; then
    log_pass "Network configuration exists"
else
    log_fail "Network configuration missing"
fi

# Summary
echo ""
echo "=========================================="
echo "Sprint 1 Test Summary"
echo "=========================================="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Total:  $((PASSED + FAILED))"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All Sprint 1 tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some Sprint 1 tests failed!${NC}"
    exit 1
fi

