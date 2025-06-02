#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/.zshrc.d
mkdir -p ~/.oh-my-zsh/completions

mkdir -p ~/bin
mkdir -p ~/tools/awscli

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Abort for MacOS, as it is not supported
if [[ "${OS}" == "darwin" ]]; then
    echo "MacOS is not supported for this script."
    exit 1
fi

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

# Download the installer zip file
echo "Downloading aws-cli installer for ${OS}/${ARCH}..."
curl -Lo "~/tools/aws-cli/awscli-exe-${OS}-${ARCH}.zip" "https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCH}.zip"

# Extract te zip file
unzip "awscli-exe-${OS}-${ARCH}.zip"

# Install aws-cli
./aws/install --bin-dir ~/bin --install-dir ~/tools/aws-cli/ --update

