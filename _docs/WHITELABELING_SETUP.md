# Whitelabeling Setup - Step by Step

## 🎯 Overview

This guide walks you through setting up whitelabeling for your n8n instance.

## 📋 Prerequisites

- Docker and Docker Compose installed
- Your brand logos (SVG or PNG format)
- Your brand color (hex code)

## 🚀 Setup Steps

### Step 1: Prepare Your Assets

#### A. Create Logo Files

Create these files in `n8n/whitelabel/logos/`:

1. **favicon.ico** - Multi-size ICO file (16x16, 32x32, 48x48)
2. **favicon-16x16.png** - 16x16 PNG
3. **favicon-32x32.png** - 32x32 PNG
4. **logo.svg** - Main logo (SVG recommended)
5. **logo-collapsed.svg** - Sidebar collapsed logo (~40px height)
6. **logo-expanded.svg** - Sidebar expanded logo (~40px height)

**Logo Creation Tips:**
- Use a tool like [Favicon Generator](https://favicon.io/) for favicons
- Export SVG logos from your design tool
- Keep sidebar logos simple and recognizable at small sizes
- Ensure transparent backgrounds

#### B. Get Your Brand Color

1. Note your primary brand color (hex format, e.g., `#0099ff`)
2. Convert to HSL using [HSL Color Picker](https://hslpicker.com/)
3. Example: `#0099ff` = HSL(204, 100%, 50%)

### Step 2: Configure Files

#### A. Update Brand Config

Edit `n8n/whitelabel/config/brand-config.json`:

```json
{
  "brandName": "Your Brand Name",
  "brandTagline": "Your Tagline",
  "windowTitle": "Your Brand - Workflow Automation",
  "primaryColor": {
    "h": 204,
    "s": 100,
    "l": 50
  },
  "primaryColorHex": "#0099ff"
}
```

#### B. Update CSS Colors

Edit `n8n/whitelabel/styles/custom.css`:

```css
:root {
    --color-primary-h: 204;  /* Your color's hue */
    --color-primary-s: 100%; /* Your color's saturation */
    --color-primary-l: 50%;  /* Your color's lightness */
}
```

### Step 3: Rebuild Docker Image

```bash
# Navigate to project root
cd /path/to/self-hosted-ai-starter-kit

# Rebuild n8n image with whitelabeling
docker compose build n8n

# Restart services
docker compose up -d n8n
```

### Step 4: Verify

1. **Open n8n**: http://localhost:5678
2. **Check favicon**: Look at browser tab
3. **Check sidebar logo**: Look at top-left of sidebar
4. **Check colors**: Look for your brand color in buttons/links
5. **Hard refresh**: Press Ctrl+Shift+R (or Cmd+Shift+R on Mac) to clear cache

## 🎨 Customization Examples

### Example 1: Blue Brand

**Color**: `#0099ff`
**HSL**: HSL(204, 100%, 50%)

```css
:root {
    --color-primary-h: 204;
    --color-primary-s: 100%;
    --color-primary-l: 50%;
}
```

### Example 2: Green Brand

**Color**: `#00cc66`
**HSL**: HSL(150, 100%, 40%)

```css
:root {
    --color-primary-h: 150;
    --color-primary-s: 100%;
    --color-primary-l: 40%;
}
```

### Example 3: Purple Brand

**Color**: `#9966ff`
**HSL**: HSL(260, 100%, 70%)

```css
:root {
    --color-primary-h: 260;
    --color-primary-s: 100%;
    --color-primary-l: 70%;
}
```

## 🔧 Advanced: CSS Injection via Traefik

For runtime CSS injection without rebuilding:

1. **Edit CSS**: `traefik/custom/whitelabel.css`
2. **Configure Traefik**: Add middleware to inject CSS
3. **Restart Traefik**: `docker compose restart traefik`

## 📁 File Structure

```
n8n/
└── whitelabel/
    ├── logos/              # Your logo files go here
    │   ├── favicon.ico
    │   ├── favicon-16x16.png
    │   ├── favicon-32x32.png
    │   ├── logo.svg
    │   ├── logo-collapsed.svg
    │   └── logo-expanded.svg
    ├── styles/
    │   └── custom.css      # Your color customizations
    └── config/
        └── brand-config.json  # Your brand settings
```

## ✅ Checklist

- [ ] Logo files created and placed in `n8n/whitelabel/logos/`
- [ ] Brand color converted to HSL
- [ ] `custom.css` updated with HSL values
- [ ] `brand-config.json` updated with brand name
- [ ] Docker image rebuilt: `docker compose build n8n`
- [ ] Container restarted: `docker compose up -d n8n`
- [ ] Verified logos appear in browser
- [ ] Verified colors match brand
- [ ] Hard refreshed browser to clear cache

## 🐛 Troubleshooting

### Logos Not Appearing

1. **Check file names**: Must match exactly (case-sensitive)
2. **Check file location**: Must be in `n8n/whitelabel/logos/`
3. **Rebuild without cache**: `docker compose build n8n --no-cache`
4. **Check container logs**: `docker compose logs n8n | grep -i logo`

### Colors Not Changing

1. **Hard refresh browser**: Ctrl+Shift+R (Windows) or Cmd+Shift+R (Mac)
2. **Check CSS syntax**: Verify HSL values are correct
3. **Check browser console**: Look for CSS errors
4. **Verify CSS is loaded**: Check Network tab in DevTools

### Build Errors

1. **Check Dockerfile syntax**: Ensure no typos
2. **Check file permissions**: Logos should be readable
3. **Check Docker logs**: `docker compose build n8n 2>&1 | tail -50`

## 📚 Next Steps

1. **Test thoroughly**: Check all pages for branding
2. **Update documentation**: Document your brand guidelines
3. **Version control**: Commit whitelabel assets to git
4. **CI/CD**: Include whitelabeling in deployment pipeline

## 🎉 Success!

Once complete, your n8n instance will have:
- ✅ Custom favicon in browser tab
- ✅ Custom logos in sidebar
- ✅ Brand colors throughout UI
- ✅ Professional branded appearance

Happy branding! 🎨

