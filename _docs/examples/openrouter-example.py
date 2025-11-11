"""
OpenRouter Example Script for n8n Execute Command Node
This script demonstrates how to use OpenRouter API in n8n workflows
"""

import os
import json
import sys
from openai import OpenAI

def main():
    # Get API key from environment (set in n8n or .env)
    api_key = os.environ.get('OPENROUTER_API_KEY')
    
    if not api_key:
        result = {
            "success": False,
            "error": "OPENROUTER_API_KEY not set",
            "hint": "Set OPENROUTER_API_KEY in .env file or n8n environment variables"
        }
        print(json.dumps(result))
        return
    
    # Read input from previous n8n node (optional)
    try:
        input_data = json.load(sys.stdin)
        user_query = input_data.get('query', 'Hello, how are you?')
    except:
        user_query = 'Hello, how are you?'
    
    try:
        # Initialize OpenRouter client
        client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=api_key,
        )
        
        # Make API call to OpenRouter
        # You can use any model from: https://openrouter.ai/models
        response = client.chat.completions.create(
            model="anthropic/claude-3.5-sonnet",  # Or "openai/gpt-4o", "google/gemini-pro-1.5", etc.
            messages=[
                {"role": "user", "content": user_query}
            ],
            max_tokens=500,
            extra_headers={
                "HTTP-Referer": "https://n8n.workflow",  # Optional: for analytics
                "X-Title": "n8n Workflow",  # Optional: for analytics
            }
        )
        
        # Format result for n8n
        result = {
            "success": True,
            "query": user_query,
            "model": response.model,
            "response": response.choices[0].message.content,
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            }
        }
        
        print(json.dumps(result))
        
    except Exception as e:
        result = {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__
        }
        print(json.dumps(result))
        sys.exit(1)

if __name__ == "__main__":
    main()

