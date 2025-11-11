#!/bin/sh
# Script to apply whitelabeling to n8n installation
# This runs inside the Docker container

set -e

N8N_DIR="/home/node/.n8n"
PUBLIC_DIR="/usr/local/lib/node_modules/n8n/dist/public"
N8N_MODULE_DIR="/usr/local/lib/node_modules/n8n"

echo "Applying whitelabeling..."

# Copy custom logos if they exist
if [ -d "/whitelabel/logos" ]; then
    echo "Copying custom logos..."
    cp -f /whitelabel/logos/*.png /whitelabel/logos/*.ico /whitelabel/logos/*.svg "$PUBLIC_DIR/" 2>/dev/null || true
fi

# Inject custom CSS if it exists
if [ -f "/whitelabel/styles/custom.css" ]; then
    echo "Injecting custom CSS..."
    # Find the main CSS file and append our custom CSS
    MAIN_CSS=$(find "$PUBLIC_DIR" -name "*.css" -type f | head -1)
    if [ -n "$MAIN_CSS" ]; then
        cat /whitelabel/styles/custom.css >> "$MAIN_CSS" || true
    fi
fi

echo "Whitelabeling applied successfully!"

