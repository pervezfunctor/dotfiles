# Use specific Alpine version for reproducibility
FROM alpine:3.22

# Add labels for metadata
LABEL maintainer="pervezfunctor@gmail.com" \
      org.opencontainers.image.title="Alpine Code Server" \
      org.opencontainers.image.description="VS Code running on a remote server" \
      org.opencontainers.image.source="https://github.com/coder/code-server" \
      org.opencontainers.image.licenses="MIT"

# Set environment variables
ENV CODE_SERVER_VERSION=4.105.1 \
    HOME=/home/coder \
    NODE_ENV=production

# Create a non-root user for security
RUN addgroup -g 1000 coder && \
    adduser -D -s /bin/bash -u 1000 -G coder coder

# Install dependencies and code-server in a single layer to reduce image size
RUN apk add --no-cache \
    bash \
    curl \
    nodejs \
    npm \
    libstdc++ \
    libc6-compat \
    python3 \
    make \
    g++ \
    && \
    # Download and install code-server
    curl -L -o code-server.tar.gz \
    "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-alpine.tar.gz" && \
    tar -xzf code-server.tar.gz && \
    cp -r code-server-${CODE_SERVER_VERSION}-linux-alpine/* /usr/local/ && \
    rm -rf code-server* && \
    # Clean up to reduce image size
    apk del --purge python3 make g++ && \
    rm -rf /var/cache/apk/*

# Set working directory
WORKDIR $HOME

# Create volume for persistent data
VOLUME ["/home/coder/.local/share/code-server"]

# Expose the default port
EXPOSE 8080

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/healthz || exit 1

# Switch to non-root user
USER coder

# Set entrypoint to handle proper signal forwarding and initialization
ENTRYPOINT ["/usr/local/bin/code-server", "--host", "0.0.0.0", "--port", "8080", "--auth", "none"]
