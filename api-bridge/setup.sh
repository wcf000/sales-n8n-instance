#!/bin/bash
# Quick setup script for API Bridge development environment

set -e

echo "🚀 Setting up API Bridge development environment..."

# Check if uv is installed
if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv (ultrafast Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
else
    echo "✅ uv is already installed"
fi

# Check Python version
echo "🐍 Checking Python version..."
python_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
if [[ $(echo "$python_version >= 3.11" | bc -l 2>/dev/null || echo "0") == "0" ]]; then
    echo "⚠️  Warning: Python 3.11+ is recommended. Current version: $python_version"
fi

# Create virtual environment and install dependencies
echo "📚 Installing dependencies..."
uv sync --all-extras --dev

# Install pre-commit hooks
echo "🔧 Installing pre-commit hooks..."
uv run pre-commit install

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Activate virtual environment: source .venv/bin/activate"
echo "  2. Run the server: make run"
echo "  3. Run tests: make test"
echo "  4. Format code: make format"
echo ""
echo "Available commands:"
echo "  make help          - Show all available commands"
echo "  make test          - Run tests"
echo "  make lint          - Lint code"
echo "  make format        - Format code"
echo "  make check         - Run all checks"
echo "  make run           - Start development server"
echo ""

