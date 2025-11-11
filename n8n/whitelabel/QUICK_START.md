# Whitelabeling Quick Start Guide

## 🚀 Quick Setup (5 minutes)

### Step 1: Add Your Logos

Place your logo files in `n8n/whitelabel/logos/`:

**Required files:**
- `favicon.ico` - Browser favicon (16x16, 32x32, 48x48)
- `favicon-16x16.png` - 16x16 PNG favicon
- `favicon-32x32.png` - 32x32 PNG favicon
- `logo.svg` - Main logo (SVG format)
- `logo-collapsed.svg` - Sidebar collapsed logo (~40px height)
- `logo-expanded.svg` - Sidebar expanded logo (~40px height)

**Logo Tips:**
- Use SVG format for best quality
- Keep logos simple and recognizable at small sizes
- Sidebar logos should be ~40px in height
- Ensure transparent backgrounds for PNG files

### Step 2: Customize Colors

Edit `n8n/whitelabel/styles/custom.css`:

```css
:root {
    /* Convert your brand color to HSL */
    --color-primary-h: 204;  /* Hue: 0-360 */
    --color-primary-s: 100%; /* Saturation: 0-100% */
    --color-primary-l: 50%;  /* Lightness: 0-100% */
}
```

**Color Converter:**
- Use https://hslpicker.com/ to convert hex to HSL
- Example: `#0099ff` = HSL(204, 100%, 50%)

### Step 3: Update Brand Config

Edit `n8n/whitelabel/config/brand-config.json`:

```json
{
  "brandName": "Your Brand Name",
  "brandTagline": "Your Tagline",
  "windowTitle": "Your Brand - Workflow Automation"
}
```

### Step 4: Rebuild and Deploy

```bash
# Rebuild the Docker image
docker compose build n8n

# Restart the container
docker compose up -d n8n
```

### Step 5: Verify

1. Open http://localhost:5678
2. Check browser tab for custom favicon
3. Check sidebar for custom logo
4. Verify colors match your brand

## 📝 Example: Complete Customization

### 1. Logo Files
```
n8n/whitelabel/logos/
├── favicon.ico
├── favicon-16x16.png
├── favicon-32x32.png
├── logo.svg
├── logo-collapsed.svg
└── logo-expanded.svg
```

### 2. Custom CSS
```css
/* n8n/whitelabel/styles/custom.css */
:root {
    --color-primary-h: 204;
    --color-primary-s: 100%;
    --color-primary-l: 50%;
}
```

### 3. Brand Config
```json
{
  "brandName": "DealScale",
  "brandTagline": "Workflow Automation Platform",
  "windowTitle": "DealScale - Workflow Automation"
}
```

## 🎨 What Gets Customized

✅ **Logos** - Favicon, sidebar logos  
✅ **Colors** - Primary theme color  
⚠️ **Text** - Requires building from source (advanced)  
⚠️ **Window Title** - Requires building from source (advanced)

## 🔧 Troubleshooting

**Logos not showing?**
- Check file names match exactly
- Rebuild: `docker compose build n8n --no-cache`
- Check logs: `docker compose logs n8n`

**Colors not changing?**
- Hard refresh browser (Ctrl+Shift+R)
- Verify HSL values in CSS
- Check browser console for errors

## 📚 Full Documentation

See `_docs/WHITELABELING.md` for complete guide.

