# Changelog & Updates

This document tracks all updates, enhancements, and changes made to the self-hosted n8n platform.

## Version 1.0.0 - Initial Release (2025-01-11)

### 🎉 Epic Completion

All user stories from the original epic have been completed and verified:

#### Sprint 1: Foundation & Security ✅
- ✅ Deploy n8n + Persistent Database
- ✅ Secure behind reverse proxy (Traefik + SSL/TLS)

#### Sprint 2: Python Execution & Extensibility ✅
- ✅ Embed Python runtime (Python 3.12.12)
- ✅ Decoupled custom nodes repository structure
- ✅ Webhook/API integration

#### Sprint 3: Scalability & Reliability ✅
- ✅ Scalable worker mode (Redis + n8n-worker)
- ✅ Backup/recovery automation

### 🆕 Major Features Added

#### Python Execution Layer
- **Python 3.12.12** installed in n8n container
- **Curated packages** pre-installed:
  - `pandas` 2.3.3 - Data manipulation
  - `numpy` 1.26.4 - Numerical computing
  - `requests` 2.32.5 - HTTP library
  - `openai` 1.109.1 - OpenAI SDK (OpenRouter compatible)
  - `anthropic` - Anthropic Claude SDK
  - `beautifulsoup4` 4.14.2 - Web scraping
  - `lxml` - XML/HTML processing
  - `SQLAlchemy` 2.0.44 - Database ORM
  - `psycopg2-binary` 2.9.11 - PostgreSQL adapter
  - `boto3` 1.40.70 - AWS SDK

#### OpenRouter Integration
- **Built-in OpenRouter support** for accessing 100+ LLM models
- Unified API for GPT-4, Claude, Gemini, Llama, and more
- Complete documentation and examples
- Test scripts for validation

#### Infrastructure
- **Traefik reverse proxy** with SSL/TLS support
- **PostgreSQL 16** with persistent volumes
- **Redis** for worker mode queue management
- **Qdrant** vector database
- **Ollama** LLM server (CPU/GPU support)

#### Documentation
- Comprehensive documentation in `_docs/`:
  - Architecture overview
  - Deployment guide
  - Python environment guide
  - Custom nodes development
  - Community nodes setup
  - API/Webhook integration
  - Worker mode configuration
  - Backup/recovery procedures
  - Troubleshooting guide
  - Local development guide
  - OpenRouter integration guide

#### Testing & Validation
- Complete test suite (38 tests across 3 sprints)
- Verification scripts
- Health check scripts
- Monitoring tools

#### Automation Scripts
- Backup script (`scripts/backup.sh`)
- Restore script (`scripts/restore.sh`)
- Development startup script (`scripts/dev-start.sh`)
- Environment setup scripts
- Python validation script
- Webhook test script
- OpenRouter test script

### 📝 Documentation Files Created

1. `_docs/architecture.md` - System architecture and component relationships
2. `_docs/deployment.md` - Deployment instructions and environment setup
3. `_docs/python-environment.md` - Python execution environment documentation
4. `_docs/custom-nodes.md` - Custom nodes development guide
5. `_docs/community-nodes.md` - Community nodes installation guide
6. `_docs/api-integration.md` - Webhook and API configuration
7. `_docs/worker-mode.md` - Worker mode setup and configuration
8. `_docs/backup-recovery.md` - Backup and recovery procedures
9. `_docs/troubleshooting.md` - Common issues and solutions
10. `_docs/QUICKSTART.md` - Quick start guide
11. `_docs/LOCAL_DEVELOPMENT.md` - Local development guide
12. `_docs/openrouter-integration.md` - OpenRouter API integration guide
13. `_docs/COMPLETION_STATUS.md` - Implementation completion status
14. `_docs/CHANGELOG.md` - This file

### 🔧 Configuration Files

- `docker-compose.yml` - Complete Docker Compose configuration
- `n8n/Dockerfile` - Custom n8n image with Python
- `n8n/requirements.txt` - Python package dependencies
- `n8n/community-nodes.json` - Community nodes configuration
- `traefik/traefik.yml` - Traefik main configuration
- `traefik/dynamic/n8n.yml` - Dynamic routing rules
- `SETUP.md` - Environment setup instructions

