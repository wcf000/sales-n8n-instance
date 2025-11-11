#!/usr/bin/env python3
"""
OpenRouter Test Script
Tests OpenRouter API integration with Python
"""

import os
import json
import sys
from openai import OpenAI

def test_openrouter():
    """Test OpenRouter API connection and model access"""
    
    # Get API key from environment
    api_key = os.environ.get('OPENROUTER_API_KEY')
    
    if not api_key:
        result = {
            "success": False,
            "error": "OPENROUTER_API_KEY not set in environment",
            "hint": "Set OPENROUTER_API_KEY in .env or n8n environment variables"
        }
        print(json.dumps(result, indent=2))
        return False
    
    try:
        # Initialize OpenRouter client
        client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=api_key,
        )
        
        # Test with a simple model
        print("Testing OpenRouter connection...", file=sys.stderr)
        
        response = client.chat.completions.create(
            model="openai/gpt-3.5-turbo",  # Cheapest option for testing
            messages=[
                {"role": "user", "content": "Say 'OpenRouter test successful' and nothing else."}
            ],
            max_tokens=20
        )
        
        result = {
            "success": True,
            "model": response.model,
            "response": response.choices[0].message.content.strip(),
            "usage": {
                "prompt_tokens": response.usage.prompt_tokens,
                "completion_tokens": response.usage.completion_tokens,
                "total_tokens": response.usage.total_tokens
            },
            "message": "OpenRouter integration working correctly"
        }
        
        print(json.dumps(result, indent=2))
        return True
        
    except Exception as e:
        result = {
            "success": False,
            "error": str(e),
            "error_type": type(e).__name__,
            "message": "OpenRouter test failed"
        }
        print(json.dumps(result, indent=2))
        return False

if __name__ == "__main__":
    success = test_openrouter()
    sys.exit(0 if success else 1)

