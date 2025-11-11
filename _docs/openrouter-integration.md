# OpenRouter Integration Guide

## Overview

OpenRouter provides unified access to multiple LLM providers (OpenAI, Anthropic, Google, Meta, etc.) through a single API. This guide shows how to use OpenRouter with the Python execution layer in n8n.

## Why OpenRouter?

- **Unified API**: Access 100+ models from different providers
- **Cost Optimization**: Compare pricing across providers
- **Fallback Support**: Automatic failover between models
- **Rate Limit Management**: Built-in rate limiting and queuing

## Setup

### 1. Get OpenRouter API Key

1. Sign up at [OpenRouter.ai](https://openrouter.ai/)
2. Create an API key in your dashboard
3. Add credits to your account

### 2. Configure Environment Variable

Add to your `.env` file:

```bash
OPENROUTER_API_KEY=sk-or-v1-your-api-key-here
```

Or set it in n8n workflow credentials.

## Using OpenRouter in Python Scripts

### Basic Example with OpenAI SDK

OpenRouter is compatible with the OpenAI SDK. Just change the base URL:

```python
import os
import json
import sys
from openai import OpenAI

# Get API key from environment or n8n input
api_key = os.environ.get('OPENROUTER_API_KEY', 'your-key-here')

# Initialize OpenAI client with OpenRouter endpoint
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=api_key,
)

# Make a chat completion request
response = client.chat.completions.create(
    model="anthropic/claude-3.5-sonnet",  # Or any OpenRouter model
    messages=[
        {"role": "user", "content": "Hello! Explain what OpenRouter is."}
    ],
    extra_headers={
        "HTTP-Referer": "https://your-app.com",  # Optional: for analytics
        "X-Title": "n8n Workflow",  # Optional: for analytics
    }
)

result = {
    "model": response.model,
    "message": response.choices[0].message.content,
    "usage": {
        "prompt_tokens": response.usage.prompt_tokens,
        "completion_tokens": response.usage.completion_tokens,
        "total_tokens": response.usage.total_tokens
    }
}

print(json.dumps(result))
```

### Using Requests Library

For more control, use the requests library directly:

```python
import os
import json
import sys
import requests

# Get API key
api_key = os.environ.get('OPENROUTER_API_KEY', 'your-key-here')

# OpenRouter API endpoint
url = "https://openrouter.ai/api/v1/chat/completions"

headers = {
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json",
    "HTTP-Referer": "https://your-app.com",  # Optional
    "X-Title": "n8n Workflow",  # Optional
}

data = {
    "model": "openai/gpt-4o",  # Or any OpenRouter model
    "messages": [
        {"role": "user", "content": "What is 2+2?"}
    ]
}

response = requests.post(url, headers=headers, json=data)
result = response.json()

print(json.dumps(result))
```

### Advanced: Model Selection with Fallback

```python
import os
import json
import sys
from openai import OpenAI

api_key = os.environ.get('OPENROUTER_API_KEY', 'your-key-here')
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=api_key,
)

# Try primary model, fallback to secondary
models = [
    "anthropic/claude-3.5-sonnet",
    "openai/gpt-4o",
    "google/gemini-pro-1.5"
]

user_message = "Explain quantum computing in simple terms."

for model in models:
    try:
        response = client.chat.completions.create(
            model=model,
            messages=[{"role": "user", "content": user_message}],
            max_tokens=500
        )
        
        result = {
            "success": True,
            "model_used": model,
            "response": response.choices[0].message.content,
            "tokens": response.usage.total_tokens
        }
        print(json.dumps(result))
        break
    except Exception as e:
        if model == models[-1]:  # Last model failed
            result = {
                "success": False,
                "error": str(e)
            }
            print(json.dumps(result))
        continue
```

## Available Models

OpenRouter provides access to models from multiple providers:

### OpenAI Models
- `openai/gpt-4o`
- `openai/gpt-4-turbo`
- `openai/gpt-3.5-turbo`

### Anthropic Models
- `anthropic/claude-3.5-sonnet`
- `anthropic/claude-3-opus`
- `anthropic/claude-3-haiku`

### Google Models
- `google/gemini-pro-1.5`
- `google/gemini-flash-1.5`

### Meta Models
- `meta-llama/llama-3.1-70b-instruct`
- `meta-llama/llama-3.1-8b-instruct`

### Other Providers
- `mistralai/mistral-large`
- `perplexity/llama-3.1-sonar-large-128k-online`
- And 100+ more...

See full list: [OpenRouter Models](https://openrouter.ai/models)

## Using in n8n Execute Command Node

### Example 1: Simple Chat Completion

1. Add "Execute Command" node
2. Set command: `python3`
3. Set arguments:
```python
-c "import os, json; from openai import OpenAI; client = OpenAI(base_url='https://openrouter.ai/api/v1', api_key=os.environ.get('OPENROUTER_API_KEY')); response = client.chat.completions.create(model='anthropic/claude-3.5-sonnet', messages=[{'role': 'user', 'content': 'Hello!'}]); print(json.dumps({'response': response.choices[0].message.content}))"
```

### Example 2: With Input from Previous Node

```python
import os
import json
import sys
from openai import OpenAI

# Read input from n8n
input_data = json.load(sys.stdin)
user_query = input_data.get('query', 'Default question')

# Initialize OpenRouter client
client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ.get('OPENROUTER_API_KEY')
)

# Make request
response = client.chat.completions.create(
    model="openai/gpt-4o",
    messages=[{"role": "user", "content": user_query}]
)

# Output for n8n
result = {
    "query": user_query,
    "response": response.choices[0].message.content,
    "model": response.model,
    "tokens": response.usage.total_tokens
}

print(json.dumps(result))
```

## Environment Variables

### Setting in n8n

1. Go to Settings → Environment Variables
2. Add: `OPENROUTER_API_KEY` = `sk-or-v1-...`
3. Use in Python scripts: `os.environ.get('OPENROUTER_API_KEY')`

### Setting in Docker Compose

Add to `docker-compose.yml`:

```yaml
environment:
  - OPENROUTER_API_KEY=${OPENROUTER_API_KEY}
```

And in `.env`:
```bash
OPENROUTER_API_KEY=sk-or-v1-your-key-here
```

## Cost Optimization

### Check Model Pricing

```python
import requests

url = "https://openrouter.ai/api/v1/models"
response = requests.get(url)
models = response.json()

# Find cheapest model for your use case
for model in models['data']:
    if 'pricing' in model:
        print(f"{model['id']}: ${model['pricing']['prompt']}/1M tokens")
```

### Use Streaming for Long Responses

```python
from openai import OpenAI

client = OpenAI(
    base_url="https://openrouter.ai/api/v1",
    api_key=os.environ.get('OPENROUTER_API_KEY')
)

stream = client.chat.completions.create(
    model="anthropic/claude-3.5-sonnet",
    messages=[{"role": "user", "content": "Write a long story"}],
    stream=True
)

for chunk in stream:
    if chunk.choices[0].delta.content:
        print(chunk.choices[0].delta.content, end='', flush=True)
```

## Error Handling

```python
import os
import json
import sys
from openai import OpenAI
from openai import APIError, RateLimitError

try:
    client = OpenAI(
        base_url="https://openrouter.ai/api/v1",
        api_key=os.environ.get('OPENROUTER_API_KEY')
    )
    
    response = client.chat.completions.create(
        model="anthropic/claude-3.5-sonnet",
        messages=[{"role": "user", "content": "Hello"}]
    )
    
    result = {"success": True, "response": response.choices[0].message.content}
    
except RateLimitError as e:
    result = {"success": False, "error": "Rate limit exceeded", "details": str(e)}
except APIError as e:
    result = {"success": False, "error": "API error", "details": str(e)}
except Exception as e:
    result = {"success": False, "error": "Unexpected error", "details": str(e)}

print(json.dumps(result))
```

## Best Practices

1. **Use Environment Variables**: Never hardcode API keys
2. **Set HTTP-Referer**: Helps with analytics and support
3. **Handle Rate Limits**: Implement retry logic with exponential backoff
4. **Monitor Costs**: Check OpenRouter dashboard regularly
5. **Use Appropriate Models**: Choose models based on task complexity
6. **Cache Responses**: Cache common queries to reduce costs

## Example Workflows

### Workflow 1: AI-Powered Data Analysis

1. Read data from previous node
2. Execute Python script with OpenRouter:
   - Send data summary to LLM
   - Get insights and recommendations
   - Return structured JSON

### Workflow 2: Multi-Model Comparison

1. Send same prompt to multiple models
2. Compare responses
3. Select best response based on criteria

### Workflow 3: Cost-Optimized Chatbot

1. Try cheaper model first (e.g., `gpt-3.5-turbo`)
2. If confidence low, upgrade to better model
3. Return response with model used

## Resources

- [OpenRouter Documentation](https://openrouter.ai/docs)
- [OpenRouter Models](https://openrouter.ai/models)
- [OpenRouter Pricing](https://openrouter.ai/models?order=price)
- [OpenRouter API Reference](https://openrouter.ai/docs/api-reference)

## Troubleshooting

### API Key Not Working

- Verify key format: `sk-or-v1-...`
- Check key has credits/balance
- Verify key is set in environment

### Rate Limit Errors

- Implement exponential backoff
- Use queue system for high volume
- Consider upgrading OpenRouter plan

### Model Not Available

- Check model ID spelling
- Verify model is available on OpenRouter
- Try alternative model from same provider

