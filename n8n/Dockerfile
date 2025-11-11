# Custom n8n Dockerfile with Python 3.11+
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

# Clean up build dependencies to reduce image size
RUN apk del python3-dev gcc g++ musl-dev libffi-dev openssl-dev postgresql-dev linux-headers

# Switch back to n8n user
USER node

# Verify Python installation
RUN python3 --version && pip3 --version

# Set Python path
ENV PYTHONUNBUFFERED=1
ENV PATH="/usr/bin:$PATH"