### 🧪 Test Files

- `tests/sprint1/test-foundation.sh` - Sprint 1 tests
- `tests/sprint2/test-python-extensibility.sh` - Sprint 2 tests
- `tests/sprint3/test-scalability-reliability.sh` - Sprint 3 tests
- `tests/run-all-tests.sh` - Master test runner
- `_debug/validate-python.sh` - Python environment validation
- `_debug/test-webhook.sh` - Webhook testing
- `_debug/test-openrouter.sh` - OpenRouter testing
- `_debug/monitoring/health-check.sh` - Health monitoring
- `_debug/monitoring/resource-usage.sh` - Resource monitoring

### 📦 Example Files

- `_docs/examples/custom-node-template/` - Custom node template
- `_docs/examples/openrouter-example.py` - OpenRouter usage example
- `_debug/test-python-execution.json` - Python test workflow
- `_debug/test-webhook.json` - Webhook test workflow
- `_debug/test-openrouter-workflow.json` - OpenRouter test workflow

### 🔄 Recent Updates

#### 2025-01-11 - OpenRouter Integration
- Added OpenRouter API support
- Added `anthropic` package for Claude support
- Created OpenRouter integration documentation
- Added test scripts and examples
- Updated environment configuration

#### 2025-01-11 - Port Mapping Fix
- Fixed n8n port exposure in docker-compose.yml
- Added direct port mapping for local development
- Resolved connection issues

#### 2025-01-11 - Python Installation Fix
- Fixed Alpine Linux Python 3.11+ PEP 668 restrictions
- Added `--break-system-packages` flag for pip installs
- Verified all packages install correctly

#### 2025-01-11 - Environment Configuration
- Created `.env` file with proper escaping
- Fixed Traefik basic auth hash escaping
- Added environment setup scripts for Windows and Linux

### 🐛 Bug Fixes

- Fixed Docker Compose environment variable warnings
- Fixed Python package installation on Alpine Linux
- Fixed n8n port not being exposed to host
- Fixed Traefik configuration file syntax

### 📚 Documentation Updates

- Added comprehensive OpenRouter integration guide
- Updated Python environment documentation
- Added local development guide
- Created completion status document
- Updated README with implementation status table

### 🔐 Security Improvements

- Proper environment variable escaping
- Secure credential handling
- SSL/TLS configuration via Traefik
- Basic authentication middleware

### ⚡ Performance Improvements

- Optimized Docker image build process
- Reduced image size by cleaning build dependencies
- Efficient Python package installation

### 🚀 Future Enhancements (Planned)

- Integration with Kestra orchestration pipelines
- Built-in AI model registry and function calling layer
- Advanced Role-Based Access Control (RBAC)
- Prometheus exporters for execution metrics
- Additional LLM provider integrations

### 📊 Statistics

- **Total Files Created**: 50+
- **Documentation Pages**: 14
- **Test Cases**: 38
- **Scripts**: 10+
- **Example Workflows**: 3
- **Python Packages**: 9 core packages
- **Docker Services**: 7 (n8n, postgres, traefik, redis, qdrant, ollama, n8n-worker)

### 🎯 Verification

All features verified with:
- ✅ Static validation tests (38/38 passing)
- ✅ Runtime verification scripts
- ✅ Health check scripts
- ✅ Manual testing

### 📖 How to Stay Updated

1. Check this CHANGELOG.md for recent updates
2. Review `_docs/COMPLETION_STATUS.md` for feature status
3. Run `./scripts/verify-implementation.sh` to verify setup
4. Run `./tests/run-all-tests.sh` to run full test suite

### 🔗 Related Documentation

- [Implementation Status](COMPLETION_STATUS.md)
- [Quick Start Guide](QUICKSTART.md)
- [Local Development](LOCAL_DEVELOPMENT.md)
- [Architecture Overview](architecture.md)
- [Deployment Guide](deployment.md)

---

**Last Updated**: 2025-01-11  
**Version**: 1.0.0  
**Status**: Production Ready ✅

