# Custom n8n Dockerfile with Python 3.11+ and Whitelabeling Support
FROM n8nio/n8n:latest

# Install system dependencies for Python and package building
USER root

RUN apk add --no-cache \
    python3 \
    py3-pip \
    python3-dev \
    gcc \
    g++ \
    musl-dev \
    libffi-dev \
    openssl-dev \
    postgresql-dev \
    linux-headers \
    curl \
    bash \
    && ln -sf python3 /usr/bin/python \
    && ln -sf pip3 /usr/bin/pip

# Upgrade pip to latest version
# Use --break-system-packages for Alpine Linux Python 3.11+ (PEP 668)
RUN pip install --break-system-packages --upgrade pip setuptools wheel

# Copy requirements file
COPY requirements.txt /tmp/requirements.txt

# Install Python packages
# Use --break-system-packages for Alpine Linux Python 3.11+ (PEP 668)
RUN pip install --break-system-packages --no-cache-dir -r /tmp/requirements.txt

# Copy whitelabeling files
COPY whitelabel/ /whitelabel/

# Make whitelabel script executable
RUN chmod +x /whitelabel/scripts/apply-whitelabel.sh 2>/dev/null || true

# Find n8n public directory and apply whitelabeling
RUN PUBLIC_DIR=$(find /usr/local/lib/node_modules/n8n -type d -name "public" | head -1) && \
    if [ -n "$PUBLIC_DIR" ] && [ -d "/whitelabel/logos" ]; then \
        echo "Applying whitelabeling to $PUBLIC_DIR" && \
        cp -f /whitelabel/logos/*.png /whitelabel/logos/*.ico /whitelabel/logos/*.svg "$PUBLIC_DIR/" 2>/dev/null || true && \
        echo "Logos copied successfully"; \
    else \
        echo "Public directory not found or logos directory missing"; \
    fi

# Clean up build dependencies to reduce image size
RUN apk del python3-dev gcc g++ musl-dev libffi-dev openssl-dev postgresql-dev linux-headers

# Switch back to n8n user
USER node

# Verify Python installation
RUN python3 --version && pip3 --version

# Set Python path
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/bin:$PATH"

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

