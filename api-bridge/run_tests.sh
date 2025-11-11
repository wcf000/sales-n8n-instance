#!/bin/bash
# Test runner script for API bridge

set -e

echo "🧪 Running API Bridge Test Suite..."
echo ""

# Check if we're in the right directory
if [ ! -f "main.py" ]; then
    echo "❌ Error: main.py not found. Please run from api-bridge directory."
    exit 1
fi

# Try to use uv if available
if command -v uv &> /dev/null; then
    echo "✅ Using uv for test execution..."
    echo ""
    uv run pytest tests/ -v --tb=short
else
    echo "⚠️  uv not found, using system Python..."
    echo ""
    python -m pytest tests/ -v --tb=short
fi

echo ""
echo "✅ Test suite completed!"

