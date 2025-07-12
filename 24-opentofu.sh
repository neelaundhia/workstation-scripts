#!/bin/bash

# Install OpenTofu
mkdir -p ~/bin
mkdir -p ~/tools/opentofu

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

# Get latest OpenTofu version
OPENTOFU_VERSION=$(curl -s https://api.github.com/repos/opentofu/opentofu/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Print the OpenTofu version
echo "Installing OpenTofu ${OPENTOFU_VERSION}"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download the binary to the temp directory
echo "Downloading OpenTofu ${OPENTOFU_VERSION} for ${OS}/${ARCH}..."
curl -Lo "${TEMP_DIR}/opentofu-${OPENTOFU_VERSION}.zip" "https://github.com/opentofu/opentofu/releases/download/${OPENTOFU_VERSION}/tofu_${OPENTOFU_VERSION#v}_${OS}_${ARCH}.zip"

# Extract the binary in the temp directory
cd "${TEMP_DIR}"
unzip -q "opentofu-${OPENTOFU_VERSION}.zip"

# Move the binary to the tools directory
mv "tofu" "${HOME}/tools/opentofu/tofu-${OPENTOFU_VERSION}"

# Make it executable
chmod +x "${HOME}/tools/opentofu/tofu-${OPENTOFU_VERSION}"

# Create/Update symlink
ln -sf ~/tools/opentofu/tofu-${OPENTOFU_VERSION} ~/bin/tofu

echo "OpenTofu ${OPENTOFU_VERSION} has been installed successfully for ${OS}/${ARCH}"
