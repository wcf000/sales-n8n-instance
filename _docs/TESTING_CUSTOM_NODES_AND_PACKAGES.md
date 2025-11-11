# Testing Custom Nodes and Python Packages

This guide shows you how to test the custom nodes and Python packages installed in your n8n instance.

## 🎯 Quick Test Guide

### 1. Test Custom Nodes (LangChain)

Your instance has **@n8n/n8n-nodes-langchain** installed. Here's how to test it:

#### Step 1: Create a New Workflow
1. Go to http://localhost:5678
2. Click **"Add workflow"** or **"New workflow"**
3. Click the **"+"** button to add nodes

#### Step 2: Add LangChain Nodes
1. Search for **"LangChain"** in the node search
2. You should see nodes like:
   - **LangChain Chat Model**
   - **LangChain Chain**
   - **LangChain Memory**
   - **LangChain Tool**

#### Step 3: Test with Ollama
1. Add a **"Chat Trigger"** node (for testing)
2. Add a **"LangChain Chat Model"** node
3. Configure it to use **Ollama** (if you have Ollama running)
4. Add a **"LangChain Chain"** node
5. Connect them and test!

### 2. Test Python Packages

#### Method 1: Using Execute Command Node

**Test Pandas:**
1. Add an **"Execute Command"** node
2. Set **Command**: `python3`
3. Set **Arguments**: `-c`
4. In **Stdin** or **Arguments**, add:
```python
import json
import sys
import pandas as pd

# Read input
data = json.load(sys.stdin)

# Create DataFrame
df = pd.DataFrame([data] if isinstance(data, dict) else data)

# Process
result = {
    "pandas_version": pd.__version__,
    "rows": len(df),
    "columns": list(df.columns) if hasattr(df, 'columns') else [],
    "message": "Pandas is working!"
}

print(json.dumps(result))
```

**Test OpenAI/OpenRouter:**
```python
import json
import sys
import os

try:
    import openai
    result = {
        "openai_available": True,
        "version": openai.__version__,
        "message": "OpenAI SDK is installed!"
    }
except ImportError as e:
    result = {
        "openai_available": False,
        "error": str(e)
    }

print(json.dumps(result))
```

**Test Requests:**
```python
import json
import sys
import requests

try:
    response = requests.get("https://httpbin.org/json", timeout=5)
    result = {
        "requests_available": True,
        "status_code": response.status_code,
        "data": response.json(),
        "message": "Requests library is working!"
    }
except Exception as e:
    result = {
        "requests_available": False,
        "error": str(e)
    }

print(json.dumps(result))
```

**Test BeautifulSoup (Web Scraping):**
```python
import json
import sys
from bs4 import BeautifulSoup

html = """
<html>
<head><title>Test Page</title></head>
<body>
    <h1>Hello World</h1>
    <p>This is a test</p>
</body>
</html>
"""

soup = BeautifulSoup(html, 'html.parser')
result = {
    "beautifulsoup_available": True,
    "title": soup.title.string if soup.title else None,
    "heading": soup.h1.string if soup.h1 else None,
    "paragraph": soup.p.string if soup.p else None,
    "message": "BeautifulSoup is working!"
}

print(json.dumps(result))
```

#### Method 2: Using Code Node (if available)

If you have the Code node enabled:
1. Add a **"Code"** node
2. Select **Python** as the language
3. Use the same code examples above

## 🧪 Complete Test Workflow

### Create a Test Workflow

1. **Start Node**: Add a **"Manual Trigger"** or **"Schedule Trigger"**
2. **Python Test Node**: Add **"Execute Command"** node
3. **Set Command**: `python3`
4. **Set Arguments**: `-c`
5. **Add Test Script** (see examples above)

### Example: Comprehensive Package Test

```python
import json
import sys

results = {}

# Test Pandas
try:
    import pandas as pd
    results["pandas"] = {
        "installed": True,
        "version": pd.__version__
    }
except ImportError:
    results["pandas"] = {"installed": False}

# Test NumPy
try:
    import numpy as np
    results["numpy"] = {
        "installed": True,
        "version": np.__version__
    }
except ImportError:
    results["numpy"] = {"installed": False}

# Test Requests
try:
    import requests
    results["requests"] = {
        "installed": True,
        "version": requests.__version__
    }
except ImportError:
    results["requests"] = {"installed": False}

# Test OpenAI
try:
    import openai
    results["openai"] = {
        "installed": True,
        "version": openai.__version__
    }
except ImportError:
    results["openai"] = {"installed": False}

# Test BeautifulSoup
try:
    from bs4 import BeautifulSoup
    results["beautifulsoup4"] = {"installed": True}
except ImportError:
    results["beautifulsoup4"] = {"installed": False}

# Test SQLAlchemy
try:
    import sqlalchemy
    results["sqlalchemy"] = {
        "installed": True,
        "version": sqlalchemy.__version__
    }
except ImportError:
    results["sqlalchemy"] = {"installed": False}

# Test boto3
try:
    import boto3
    results["boto3"] = {"installed": True}
except ImportError:
    results["boto3"] = {"installed": False}

print(json.dumps({
    "status": "success",
    "packages": results,
    "summary": {
        "total": len(results),
        "installed": sum(1 for pkg in results.values() if pkg.get("installed", False))
    }
}, indent=2))
```

