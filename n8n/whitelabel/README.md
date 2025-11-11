# Whitelabeling Configuration

This directory contains files for customizing n8n's branding.

## Structure

```
whitelabel/
├── logos/              # Custom logo files
│   ├── favicon.ico
│   ├── favicon-16x16.png
│   ├── favicon-32x32.png
│   ├── logo.svg
│   ├── logo-collapsed.svg
│   └── logo-expanded.svg
├── styles/             # Custom CSS overrides
│   └── custom.css
├── config/             # Configuration files
│   ├── brand-config.json
│   └── i18n-overrides.json
└── scripts/            # Build scripts
    └── apply-whitelabel.sh
```

## Customization Options

### 1. Logos
Replace files in `logos/` directory:
- `favicon.ico` - Browser favicon
- `favicon-16x16.png` - 16x16 favicon
- `favicon-32x32.png` - 32x32 favicon
- `logo.svg` - Main logo
- `logo-collapsed.svg` - Sidebar collapsed logo
- `logo-expanded.svg` - Sidebar expanded logo

### 2. Colors
Edit `styles/custom.css` to override theme colors:
```css
:root {
    --color-primary: #0099ff;
    --color-primary-h: 204;
    --color-primary-s: 100%;
    --color-primary-l: 50%;
}
```

### 3. Brand Name
Edit `config/brand-config.json`:
```json
{
    "brandName": "My Brand",
    "brandTagline": "Workflow Automation",
    "windowTitle": "My Brand - Workflow Automation"
}
```

## Usage

1. Place your custom logos in `logos/` directory
2. Customize `styles/custom.css` for colors
3. Update `config/brand-config.json` for brand name
4. Rebuild Docker image: `docker compose build n8n`
5. Restart: `docker compose up -d n8n`

## Note

Full whitelabeling requires building n8n from source. This approach provides:
- Logo replacement
- CSS color overrides
- Basic branding via reverse proxy injection

For complete whitelabeling (including text changes), you'll need to:
1. Fork n8n repository
2. Modify source files
3. Build custom Docker image

See `_docs/WHITELABELING.md` for detailed instructions.

