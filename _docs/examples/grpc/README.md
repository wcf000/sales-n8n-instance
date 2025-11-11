# gRPC Examples

This directory contains example scripts and templates for using gRPC in n8n workflows.

## Files

- `grpc-client-example.py` - Generic gRPC client script for n8n
- `grpc-proto-example.proto` - Example Protocol Buffer definition
- `grpc-qdrant-example.py` - Example Qdrant gRPC integration

## Usage

### 1. Generate gRPC Stubs

For your own services, generate Python stubs from .proto files:

```bash
python -m grpc_tools.protoc \
  --python_out=. \
  --grpc_python_out=. \
  --proto_path=. \
  your_service.proto
```

### 2. Copy Stubs to n8n

Copy generated files to the shared directory:

```bash
# On host
cp your_service_pb2.py your_service_pb2_grpc.py ./shared/grpc/

# In n8n container, they'll be at /data/shared/grpc/
```

### 3. Use in n8n Workflow

1. Create workflow with Execute Command node
2. Set command: `python3`
3. Set arguments: `-c "$(cat /data/shared/grpc/your_script.py)"`
4. Or reference script directly if mounted

## Example Workflow

1. **Webhook Trigger** - Receive data
2. **Code Node** - Transform to gRPC request format
3. **Execute Command** - Run gRPC client script
4. **Code Node** - Process gRPC response
5. **Continue workflow** - Use response data

## Testing

Test gRPC connectivity:

```bash
docker compose exec n8n python3 -c "
import grpc
channel = grpc.insecure_channel('your-service:50051')
try:
    grpc.channel_ready_future(channel).result(timeout=5)
    print('✓ gRPC service reachable')
except:
    print('✗ Cannot connect')
"
```

