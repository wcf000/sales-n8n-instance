# Python Execution Environment

## Overview

The n8n platform includes a Python 3.11+ execution environment with a curated set of packages, enabling powerful data processing, AI integration, and custom scripting capabilities within workflows.

## Python Installation

Python is installed in the n8n Docker container via a custom Dockerfile that:
1. Extends the official n8n image
2. Installs Python 3.11+ and pip
3. Installs system dependencies
4. Installs Python packages from `requirements.txt`

## Available Python Packages

### Core Packages

- **pandas** (^2.0.0): Data manipulation and analysis
- **numpy** (^1.24.0): Numerical computing
- **requests** (^2.31.0): HTTP library for API calls

### AI & Machine Learning

- **openai** (^1.0.0): OpenAI API client (compatible with OpenRouter)
- **anthropic** (^0.34.0): Anthropic Claude API client
- **langchain** (^0.1.0): LLM application framework (optional)

### Web Scraping

- **beautifulsoup4** (^4.12.0): HTML/XML parsing
- **lxml** (^5.0.0): XML/HTML processing

### Database

- **SQLAlchemy** (^2.0.0): SQL toolkit and ORM
- **psycopg2-binary** (^2.9.0): PostgreSQL adapter

### Cloud Services

- **boto3** (^1.34.0): AWS SDK
- **azure-storage-blob** (^12.0.0): Azure storage (optional)
- **google-cloud-storage** (^2.0.0): GCP storage (optional)

## Using Python in n8n

### Execute Command Node

The primary way to run Python scripts is via the **Execute Command** node:

1. Add "Execute Command" node to workflow
2. Set command to: `python3`
3. Set arguments or use stdin for script input
4. Capture output via node output

### Example: Simple Python Script

```python
import json
import sys

# Read input from stdin (n8n data)
data = json.load(sys.stdin)

# Process data
result = {
    "processed": len(data),
    "message": "Data processed successfully"
}

# Output JSON for n8n
print(json.dumps(result))
```

### Example: Using Pandas

```python
import pandas as pd
import json
import sys

# Read input data
input_data = json.load(sys.stdin)

# Create DataFrame
df = pd.DataFrame(input_data)

# Process data
summary = {
    "rows": len(df),
    "columns": list(df.columns),
    "summary_stats": df.describe().to_dict()
}

# Output result
print(json.dumps(summary, default=str))
```

### Example: API Call with Requests

```python
import requests
import json
import sys

# Read input from n8n
data = json.load(sys.stdin)
url = data.get("url")

# Make API call
response = requests.get(url)
result = {
    "status_code": response.status_code,
    "data": response.json() if response.headers.get("content-type") == "application/json" else response.text
}

print(json.dumps(result))
```

## Adding New Packages

### Method 1: Update requirements.txt

1. Edit `n8n/requirements.txt`
2. Add package with version: `package-name==version`
3. Rebuild Docker image:

```bash
docker compose build n8n
docker compose up -d n8n
```

### Method 2: Install at Runtime (Not Recommended)

You can install packages at runtime, but they will be lost on container restart:

```bash
docker compose exec n8n pip install package-name
```

**Note**: Always update `requirements.txt` and rebuild for persistence.

## Python Version

Current version: **Python 3.11+**

Check version in container:
```bash
docker compose exec n8n python3 --version
```

## Environment Variables

Python scripts have access to n8n environment variables:

- `N8N_USER_FOLDER`: n8n data directory
- `N8N_ENCRYPTION_KEY`: Encryption key (use carefully)
- Database connection variables (if needed)

Access in Python:
```python
import os
n8n_folder = os.environ.get('N8N_USER_FOLDER', '/home/node/.n8n')
```

## File System Access

Python scripts can access the shared folder:

- **Path in container**: `/data/shared`
- **Path on host**: `./shared` (relative to project root)

Example:
```python
import os
shared_path = "/data/shared"
file_path = os.path.join(shared_path, "data.csv")

# Read file
with open(file_path, 'r') as f:
    data = f.read()
```

## Best Practices

### 1. Error Handling

Always include error handling:

```python
import json
import sys

try:
    data = json.load(sys.stdin)
    # Process data
    result = {"status": "success", "data": data}
except Exception as e:
    result = {"status": "error", "message": str(e)}

print(json.dumps(result))
```

### 2. Input/Output Format

- Use JSON for input/output
- Read from `stdin` for n8n data
- Write to `stdout` for n8n output
- Use `stderr` for error messages

### 3. Resource Management

- Close file handles
- Use context managers (`with` statements)
- Clean up temporary files

### 4. Performance

- Use pandas for large datasets
- Cache API responses when possible
- Use generators for large data processing

### 5. Security

- Never expose secrets in scripts
- Validate all inputs
- Sanitize file paths
- Use parameterized queries for databases

## Validation

### Test Python Installation

Run validation script:
```bash
./_debug/validate-python.sh
```

### Manual Testing

1. Create workflow with Execute Command node
2. Test Python version:
   - Command: `python3`
   - Arguments: `--version`
3. Test package import:
   - Command: `python3`
   - Arguments: `-c "import pandas; print('OK')"`

## Troubleshooting

### Python Not Found

1. Verify Dockerfile built correctly
2. Check container: `docker compose exec n8n which python3`
3. Rebuild image: `docker compose build n8n`

### Package Import Errors

1. Check package in requirements.txt
2. Verify installation: `docker compose exec n8n pip list`
3. Rebuild image with updated requirements.txt

### Permission Errors

1. Check file permissions in shared folder
2. Verify user permissions in container
3. Check volume mount configuration

### Memory Issues

1. Increase Docker memory limit
2. Optimize Python scripts
3. Use streaming for large datasets

## Example Workflows

See `_debug/test-python-execution.json` for example workflows demonstrating:
- Basic Python execution
- Pandas data processing
- API calls with requests
- File operations

## OpenRouter Integration

OpenRouter provides unified access to 100+ LLM models. See `_docs/openrouter-integration.md` for complete guide.

### Quick Example

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ.get('OPENROUTER_API_KEY')
)

response = client.chat.completions.create(
    model="anthropic/claude-3.5-sonnet",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

## Additional Resources

- [Python Documentation](https://docs.python.org/3/)
- [Pandas Documentation](https://pandas.pydata.org/)
- [OpenRouter Integration Guide](../openrouter-integration.md)
- [n8n Execute Command Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.executecommand/)

