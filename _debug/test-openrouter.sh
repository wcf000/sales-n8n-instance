#!/bin/bash
# OpenRouter Test Script
# Tests OpenRouter integration in n8n container

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== OpenRouter Integration Test ==="
echo ""

# Check if n8n container is running
if ! docker compose ps n8n | grep -q "Up"; then
    echo -e "${RED}ERROR: n8n container is not running${NC}"
    echo "Start it with: docker compose up -d n8n"
    exit 1
fi

# Check if OPENROUTER_API_KEY is set
if [ -z "$OPENROUTER_API_KEY" ]; then
    echo -e "${YELLOW}Warning: OPENROUTER_API_KEY not set in environment${NC}"
    echo "Set it in .env file or export it:"
    echo "  export OPENROUTER_API_KEY=sk-or-v1-your-key-here"
    echo ""
    echo "Skipping API test, but checking Python setup..."
    SKIP_API_TEST=true
else
    SKIP_API_TEST=false
fi

# Test 1: Check if openai package is installed
echo "1. Checking OpenAI package..."
if docker compose exec -T n8n python3 -c "import openai; print(f'OpenAI version: {openai.__version__}')" 2>/dev/null; then
    echo -e "${GREEN}   ✓ OpenAI package installed${NC}"
else
    echo -e "${RED}   ✗ OpenAI package not found${NC}"
    exit 1
fi

# Test 2: Check if script exists
echo ""
echo "2. Checking test script..."
if [ -f "_debug/test-openrouter.py" ]; then
    echo -e "${GREEN}   ✓ Test script exists${NC}"
else
    echo -e "${RED}   ✗ Test script not found${NC}"
    exit 1
fi

# Test 3: Run OpenRouter API test (if key is set)
if [ "$SKIP_API_TEST" = false ]; then
    echo ""
    echo "3. Testing OpenRouter API connection..."
    echo "   (This will make a real API call and may incur costs)"
    echo ""
    
    # Copy script to container and run
    docker compose exec -T n8n python3 - <<EOF
import os
import json
import sys
from openai import OpenAI

api_key = os.environ.get('OPENROUTER_API_KEY', '${OPENROUTER_API_KEY}')

try:
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=api_key,
    )
    
    response = client.chat.completions.create(
        model="openai/gpt-3.5-turbo",
        messages=[{"role": "user", "content": "Say 'test' and nothing else."}],
        max_tokens=10
    )
    
    result = {
        "success": True,
        "model": response.model,
        "response": response.choices[0].message.content.strip(),
        "tokens": response.usage.total_tokens
    }
    print(json.dumps(result, indent=2))
except Exception as e:
    result = {
        "success": False,
        "error": str(e)
    }
    print(json.dumps(result, indent=2))
    sys.exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}   ✓ OpenRouter API test successful${NC}"
    else
        echo -e "${RED}   ✗ OpenRouter API test failed${NC}"
        exit 1
    fi
else
    echo ""
    echo "3. Skipping API test (OPENROUTER_API_KEY not set)"
    echo -e "${YELLOW}   To test API: Set OPENROUTER_API_KEY and run again${NC}"
fi

echo ""
echo -e "${GREEN}=== OpenRouter Integration Test Complete ===${NC}"
echo ""
echo "To use OpenRouter in n8n workflows:"
echo "  1. Set OPENROUTER_API_KEY in .env or n8n environment"
echo "  2. Use Execute Command node with Python script"
echo "  3. See _docs/openrouter-integration.md for examples"

