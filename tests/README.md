# Test Suite Documentation

This directory contains comprehensive tests for the n8n self-hosted platform implementation, organized by sprint.

## Test Types

### Static Validation Tests (Current)

The current test suite performs **static validation** - it checks:
- ✅ File existence and structure
- ✅ Configuration file syntax
- ✅ Documentation completeness
- ✅ Script executability
- ✅ Docker Compose syntax (without running containers)

**These tests do NOT require Docker to be running** - they validate the codebase structure and configuration files.

### Runtime Tests (Future Enhancement)

For full validation, you would need:
- Docker running
- Services started
- Actual functionality testing

We can add runtime tests that verify:
- Services start correctly
- Python environment works
- Database connectivity
- Webhook functionality
- Worker mode execution

## Test Structure

```
tests/
├── sprint1/
│   └── test-foundation.sh          # Foundation & Security tests
├── sprint2/
│   └── test-python-extensibility.sh # Python Execution & Extensibility tests
├── sprint3/
│   └── test-scalability-reliability.sh # Scalability & Reliability tests
├── run-all-tests.sh                # Master test runner
└── README.md                       # This file
```

## Running Tests

### Run All Tests

```bash
./tests/run-all-tests.sh
```

This will execute:
- All Sprint 1 tests (Foundation & Security)
- All Sprint 2 tests (Python Execution & Extensibility)
- All Sprint 3 tests (Scalability & Reliability)
- Epic-level integration tests

### Run Individual Sprint Tests

```bash
# Sprint 1: Foundation & Security
./tests/sprint1/test-foundation.sh

# Sprint 2: Python Execution & Extensibility
./tests/sprint2/test-python-extensibility.sh

# Sprint 3: Scalability & Reliability
./tests/sprint3/test-scalability-reliability.sh
```

## Test Coverage

### Sprint 1: Foundation & Security (10 tests)

1. Docker Compose file exists
2. Custom n8n Dockerfile exists
3. Python requirements.txt exists with required packages
4. Traefik configuration exists
5. Documentation structure exists (10+ files)
6. Docker Compose syntax validation
7. Required services defined (postgres, n8n, traefik, qdrant)
8. Environment variables configured
9. Volume definitions
10. Network configuration

### Sprint 2: Python Execution & Extensibility (11 tests)

1. Python validation script exists and is executable
2. Test workflows exist and are valid JSON
3. Webhook test script exists and is executable
4. Custom nodes template exists with all files
5. Community nodes configuration exists and is valid JSON
6. Community nodes volume mount in docker-compose.yml
7. Community nodes environment variables
8. Webhook configuration in docker-compose.yml
9. API integration documentation
10. Python environment documentation with key sections
11. Dockerfile installs Python packages

### Sprint 3: Scalability & Reliability (12 tests)

1. Redis service for worker mode
2. Worker mode services (n8n-main, n8n-worker)
3. Worker mode environment variables
4. Worker mode profiles
5. Backup script exists and is executable
6. Restore script exists and is executable
7. Monitoring scripts exist and are executable
8. Worker mode documentation
9. Backup/recovery documentation
10. Redis volume configuration
11. Backup script creates manifest
12. Health check script validates services

### Epic Integration Tests (5 tests)

1. Documentation completeness (10+ files)
2. Script executability (all scripts executable)
3. Docker Compose services (7+ services)
4. Python packages (8+ packages)
5. Test workflow validity (valid JSON)

## Test Results

When tests pass, you'll see:
```
==========================================
  ALL TESTS PASSED! ✓
==========================================
```

When tests fail, you'll see:
```
==========================================
  SOME TESTS FAILED! ✗
==========================================
```

## Test Output

Tests provide colored output:
- 🟢 **GREEN [PASS]**: Test passed
- 🔴 **RED [FAIL]**: Test failed
- 🟡 **YELLOW [INFO]**: Informational message
- 🔵 **BLUE**: Section headers

## Prerequisites

Tests require:
- Bash shell
- Docker and Docker Compose (for syntax validation only, not runtime)
- `jq` (optional, for JSON validation)

## Adding Runtime Tests

To add runtime tests that require Docker:

1. Check if Docker is running:
   ```bash
   if ! docker info >/dev/null 2>&1; then
       log_info "Docker not running, skipping runtime tests"
       return
   fi
   ```

2. Start services:
   ```bash
   docker compose up -d
   ```

3. Wait for services to be ready:
   ```bash
   docker compose exec -T postgres pg_isready
   ```

4. Run functional tests

5. Clean up:
   ```bash
   docker compose down
   ```

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Run Static Tests
  run: ./tests/run-all-tests.sh

- name: Run Runtime Tests (optional)
  run: |
    docker compose up -d
    ./tests/runtime-tests.sh
    docker compose down
```

## Troubleshooting

### Tests fail due to missing .env

The tests handle missing `.env` files gracefully. If you see warnings about environment variables, this is expected when running tests without a full setup.

### Docker not available

Tests that require Docker will be skipped if Docker is not available, with an informational message.

### JSON validation fails

If `jq` is not installed, JSON validation tests will be skipped. Install `jq` for full test coverage.

## Test Statistics

Current test coverage:
- **Sprint 1**: 10 tests
- **Sprint 2**: 11 tests
- **Sprint 3**: 12 tests
- **Epic Integration**: 5 tests
- **Total**: 38 tests

All tests validate the implementation against the epic requirements and acceptance criteria.
