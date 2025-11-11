# 🚀 Quick Test Guide: Custom Nodes & Python Packages

## ✅ Verification Complete!

All packages are installed and working:
- ✅ **pandas** 2.3.3
- ✅ **numpy** 1.26.4
- ✅ **requests** 2.32.5
- ✅ **openai** 1.109.1
- ✅ **beautifulsoup4** 4.14.2
- ✅ **boto3** 1.40.70
- ✅ **sqlalchemy** (installed)
- ✅ **Python 3.12.12** available

## 🎯 Quick Test Steps

### Option 1: Import Test Workflow (Easiest!)

1. **Go to n8n**: http://localhost:5678
2. **Click "Workflows"** → **"Import from File"**
3. **Select**: `_debug/test-python-packages-workflow.json`
4. **Click "Execute Workflow"**
5. **Check results** - All packages should show as installed!

### Option 2: Manual Test in n8n UI

1. **Create New Workflow** in n8n
2. **Add "Execute Command" node**
3. **Set Command**: `python3`
4. **Set Arguments**: `-c`
5. **Paste this test script**:

```python
import json
import pandas as pd
import numpy as np
import requests

# Quick test
result = {
    "pandas": pd.__version__,
    "numpy": np.__version__,
    "requests": requests.__version__,
    "status": "All packages working! ✅"
}

print(json.dumps(result))
```

6. **Execute** and check output!

### Option 3: Test Custom Nodes (LangChain)

1. **In n8n UI**, click **"+"** to add node
2. **Search for**: `LangChain`
3. **You should see**:
   - LangChain Chat Model
   - LangChain Chain
   - LangChain Memory
   - LangChain Tool

4. **Add a LangChain node** and configure it!

## 📋 Test Checklist

- [ ] Python packages import successfully
- [ ] Pandas can create DataFrames
- [ ] Requests can make HTTP calls
- [ ] OpenAI SDK is available
- [ ] LangChain nodes appear in node search
- [ ] Execute Command node runs Python scripts

## 🎉 Success!

If all tests pass, you're ready to:
- Use Python in workflows
- Process data with Pandas
- Make API calls with Requests
- Use LangChain for AI workflows
- Build custom automation workflows

## 📚 Full Documentation

See `_docs/TESTING_CUSTOM_NODES_AND_PACKAGES.md` for:
- Detailed test examples
- Advanced testing scenarios
- Database connection tests
- Troubleshooting guide

Happy automating! 🚀

