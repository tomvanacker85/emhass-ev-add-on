# Build from scratch using Debian slim base
FROM python:3.11-slim-bookworm

# Set build arguments
ARG BUILD_VERSION="latest"
ARG TARGETARCH

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    jq \
    libffi-dev \
    libc6-dev \
    coinor-cbc \
    libatlas-base-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install uv for faster Python package management
COPY --from=ghcr.io/astral-sh/uv:0.5.9 /uv /uvx /usr/local/bin/

# Set working directory
WORKDIR /app

# Clone and install EV-enhanced EMHASS
RUN git clone -b feature/ev-charging-extension --depth 1 https://github.com/tomvanacker85/emhass.git . && \
    uv venv && \
    . .venv/bin/activate && \
    uv pip install --no-cache-dir -e .

# Create directories for EMHASS EV
RUN mkdir -p /share/emhass-ev /app/config

# Set environment variables for EV version
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=5003
ENV EMHASS_PORT=5003
ENV EMHASS_DATA_PATH=/share/emhass-ev
ENV PATH="/app/.venv/bin:$PATH"

# Docker Labels for Home Assistant
LABEL \
    io.hass.name="emhass-ev" \
    io.hass.description="EMHASS EV: Energy Management for Home Assistant with Electric Vehicle charging optimization" \
    io.hass.version=${BUILD_VERSION} \
    io.hass.type="addon" \
    io.hass.arch="aarch64|amd64" \
    org.opencontainers.image.source="https://github.com/tomvanacker85/emhass" \
    org.opencontainers.image.description="EMHASS EV extension with electric vehicle charging optimization"

# Expose EV port
EXPOSE 5003
