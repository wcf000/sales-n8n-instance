#!/bin/bash
# Python Environment Validation Script
# This script validates that Python and required packages are installed in the n8n container

set -e

echo "=== Python Environment Validation ==="
echo ""

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo "ERROR: n8n container is not running"
    echo "Start it with: docker compose up -d n8n"
    exit 1
fi

echo "1. Checking Python version..."
PYTHON_VERSION=$(docker compose exec -T n8n python3 --version 2>&1)
echo "   $PYTHON_VERSION"

if ! echo "$PYTHON_VERSION" | grep -q "Python 3"; then
    echo "   ERROR: Python 3 not found"
    exit 1
fi

echo ""
echo "2. Checking pip version..."
PIP_VERSION=$(docker compose exec -T n8n pip3 --version 2>&1)
echo "   $PIP_VERSION"

echo ""
echo "3. Verifying required packages..."

REQUIRED_PACKAGES=(
    "pandas"
    "numpy"
    "requests"
    "openai"
    "beautifulsoup4"
    "lxml"
    "SQLAlchemy"
    "psycopg2"
    "boto3"
)

FAILED=0
for package in "${REQUIRED_PACKAGES[@]}"; do
    if docker compose exec -T n8n python3 -c "import ${package%%-*}" 2>/dev/null; then
        VERSION=$(docker compose exec -T n8n pip3 show "$package" 2>/dev/null | grep "^Version:" | awk '{print $2}' || echo "unknown")
        echo "   ✓ $package ($VERSION)"
    else
        echo "   ✗ $package - NOT FOUND"
        FAILED=1
    fi
done

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "ERROR: Some required packages are missing"
    echo "Rebuild the n8n image: docker compose build n8n"
    exit 1
fi

echo ""
echo "4. Testing basic Python script execution..."
TEST_SCRIPT="import json; import sys; data = {'test': 'success'}; print(json.dumps(data))"
RESULT=$(docker compose exec -T n8n python3 -c "$TEST_SCRIPT" 2>&1)

if echo "$RESULT" | grep -q "success"; then
    echo "   ✓ Python script execution works"
    echo "   Output: $RESULT"
else
    echo "   ✗ Python script execution failed"
    echo "   Output: $RESULT"
    exit 1
fi

echo ""
echo "5. Testing package imports..."
IMPORT_TEST="import pandas as pd; import requests; import openai; print('All imports successful')"
if docker compose exec -T n8n python3 -c "$IMPORT_TEST" 2>&1 | grep -q "successful"; then
    echo "   ✓ All critical packages can be imported"
else
    echo "   ✗ Some packages failed to import"
    exit 1
fi

echo ""
echo "=== Validation Complete ==="
echo "✓ Python environment is properly configured"
echo ""
echo "You can now use Python in n8n workflows via the Execute Command node:"
echo "  Command: python3"
echo "  Arguments: -c \"your_python_code_here\""

