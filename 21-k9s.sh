#!/bin/bash

# Install k9s
mkdir -p ~/bin
mkdir -p ~/tools/k9s

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

# Get latest k9s version
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Create a temporary directory for download and extraction
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download the binary to temp directory
echo "Downloading k9s ${K9S_VERSION} for ${OS}/${ARCH}..."
curl -Lo $TEMP_DIR/k9s-${K9S_VERSION}.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_${OS}_${ARCH}.tar.gz"

# Extract the binary to temp directory
tar -xzf $TEMP_DIR/k9s-${K9S_VERSION}.tar.gz -C $TEMP_DIR

# Move the binary to its final location
mv $TEMP_DIR/k9s ~/tools/k9s/k9s-${K9S_VERSION}

# Make it executable
chmod +x ~/tools/k9s/k9s-${K9S_VERSION}

# Create/Update symlink
ln -sf ~/tools/k9s/k9s-${K9S_VERSION} ~/bin/k9s

# Generate shell completions if supported
if ~/bin/k9s completion zsh &>/dev/null; then
    ~/bin/k9s completion zsh > ~/.oh-my-zsh/completions/_k9s
fi

echo "k9s ${K9S_VERSION} has been installed successfully for ${OS}/${ARCH}"
