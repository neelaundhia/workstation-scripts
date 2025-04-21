#!/bin/bash

# Install Helm
mkdir -p ~/bin
mkdir -p ~/tools/helm

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

# Get latest helm version
HELM_VERSION=$(curl -s https://api.github.com/repos/helm/helm/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download the binary to the temp directory
echo "Downloading Helm ${HELM_VERSION} for ${OS}/${ARCH}..."
curl -Lo "${TEMP_DIR}/helm-${HELM_VERSION}.tar.gz" "https://get.helm.sh/helm-${HELM_VERSION}-${OS}-${ARCH}.tar.gz"

# Extract the binary in the temp directory
cd "${TEMP_DIR}"
tar xzf "helm-${HELM_VERSION}.tar.gz"

# Move the binary to the tools directory
mv "${OS}-${ARCH}/helm" "${HOME}/tools/helm/helm-${HELM_VERSION}"

# Make it executable
chmod +x "${HOME}/tools/helm/helm-${HELM_VERSION}"

# Create/Update symlink
ln -sf ~/tools/helm/helm-${HELM_VERSION} ~/bin/helm

# Generate shell completions
~/bin/helm completion zsh > ~/.oh-my-zsh/completions/_helm

echo "Helm ${HELM_VERSION} has been installed successfully for ${OS}/${ARCH}"