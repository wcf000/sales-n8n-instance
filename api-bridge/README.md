# API Bridge

FastAPI REST Bridge and GraphQL API for n8n platform integration.

## Development Setup

### Prerequisites

- Python 3.11+
- [uv](https://github.com/astral-sh/uv) (ultrafast Python package manager)

### Quick Start

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Navigate to api-bridge directory
cd api-bridge

# Create virtual environment and install dependencies
uv sync --all-extras --dev

# Activate virtual environment
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Run the application
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Using uv

```bash
# Add a new dependency
uv add package-name

# Add a development dependency
uv add --dev package-name

# Update dependencies
uv sync --upgrade

# Run commands in the virtual environment
uv run pytest
uv run ruff check .
uv run black .
```

## Code Quality

### Pre-commit Hooks

Install pre-commit hooks to automatically format and lint code before commits:

```bash
# Install pre-commit (included in dev dependencies)
uv run pre-commit install

# Run hooks manually on all files
uv run pre-commit run --all-files
```

### Linting & Formatting

```bash
# Lint with Ruff (auto-fix)
uv run ruff check . --fix

# Format with Black
uv run black .

# Type check with mypy
uv run mypy .
```

### Testing

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=. --cov-report=html

# Run specific test file
uv run pytest tests/test_health.py -v
```

## Project Structure

```
api-bridge/
├── main.py              # FastAPI application
├── pyproject.toml       # Project configuration (dependencies, tools)
├── pytest.ini          # Pytest configuration
├── tests/              # Test files
│   ├── __init__.py
│   └── test_health.py
└── .venv/              # Virtual environment (created by uv)
```

## Configuration

All tool configurations are in `pyproject.toml`:

- **Black**: Code formatting (line length: 100)
- **Ruff**: Linting and import sorting
- **Mypy**: Type checking
- **Pytest**: Test configuration

## CI/CD

The CI pipeline automatically:
- Runs pre-commit hooks
- Lints with Ruff
- Formats with Black
- Type checks with mypy
- Runs tests with pytest
- Builds Docker images

## Environment Variables

```bash
N8N_URL=http://n8n:5678
N8N_API_KEY=your-api-key
POSTGRES_URL=postgresql://user:pass@host:5432/dbname
```

## API Endpoints

- `GET /health` - Health check
- `GET /` - API information
- `GET /api/v1/workflows` - List workflows
- `POST /api/v1/workflows/{id}/trigger` - Trigger workflow
- `POST /api/v1/vector/search` - Vector search
- `POST /api/v1/vector/insert` - Insert vector
- `POST /graphql` - GraphQL endpoint

## Docker

```bash
# Build image
docker build -t api-bridge:latest -f Dockerfile .

# Run container
docker run -p 8000:8000 \
  -e N8N_URL=http://n8n:5678 \
  -e N8N_API_KEY=your-key \
  api-bridge:latest
```

