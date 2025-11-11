#!/bin/sh
# Custom entrypoint that applies whitelabeling before starting n8n

# Apply whitelabeling
if [ -f "/whitelabel/scripts/apply-whitelabel.sh" ]; then
    /whitelabel/scripts/apply-whitelabel.sh || true
fi

# Call original n8n entrypoint
exec /docker-entrypoint.sh "$@"

