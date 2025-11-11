"""
Pytest configuration and fixtures for API bridge tests.
"""

import os
import sys
from unittest.mock import patch, MagicMock

# Set environment variables before any imports
os.environ.setdefault("N8N_URL", "http://localhost:5678")
os.environ.setdefault("N8N_API_KEY", "test-key")
os.environ.setdefault("POSTGRES_URL", "postgresql://test:test@localhost:5432/test_db")

# Mock database and HTTP clients to prevent hanging on import
sys.modules['sqlalchemy'] = MagicMock()
sys.modules['pgvector'] = MagicMock()
sys.modules['pgvector.sqlalchemy'] = MagicMock()

# Patch create_engine to return a mock
mock_engine = MagicMock()
mock_conn = MagicMock()
mock_engine.connect.return_value.__enter__.return_value = mock_conn
mock_engine.connect.return_value.__exit__.return_value = None

patcher = patch('sqlalchemy.create_engine', return_value=mock_engine)
patcher.start()

