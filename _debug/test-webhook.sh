#!/bin/bash
# Webhook Test Script
# This script tests the n8n webhook endpoint

set -e

# Configuration
N8N_URL="${N8N_URL:-http://localhost:5678}"
WEBHOOK_PATH="${WEBHOOK_PATH:-test-webhook}"
WEBHOOK_TOKEN="${WEBHOOK_TOKEN:-}"

echo "=== Webhook Test Script ==="
echo ""

# Construct webhook URL
if [ -n "$WEBHOOK_TOKEN" ]; then
    WEBHOOK_URL="${N8N_URL}/webhook/${WEBHOOK_PATH}?token=${WEBHOOK_TOKEN}"
else
    WEBHOOK_URL="${N8N_URL}/webhook/${WEBHOOK_PATH}"
fi

echo "Testing webhook at: $WEBHOOK_URL"
echo ""

# Test data
TEST_DATA='{
  "test": true,
  "message": "Webhook test from script",
  "timestamp": "'$(date -u +"%Y-%m-%dT%H:%M:%SZ")'",
  "data": {
    "key1": "value1",
    "key2": "value2"
  }
}'

echo "1. Sending POST request with test data..."
echo "   Data: $TEST_DATA"
echo ""

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$TEST_DATA" \
    "$WEBHOOK_URL" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE/d')

echo "2. Response received:"
echo "   HTTP Status: $HTTP_CODE"
echo "   Response Body:"
echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "✓ Webhook test successful!"
    echo ""
    echo "The webhook is working correctly."
    exit 0
else
    echo "✗ Webhook test failed!"
    echo ""
    echo "Possible issues:"
    echo "  - Workflow not activated in n8n"
    echo "  - Webhook path incorrect"
    echo "  - n8n instance not running"
    echo "  - Authentication required"
    echo ""
    echo "Check n8n logs: docker compose logs n8n"
    exit 1
fi

