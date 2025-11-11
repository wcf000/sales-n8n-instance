# Custom Nodes Development Guide

## Overview

This guide explains how to develop, build, and deploy custom n8n nodes. Custom nodes extend n8n's capabilities with domain-specific functionality.

## Architecture

Custom nodes are distributed as NPM packages that n8n can install and load at runtime. The recommended approach is to maintain custom nodes in a separate repository.

## Development Setup

### 1. Create Node Package

Initialize a new NPM package:

```bash
mkdir n8n-custom-nodes
cd n8n-custom-nodes
npm init -y
```

### 2. Install Dependencies

```bash
npm install --save-dev \
  @types/node \
  typescript \
  ts-node \
  n8n-workflow \
  n8n-nodes-base
```

### 3. Project Structure

```
n8n-custom-nodes/
├── nodes/
│   └── MyCustomNode/
│       ├── MyCustomNode.node.ts
│       └── MyCustomNode.node.json
├── package.json
├── tsconfig.json
└── README.md
```

### 4. Basic Node Template

See `_docs/examples/custom-node-template/` for a complete example.

## Node Implementation

### TypeScript Node File

Create `nodes/MyCustomNode/MyCustomNode.node.ts`:

```typescript
import {
  IExecuteFunctions,
  INodeExecutionData,
  INodeType,
  INodeTypeDescription,
  NodePropertyTypes,
} from 'n8n-workflow';

export class MyCustomNode implements INodeType {
  description: INodeTypeDescription = {
    displayName: 'My Custom Node',
    name: 'myCustomNode',
    icon: 'file:myCustomNode.svg',
    group: ['transform'],
    version: 1,
    description: 'Custom node description',
    defaults: {
      name: 'My Custom Node',
    },
    inputs: ['main'],
    outputs: ['main'],
    properties: [
      {
        displayName: 'Operation',
        name: 'operation',
        type: 'options',
        options: [
          {
            name: 'Process Data',
            value: 'process',
          },
        ],
        default: 'process',
        description: 'Operation to perform',
      },
      {
        displayName: 'Input Field',
        name: 'inputField',
        type: 'string',
        default: '',
        description: 'Input field name',
      },
    ],
  };

  async execute(this: IExecuteFunctions): Promise<INodeExecutionData[][]> {
    const items = this.getInputData();
    const returnData: INodeExecutionData[] = [];

    for (let i = 0; i < items.length; i++) {
      const operation = this.getNodeParameter('operation', i) as string;
      const inputField = this.getNodeParameter('inputField', i) as string;

      if (operation === 'process') {
        const inputData = items[i].json[inputField];
        
        // Process data
        const processedData = {
          original: inputData,
          processed: `Processed: ${inputData}`,
          timestamp: new Date().toISOString(),
        };

        returnData.push({
          json: processedData,
        });
      }
    }

    return [returnData];
  }
}
```

### Node Description JSON

Create `nodes/MyCustomNode/MyCustomNode.node.json`:

```json
{
  "node": {
    "version": 1,
    "name": "myCustomNode",
    "displayName": "My Custom Node",
    "description": "Custom node description",
    "defaults": {
      "name": "My Custom Node"
    },
    "inputs": ["main"],
    "outputs": ["main"],
    "properties": [
      {
        "displayName": "Operation",
        "name": "operation",
        "type": "options",
        "options": [
          {
            "name": "Process Data",
            "value": "process"
          }
        ],
        "default": "process"
      }
    ]
  }
}
```

### Package.json Configuration

Update `package.json`:

```json
{
  "name": "@yourorg/n8n-custom-nodes",
  "version": "1.0.0",
  "description": "Custom n8n nodes",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "n8n": {
    "n8nNodesApiVersion": 1,
    "nodes": [
      "dist/nodes/MyCustomNode/MyCustomNode.node.js"
    ]
  },
  "scripts": {
    "build": "tsc",
    "prepublishOnly": "npm run build"
  },
  "keywords": ["n8n", "n8n-node"],
  "author": "Your Name",
  "license": "MIT"
}
```

### TypeScript Configuration

Create `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "declaration": true,
    "outDir": "./dist",
    "rootDir": "./",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["nodes/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Building

### Compile TypeScript

```bash
npm run build
```

This creates the `dist/` directory with compiled JavaScript.

## Publishing

### Option 1: Public NPM Registry

1. Create NPM account
2. Login: `npm login`
3. Publish: `npm publish --access public`

### Option 2: Private NPM Registry

1. Set up private registry (Verdaccio, npm Enterprise, etc.)
2. Configure `.npmrc`:
   ```
   @yourorg:registry=https://your-registry.com/
   //your-registry.com/:_authToken=YOUR_TOKEN
   ```
3. Publish: `npm publish`

### Option 3: GitHub Packages

1. Configure `.npmrc`:
   ```
   @yourorg:registry=https://npm.pkg.github.com
   //npm.pkg.github.com/:_authToken=YOUR_TOKEN
   ```
2. Update `package.json`:
   ```json
   {
     "publishConfig": {
       "registry": "https://npm.pkg.github.com"
     }
   }
   ```
3. Publish: `npm publish`

## Installation in n8n

### Method 1: Community Nodes Configuration

1. Add package to `n8n/community-nodes.json`:
   ```json
   {
     "packages": [
       {
         "name": "@yourorg/n8n-custom-nodes",
         "version": "1.0.0"
       }
     ]
   }
   ```

2. Restart n8n:
   ```bash
   docker compose restart n8n
   ```

### Method 2: Environment Variable

Set in `.env`:
```
N8N_COMMUNITY_NODES_INCLUDE=@yourorg/n8n-custom-nodes@1.0.0
```

### Method 3: Manual Installation

```bash
docker compose exec n8n npm install @yourorg/n8n-custom-nodes@1.0.0
docker compose restart n8n
```

## Testing

### Local Testing

1. Link package locally:
   ```bash
   npm link
   ```

2. In n8n container, link package:
   ```bash
   docker compose exec n8n npm link @yourorg/n8n-custom-nodes
   ```

3. Restart n8n and test node

### Unit Testing

Create test files using Jest or similar:

```typescript
import { MyCustomNode } from './MyCustomNode.node';

describe('MyCustomNode', () => {
  it('should process data correctly', () => {
    // Test implementation
  });
});
```

## Best Practices

### 1. Versioning

- Use semantic versioning
- Increment version for each release
- Tag releases in Git

### 2. Documentation

- Include README with usage examples
- Document all node properties
- Provide example workflows

### 3. Error Handling

- Validate inputs
- Provide clear error messages
- Handle edge cases

### 4. Performance

- Optimize for large datasets
- Use streaming when possible
- Cache expensive operations

### 5. Security

- Validate all inputs
- Sanitize user data
- Never expose secrets

## Example Template

See `_docs/examples/custom-node-template/` for a complete working example including:
- Node implementation
- Package configuration
- Build scripts
- Documentation

## Troubleshooting

### Node Not Appearing

1. Check package name in `community-nodes.json`
2. Verify package is published
3. Check n8n logs: `docker compose logs n8n`
4. Verify node registration in package.json

### Build Errors

1. Check TypeScript configuration
2. Verify all dependencies installed
3. Check node compatibility with n8n version

### Runtime Errors

1. Check n8n logs for errors
2. Verify node implementation
3. Test with simple workflow first

## Resources

- [n8n Node Development Documentation](https://docs.n8n.io/integrations/creating-nodes/)
- [n8n Workflow Types](https://github.com/n8n-io/n8n/tree/master/packages/workflow)
- [n8n Community Nodes Examples](https://github.com/n8n-io/n8n-nodes-langchain)

