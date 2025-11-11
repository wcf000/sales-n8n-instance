FROM node:20-alpine

WORKDIR /app

# Install dependencies
RUN apk add --no-cache curl

# Install PostGraphile
RUN npm install -g postgraphile@latest

# Create entrypoint script
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'exec postgraphile \' >> /entrypoint.sh && \
    echo '  --connection "$DATABASE_URL" \' >> /entrypoint.sh && \
    echo '  --schema "$POSTGRAPHILE_SCHEMA" \' >> /entrypoint.sh && \
    echo '  --watch \' >> /entrypoint.sh && \
    echo '  --enhance-graphql \' >> /entrypoint.sh && \
    echo '  --subscriptions \' >> /entrypoint.sh && \
    echo '  --dynamic-json \' >> /entrypoint.sh && \
    echo '  --set-owner-connection \' >> /entrypoint.sh && \
    echo '  --host 0.0.0.0 \' >> /entrypoint.sh && \
    echo '  --port 5000' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 5000

CMD ["/entrypoint.sh"]

