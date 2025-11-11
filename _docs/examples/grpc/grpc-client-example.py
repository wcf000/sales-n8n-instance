#!/usr/bin/env python3
"""
Example gRPC Client Script for n8n
This script demonstrates how to make gRPC calls from n8n workflows
"""

import grpc
import sys
import json
import os

# Add shared directory to path for generated gRPC stubs
GRPC_STUBS_PATH = '/data/shared/grpc'
if os.path.exists(GRPC_STUBS_PATH):
    sys.path.insert(0, GRPC_STUBS_PATH)


def call_grpc_service(host, port, service_name, method_name, request_data, use_ssl=False, timeout=10.0):
    """
    Generic gRPC client function
    
    Args:
        host: gRPC service host
        port: gRPC service port
        service_name: Name of the service (for dynamic loading)
        method_name: Name of the method to call
        request_data: Dictionary with request parameters
        use_ssl: Whether to use SSL/TLS
        timeout: Request timeout in seconds
    
    Returns:
        Dictionary with response data
    """
    try:
        # Create channel
        if use_ssl:
            credentials = grpc.ssl_channel_credentials()
            channel = grpc.secure_channel(f'{host}:{port}', credentials)
        else:
            channel = grpc.insecure_channel(f'{host}:{port}')
        
        # Wait for channel to be ready
        grpc.channel_ready_future(channel).result(timeout=5.0)
        
        # In a real implementation, you would:
        # 1. Import generated stubs: from your_service_pb2_grpc import YourServiceStub
        # 2. Create stub: stub = YourServiceStub(channel)
        # 3. Create request: request = YourRequest(**request_data)
        # 4. Make call: response = stub.YourMethod(request, timeout=timeout)
        
        # For demonstration purposes:
        result = {
            "status": "success",
            "service": service_name,
            "method": method_name,
            "host": host,
            "port": port,
            "request": request_data,
            "message": "gRPC call would be made here with generated stubs"
        }
        
        channel.close()
        return result
        
    except grpc.RpcError as e:
        return {
            "status": "error",
            "error_code": e.code().name,
            "error_details": e.details(),
            "service": service_name,
            "method": method_name
        }
    except Exception as e:
        return {
            "status": "error",
            "error": str(e),
            "service": service_name,
            "method": method_name
        }


def main():
    """Main function - reads from stdin, writes to stdout"""
    try:
        # Read input from n8n (JSON from previous node)
        input_data = json.load(sys.stdin)
        
        # Extract parameters
        host = input_data.get("host", "localhost")
        port = input_data.get("port", 50051)
        service_name = input_data.get("service", "ExampleService")
        method_name = input_data.get("method", "GetData")
        request_data = input_data.get("data", {})
        use_ssl = input_data.get("use_ssl", False)
        timeout = input_data.get("timeout", 10.0)
        
        # Make gRPC call
        result = call_grpc_service(
            host=host,
            port=port,
            service_name=service_name,
            method_name=method_name,
            request_data=request_data,
            use_ssl=use_ssl,
            timeout=timeout
        )
        
        # Output JSON for n8n
        print(json.dumps(result, indent=2))
        
    except json.JSONDecodeError as e:
        error_result = {
            "status": "error",
            "error": "Invalid JSON input",
            "details": str(e)
        }
        print(json.dumps(error_result))
        sys.exit(1)
    except Exception as e:
        error_result = {
            "status": "error",
            "error": str(e)
        }
        print(json.dumps(error_result))
        sys.exit(1)


if __name__ == "__main__":
    main()

