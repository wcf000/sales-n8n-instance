# Custom Node Template

This is a template for creating custom n8n nodes.

## Structure

```
.
├── nodes/
│   └── ExampleNode/
│       └── ExampleNode.node.ts
├── package.json
├── tsconfig.json
└── README.md
```

## Development

### Install Dependencies

```bash
npm install
```

### Build

```bash
npm run build
```

### Publish

```bash
npm publish
```

## Usage

1. Build the package
2. Publish to NPM (public or private registry)
3. Install in n8n via `community-nodes.json` or environment variable
4. Restart n8n
5. Node will appear in n8n node palette

## Customization

1. Rename `ExampleNode` to your node name
2. Update `package.json` with your details
3. Modify node implementation in `ExampleNode.node.ts`
4. Update node properties and operations as needed

## Documentation

See `_docs/custom-nodes.md` for detailed development guide.