## 🔍 Verify Custom Nodes

### Check Installed Community Nodes

1. Go to **Settings** (gear icon)
2. Navigate to **Community Nodes**
3. You should see **@n8n/n8n-nodes-langchain** listed

### Test LangChain Nodes

1. Create a new workflow
2. Add nodes and search for:
   - **"LangChain"** - Should show LangChain-related nodes
   - **"Chat Model"** - Should show LangChain Chat Model
   - **"Chain"** - Should show LangChain Chain nodes

## 📝 Quick Test Checklist

- [ ] Python 3.12 is available in container
- [ ] Pandas package is installed
- [ ] NumPy package is installed
- [ ] Requests package is installed
- [ ] OpenAI SDK is installed
- [ ] BeautifulSoup is installed
- [ ] SQLAlchemy is installed
- [ ] LangChain nodes are available in n8n UI
- [ ] Execute Command node can run Python scripts
- [ ] Python scripts can import and use packages

## 🚀 Advanced Testing

### Test Database Connection (PostgreSQL)

```python
import json
import sys
import os
from sqlalchemy import create_engine, text

try:
    # Get database URL from environment
    db_url = os.getenv("DB_POSTGRESDB_HOST", "postgres")
    db_user = os.getenv("DB_POSTGRESDB_USER", "n8n")
    db_pass = os.getenv("DB_POSTGRESDB_PASSWORD", "")
    db_name = os.getenv("DB_POSTGRESDB_DATABASE", "n8n")
    
    # Create connection string
    conn_str = f"postgresql://{db_user}:{db_pass}@{db_url}:5432/{db_name}"
    
    # Test connection
    engine = create_engine(conn_str)
    with engine.connect() as conn:
        result = conn.execute(text("SELECT version()"))
        version = result.fetchone()[0]
    
    print(json.dumps({
        "status": "success",
        "database": "connected",
        "version": version
    }))
except Exception as e:
    print(json.dumps({
        "status": "error",
        "error": str(e)
    }))
```

### Test Vector Operations (pgvector)

```python
import json
import sys
from sqlalchemy import create_engine, text

try:
    # Connect to database
    conn_str = "postgresql://n8n:n8n@postgres:5432/n8n"
    engine = create_engine(conn_str)
    
    with engine.connect() as conn:
        # Check if pgvector extension is installed
        result = conn.execute(text("SELECT * FROM pg_extension WHERE extname = 'vector'"))
        extension = result.fetchone()
        
        if extension:
            print(json.dumps({
                "status": "success",
                "pgvector": "installed",
                "message": "pgvector extension is available"
            }))
        else:
            print(json.dumps({
                "status": "warning",
                "pgvector": "not installed",
                "message": "pgvector extension not found"
            }))
except Exception as e:
    print(json.dumps({
        "status": "error",
        "error": str(e)
    }))
```

## 🐛 Troubleshooting

### Python Not Found
- Check: `docker compose exec n8n which python3`
- Should return: `/usr/bin/python3`

### Package Not Found
- Rebuild container: `docker compose build n8n`
- Restart: `docker compose restart n8n`

### Custom Nodes Not Showing
- Check Settings → Community Nodes
- Restart n8n: `docker compose restart n8n`
- Check logs: `docker compose logs n8n`

### Execute Command Not Working
- Ensure command is: `python3`
- Check arguments format
- Verify script syntax (valid Python)

## 📚 Next Steps

1. **Create Real Workflows**: Use Python packages in actual workflows
2. **Build Custom Nodes**: Create your own custom nodes
3. **Integrate APIs**: Use requests/openai for API integrations
4. **Data Processing**: Use pandas for data manipulation
5. **Web Scraping**: Use BeautifulSoup for web scraping tasks

## 🎉 Success Indicators

You'll know everything is working when:
- ✅ Python scripts execute successfully
- ✅ Packages import without errors
- ✅ LangChain nodes appear in node search
- ✅ Data flows through Python-executed nodes
- ✅ No import errors in workflow execution

Happy testing! 🚀

