#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/tools/sops
mkdir -p ~/bin

# Get latest SOPS version
SOPS_VERSION=$(curl -s "https://api.github.com/repos/getsops/sops/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Convert architecture names to match SOPS naming
case "${ARCH}" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Handle OS-specific cases
case "${OS}" in
    darwin|linux)
        BINARY_NAME="sops-v${SOPS_VERSION}.${OS}.${ARCH}"
        ;;
    *)
        echo "Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

# Download the binary
echo "Downloading SOPS ${SOPS_VERSION} for ${OS}/${ARCH}..."
curl -Lo ~/tools/sops/sops-v${SOPS_VERSION} "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/${BINARY_NAME}"

# Make it executable
chmod +x ~/tools/sops/sops-v${SOPS_VERSION}

# Create/Update symlink
ln -sf ~/tools/sops/sops-v${SOPS_VERSION} ~/bin/sops

echo "SOPS v${SOPS_VERSION} has been installed successfully for ${OS}/${ARCH}"