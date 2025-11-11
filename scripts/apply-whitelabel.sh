#!/bin/bash
# Helper script to apply whitelabeling and rebuild n8n

set -e

echo "🎨 Applying Whitelabeling to n8n..."
echo ""

# Check if logos directory exists and has files
if [ -d "n8n/whitelabel/logos" ] && [ "$(ls -A n8n/whitelabel/logos/*.{png,ico,svg} 2>/dev/null)" ]; then
    echo "✅ Logo files found in n8n/whitelabel/logos/"
    ls -lh n8n/whitelabel/logos/
else
    echo "⚠️  No logo files found in n8n/whitelabel/logos/"
    echo "   Add your logo files to enable logo customization"
fi

echo ""
echo "📝 Checking configuration files..."

if [ -f "n8n/whitelabel/config/brand-config.json" ]; then
    echo "✅ Brand config found"
    cat n8n/whitelabel/config/brand-config.json | grep -E "brandName|primaryColor" || true
else
    echo "⚠️  Brand config not found"
fi

if [ -f "n8n/whitelabel/styles/custom.css" ]; then
    echo "✅ Custom CSS found"
    grep -E "color-primary" n8n/whitelabel/styles/custom.css | head -3 || true
else
    echo "⚠️  Custom CSS not found"
fi

echo ""
echo "🔨 Rebuilding n8n Docker image..."
docker compose build n8n

echo ""
echo "🚀 Restarting n8n container..."
docker compose up -d n8n

echo ""
echo "✅ Whitelabeling applied!"
echo ""
echo "📋 Next steps:"
echo "   1. Open http://localhost:5678"
echo "   2. Check browser tab for custom favicon"
echo "   3. Check sidebar for custom logo"
echo "   4. Verify colors match your brand"
echo "   5. Hard refresh browser (Ctrl+Shift+R) if needed"
echo ""

