# Dockerfile for compiling nginx with the optimized unzip module
#
# Build static module:
#   docker build --progress=plain -t nginx-unzip-builder .
#
# Build dynamic module:
#   docker build --progress=plain --build-arg MODULE_TYPE=dynamic -t nginx-unzip-builder .
#
# Override nginx version (default: 1.28.2):
#   docker build --progress=plain --build-arg NGINX_VERSION=1.26.0 -t nginx-unzip-builder .

FROM ubuntu:24.04

# Set working directory
WORKDIR /build

# Install build dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libpcre3 \
    libpcre3-dev \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libzip-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Define nginx version (can be overridden with --build-arg)
ARG NGINX_VERSION=1.28.2

# Define module type: static or dynamic (can be overridden with --build-arg)
ARG MODULE_TYPE=static

# Download and extract nginx sources
RUN curl -fsSL http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar xz && \
    mv nginx-${NGINX_VERSION} nginx-src

# Copy the module source into the build context
# This uses the current directory as the module
COPY . /build/nginx-unzip-module

# Configure and compile nginx with the unzip module
RUN cd /build/nginx-src && \
    MODULE_FLAG="--add-module" && \
    if [ "$MODULE_TYPE" = "dynamic" ]; then \
      MODULE_FLAG="--add-dynamic-module"; \
    fi && \
    ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    ${MODULE_FLAG}=/build/nginx-unzip-module && \
    make && \
    make install && \
    mkdir -p /usr/lib64/nginx/modules && \
    echo "Compilation successful!" && \
    /usr/sbin/nginx -V && \
    if [ "$MODULE_TYPE" = "dynamic" ]; then \
      echo "Dynamic module configured (binary includes module loader)"; \
    else \
      echo "Static module compiled into binary"; \
    fi
