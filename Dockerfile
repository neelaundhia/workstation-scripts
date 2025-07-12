# syntax=docker/dockerfile:1
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        sudo \
        curl \
        unzip \
        tar \
        ca-certificates \
        gnupg \
        lsb-release \
        git \
        sed \
        grep \
        coreutils \
        && rm -rf /var/lib/apt/lists/*

# Create a non-root user for testing
RUN useradd -ms /bin/bash tester && echo "tester ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER tester
WORKDIR /home/tester/workspace

# Copy the entire project
COPY . .

# Ensure all scripts are executable
RUN chmod +x install.sh scripts/**/*.sh || true

# Default command: list available scripts (test entrypoint)
CMD ["bash", "install.sh", "--list"] 