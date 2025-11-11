.PHONY: help install dev test lint format type-check clean run

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Install uv and dependencies
	@echo "Installing uv..."
	@curl -LsSf https://astral.sh/uv/install.sh | sh
	@echo "Installing dependencies..."
	uv sync --all-extras --dev

dev: ## Install development dependencies
	uv sync --all-extras --dev

test: ## Run tests
	uv run pytest tests/ -v

test-cov: ## Run tests with coverage
	uv run pytest tests/ -v --cov=. --cov-report=html --cov-report=term

lint: ## Lint code with Ruff
	uv run ruff check . --fix

format: ## Format code with Black
	uv run black .

format-check: ## Check code formatting
	uv run black --check .

type-check: ## Type check with mypy
	uv run mypy .

check: lint format-check type-check ## Run all checks (lint, format, type)

pre-commit: ## Run pre-commit hooks
	uv run pre-commit run --all-files

pre-commit-install: ## Install pre-commit hooks
	uv run pre-commit install

run: ## Run the development server
	uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000

clean: ## Clean cache and build artifacts
	find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
	find . -type d -name .pytest_cache -exec rm -r {} + 2>/dev/null || true
	find . -type d -name .mypy_cache -exec rm -r {} + 2>/dev/null || true
	find . -type d -name .ruff_cache -exec rm -r {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	rm -rf htmlcov/ .coverage coverage.xml

update: ## Update all dependencies
	uv sync --upgrade --all-extras --dev

