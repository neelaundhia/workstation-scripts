#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/.zshrc.d
mkdir -p ~/.oh-my-zsh/completions

mkdir -p ~/bin
mkdir -p ~/tools/kubectl

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Convert architecture names to match kubectl naming
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

# Get latest stable kubectl version
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

# Download the binary
echo "Downloading kubectl ${KUBECTL_VERSION} for ${OS}/${ARCH}..."
curl -Lo ~/tools/kubectl/kubectl-${KUBECTL_VERSION} "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl"

# Make it executable
chmod +x ~/tools/kubectl/kubectl-${KUBECTL_VERSION}

# Create/Update symlink
ln -sf ~/tools/kubectl/kubectl-${KUBECTL_VERSION} ~/bin/kubectl

# Generate shell completions
~/bin/kubectl completion zsh > ~/.oh-my-zsh/completions/_kubectl

# Copy kubectl source file for additional configuration
cp config/zsh/.zshrc.d/kubectl.source ~/.zshrc.d/kubectl.source

echo "kubectl ${KUBECTL_VERSION} has been installed successfully for ${OS}/${ARCH}"
