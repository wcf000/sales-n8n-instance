# 🎯 Complete UI Guide: Building Workflows with LangChain & Python

## ✅ Great News! Your LangChain Nodes Are Working!

You're seeing:
- ✅ Basic LLM Chain
- ✅ Question and Answer Chain  
- ✅ Summarization Chain

This means your custom nodes are **already installed and working**! 🎉

---

## 📋 Step-by-Step: Build Your First LangChain Workflow

### **Step 1: Create New Workflow**
1. Go to http://localhost:5678
2. Click **"+"** button (top right) or **"Add workflow"**
3. You'll see an empty canvas with a **"Start"** node

---

### **Step 2: Add Chat Trigger**
1. Click the **"+"** button on the canvas
2. Search for: `Chat Trigger`
3. Click **"Chat Trigger"** to add it
4. **Connect**: Drag from **"Start"** → **"Chat Trigger"**

---

### **Step 3: Add LangChain Chain Node**
1. Click **"+"** again
2. Search for: `Basic LLM Chain` (or just `Chain`)
3. Click **"Basic LLM Chain"** to add it
4. **Connect**: Drag from **"Chat Trigger"** → **"Basic LLM Chain"**

---

### **Step 4: Add Chat Model (Ollama or OpenAI)**
1. Click **"+"** again
2. Search for: `Ollama Chat Model` (or `OpenAI Chat Model`)
3. Click to add it
4. **Connect**: Drag from **"Ollama Chat Model"** → **"Model"** input on **"Basic LLM Chain"**
   - This is the **diamond-shaped** input port below the chain node

---

### **Step 5: Configure Ollama Chat Model**
1. Click the **"Ollama Chat Model"** node
2. In the settings panel:
   - **Model**: Select `llama3.2` (or your preferred model)
   - **Base URL**: `http://ollama:11434` (if Ollama is running)
   - Or use **OpenAI** if you prefer

---

### **Step 6: Configure Basic LLM Chain**
1. Click the **"Basic LLM Chain"** node
2. In **"Prompt"** field, enter:
   ```
   You are a helpful assistant. Answer this question: {{ $json.question }}
   ```
3. The chain will use the question from the Chat Trigger

---

### **Step 7: Execute & Test!**
1. Click **"Execute Workflow"** (play button at top)
2. Type a question in the Chat Trigger
3. Watch it flow through the chain!
4. Check the output in the **"Basic LLM Chain"** node

---

## 🐍 Using Python Packages in Workflows

### **Method 1: Execute Command Node (Recommended)**

#### **Step 1: Add Execute Command Node**
1. Click **"+"** on canvas
2. Search: `Execute Command`
3. Add it to your workflow

#### **Step 2: Configure for Python**
1. Click the **"Execute Command"** node
2. **Command**: `python3`
3. **Arguments**: `-c`
4. **Stdin**: Paste your Python script

#### **Step 3: Example - Data Processing with Pandas**
Paste this in **Stdin**:
```python
import json
import sys
import pandas as pd

# Get input from previous node
input_data = json.load(sys.stdin)

# Process with Pandas
if isinstance(input_data, list) and len(input_data) > 0:
    data = input_data[0].get('json', {})
else:
    data = input_data.get('json', {}) if isinstance(input_data, dict) else {}

# Create DataFrame
df = pd.DataFrame([data] if isinstance(data, dict) else data)

# Calculate stats
result = {
    'processed': True,
    'rows': len(df),
    'columns': list(df.columns) if hasattr(df, 'columns') else [],
    'message': 'Pandas processed the data!'
}

print(json.dumps(result))
```

#### **Step 4: Connect & Execute**
1. Connect previous node → **Execute Command**
2. Click **"Execute Workflow"**
3. Check output - you'll see Pandas results!

---

## 🔗 Complete Example: LangChain + Python Workflow

### **Workflow Structure:**
```
[Start]
  ↓
[Chat Trigger] ← User asks question
  ↓
[Execute Command] ← Python processes question
  ↓
[Basic LLM Chain] ← LangChain generates answer
  ↓
[Set] ← Format output
```

### **Step-by-Step Build:**

1. **Start** (already there)

2. **Chat Trigger**
   - Add node, search "Chat Trigger"
   - Connect Start → Chat Trigger

3. **Execute Command** (Python preprocessing)
   - Add "Execute Command"
   - Command: `python3`
   - Arguments: `-c`
   - Stdin:
   ```python
   import json
   import sys
   
   data = json.load(sys.stdin)
   question = data.get('json', {}).get('question', '')
   
   # Preprocess with Python
   processed = {
       'question': question.upper(),  # Example: uppercase
       'length': len(question),
       'words': len(question.split())
   }
   
   print(json.dumps(processed))
   ```
   - Connect: Chat Trigger → Execute Command

4. **Ollama Chat Model**
   - Add "Ollama Chat Model"
   - Model: `llama3.2`
   - Base URL: `http://ollama:11434`

5. **Basic LLM Chain**
   - Add "Basic LLM Chain"
   - Prompt: `Answer this: {{ $json.question }}`
   - Connect: Execute Command → Basic LLM Chain
   - Connect: Ollama Chat Model → Model input (diamond port)

6. **Set Node** (format output)
   - Add "Set"
   - Add Value:
     - Name: `answer`
     - Value: `{{ $json.text }}`
   - Connect: Basic LLM Chain → Set

7. **Execute!**
   - Click "Execute Workflow"
   - Type a question
   - See the magic happen! ✨

---

## 🎨 Visual Guide: Node Connections

### **LangChain Chain Connection:**
```
[Chat Model] 
     ↓ (dashed line to diamond port)
[Basic LLM Chain] ← Model input (diamond shape)
     ↑ (solid line from main input)
[Chat Trigger]
```

### **Python + LangChain:**
```
[Chat Trigger]
     ↓
[Execute Command] ← Python script
     ↓
[Basic LLM Chain] ← Uses Python output
     ↑ (diamond connection)
[Ollama Chat Model]
```

---

## 💡 Quick Tips

1. **Diamond Ports** = Model/Resource inputs (connect Chat Model here)
2. **Circle Ports** = Data flow (connect nodes here)
3. **Search Nodes**: Press `+` then type to search
4. **Test Individual Nodes**: Click node → "Execute Node"
5. **View Data**: Click node after execution to see output

---

## 🧪 Test Scripts to Copy/Paste

### **Simple Python Test:**
```python
import json
import pandas as pd
result = {'status': 'success', 'pandas': pd.__version__}
print(json.dumps(result))
```

### **HTTP Request Test:**
```python
import json
import requests
response = requests.get('https://httpbin.org/json', timeout=5)
print(json.dumps({'status': response.status_code, 'data': response.json()}))
```

### **Data Processing:**
```python
import json
import pandas as pd

data = {'name': ['Alice', 'Bob'], 'age': [25, 30]}
df = pd.DataFrame(data)
print(json.dumps({'rows': len(df), 'avg_age': float(df['age'].mean())}))
```

---

## ✅ What You Should See

- ✅ LangChain nodes appear when searching
- ✅ Python scripts execute successfully
- ✅ Data flows between nodes
- ✅ Output shows in node panels
- ✅ No errors in execution

---

## 🚀 Next Steps

1. **Build your workflow** using the steps above
2. **Test each node** individually
3. **Connect nodes** to create data flow
4. **Execute** and see results!
5. **Save** your workflow

**You're all set! Start building! 🎉**

