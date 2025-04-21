#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/.zshrc.d
mkdir -p ~/.oh-my-zsh/completions

mkdir -p ~/bin
mkdir -p ~/tools/flux

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Convert architecture names
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

# Get latest flux version
FLUX_VERSION=$(curl -s https://api.github.com/repos/fluxcd/flux2/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Create a temporary directory for extraction
TMP_DIR=$(mktemp -d)

# Download the tarball
echo "Downloading Flux ${FLUX_VERSION} for ${OS}/${ARCH}..."
curl -Lo "${TMP_DIR}/flux.tar.gz" "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_${OS}_${ARCH}.tar.gz"

# Extract the flux binary from the tarball
tar -xzf "${TMP_DIR}/flux.tar.gz" -C "${TMP_DIR}" flux

# Move the binary to the tools directory
cp "${TMP_DIR}/flux" ~/tools/flux/flux-${FLUX_VERSION}

# Clean up the temporary directory
rm -rf "${TMP_DIR}"

# Make it executable
chmod +x ~/tools/flux/flux-${FLUX_VERSION}

# Create/Update symlink
ln -sf ~/tools/flux/flux-${FLUX_VERSION} ~/bin/flux

# Generate shell completions
~/bin/flux completion zsh > ~/.oh-my-zsh/completions/_flux

echo "Flux ${FLUX_VERSION} has been installed successfully for ${OS}/${ARCH}"

