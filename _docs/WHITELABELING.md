# Whitelabeling n8n - Complete Guide

This guide explains how to customize n8n's branding for your organization.

## 📋 Overview

Whitelabeling allows you to:
- ✅ Replace logos (favicon, sidebar logos)
- ✅ Customize theme colors
- ✅ Change brand name in UI (requires source build)
- ✅ Customize window title

## 🎨 Quick Start (Docker Method)

### Step 1: Prepare Your Assets

1. **Create custom logos** and place them in `n8n/whitelabel/logos/`:
   - `favicon.ico` (16x16, 32x32, 48x48)
   - `favicon-16x16.png`
   - `favicon-32x32.png`
   - `logo.svg` (main logo)
   - `logo-collapsed.svg` (sidebar collapsed, ~40px height)
   - `logo-expanded.svg` (sidebar expanded, ~40px height)

2. **Customize colors** in `n8n/whitelabel/styles/custom.css`:
   ```css
   :root {
       --color-primary-h: 204;  /* Hue (0-360) */
       --color-primary-s: 100%;  /* Saturation */
       --color-primary-l: 50%;   /* Lightness */
   }
   ```

3. **Update brand config** in `n8n/whitelabel/config/brand-config.json`:
   ```json
   {
       "brandName": "Your Brand",
       "brandTagline": "Your Tagline",
       "windowTitle": "Your Brand - Workflow Automation"
   }
   ```

### Step 2: Rebuild and Deploy

```bash
# Rebuild the Docker image
docker compose build n8n

# Restart the container
docker compose up -d n8n
```

### Step 3: Verify

1. Open http://localhost:5678
2. Check that your logos appear
3. Verify colors match your brand
4. Check browser tab for custom favicon

## 🎨 Customization Options

### 1. Logo Replacement

**File Locations:**
- `n8n/whitelabel/logos/favicon.ico`
- `n8n/whitelabel/logos/favicon-16x16.png`
- `n8n/whitelabel/logos/favicon-32x32.png`
- `n8n/whitelabel/logos/logo.svg`
- `n8n/whitelabel/logos/logo-collapsed.svg`
- `n8n/whitelabel/logos/logo-expanded.svg`

**Logo Specifications:**
- **Favicon**: 16x16, 32x32, 48x48 (ICO format)
- **Sidebar logos**: ~40px height, SVG format recommended
- **Format**: SVG (preferred) or PNG with transparency

### 2. Color Customization

Edit `n8n/whitelabel/styles/custom.css`:

```css
/* Primary Brand Color */
:root {
    --color-primary-h: 204;  /* Blue: 204, Red: 0, Green: 120 */
    --color-primary-s: 100%;  /* 0-100% */
    --color-primary-l: 50%;   /* 0-100% */
}

/* Dark Theme */
[data-theme="dark"] {
    --color-primary-h: 204;
    --color-primary-s: 100%;
    --color-primary-l: 50%;
}

/* Light Theme */
[data-theme="light"] {
    --color-primary-h: 204;
    --color-primary-s: 100%;
    --color-primary-l: 50%;
}
```

**Color Converter:**
- Use online tools like [HSL Color Picker](https://hslpicker.com/) to convert hex to HSL
- Example: `#0099ff` = HSL(204, 100%, 50%)

### 3. Brand Name (Advanced - Requires Source Build)

For complete text replacement, you need to build n8n from source:

1. **Fork n8n repository**: https://github.com/n8n-io/n8n
2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-org/n8n.git
   cd n8n
   ```

3. **Modify localization**:
   - Edit `packages/frontend/@n8n/i18n/src/locales/en.json`
   - Replace "n8n" with your brand name

4. **Modify window title**:
   - Edit `packages/frontend/editor-ui/index.html`
   - Edit `packages/frontend/editor-ui/src/composables/useDocumentTitle.ts`

5. **Build and create custom Docker image**:
   ```bash
   npm install
   npm run build
   # Create Dockerfile based on n8n's official Dockerfile
   ```

## 🔧 Advanced: Reverse Proxy CSS Injection

For runtime CSS injection without rebuilding:

### Using Traefik (Already Configured)

1. Create custom CSS file in `traefik/custom/whitelabel.css`
2. Configure Traefik to inject CSS via middleware
3. Add to `traefik/dynamic/n8n.yml`:

```yaml
http:
  middlewares:
    whitelabel-css:
      replacePathRegex:
        regex: "</head>"
        replacement: "<link rel='stylesheet' href='/custom/whitelabel.css'></head>"
```

## 📁 File Structure

```
n8n/
├── Dockerfile                    # Custom Dockerfile with whitelabeling
├── whitelabel/
│   ├── logos/                   # Custom logo files
│   │   ├── favicon.ico
│   │   ├── favicon-16x16.png
│   │   ├── favicon-32x32.png
│   │   ├── logo.svg
│   │   ├── logo-collapsed.svg
│   │   └── logo-expanded.svg
│   ├── styles/                  # Custom CSS
│   │   └── custom.css
│   ├── config/                  # Brand configuration
│   │   └── brand-config.json
│   └── scripts/                 # Build/apply scripts
│       ├── apply-whitelabel.sh
│       └── docker-entrypoint.sh
└── requirements.txt
```

## 🎯 Quick Reference

### Logo Sizes
- **Favicon**: 16x16, 32x32, 48x48
- **Sidebar Logo**: ~40px height
- **Format**: SVG (recommended) or PNG

### Color Format
- **Format**: HSL (Hue, Saturation, Lightness)
- **Hue**: 0-360 (color)
- **Saturation**: 0-100% (intensity)
- **Lightness**: 0-100% (brightness)

### Rebuild Command
```bash
docker compose build n8n && docker compose up -d n8n
```

## 🐛 Troubleshooting

### Logos Not Appearing
1. Check file names match exactly
2. Verify files are in `n8n/whitelabel/logos/`
3. Rebuild image: `docker compose build n8n`
4. Check container logs: `docker compose logs n8n`

### Colors Not Changing
1. Verify CSS syntax in `custom.css`
2. Check browser cache (hard refresh: Ctrl+Shift+R)
3. Verify HSL values are correct
4. Check if CSS is being injected

### Brand Name Still Shows "n8n"
- Text replacement requires building from source
- Logo and color changes work with Docker method
- Use reverse proxy for runtime text replacement

## 📚 References

- [n8n Whitelabeling Documentation](https://docs.n8n.io/embed/white-labelling/)
- [HSL Color Picker](https://hslpicker.com/)
- [SVG Logo Guidelines](https://developer.mozilla.org/en-US/docs/Web/SVG)

## 🚀 Next Steps

1. **Add your logos** to `n8n/whitelabel/logos/`
2. **Customize colors** in `n8n/whitelabel/styles/custom.css`
3. **Update brand config** in `n8n/whitelabel/config/brand-config.json`
4. **Rebuild**: `docker compose build n8n`
5. **Deploy**: `docker compose up -d n8n`

Happy branding! 🎨

