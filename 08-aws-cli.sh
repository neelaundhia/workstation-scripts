#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/.zshrc.d
mkdir -p ~/.oh-my-zsh/completions

mkdir -p ~/bin
mkdir -p ~/tools/aws-cli

# Install Dependencies
sudo apt update
sudo apt install unzip -y

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
        ARCH="x86_64"
        ;;
    aarch64)
        ARCH="aarch64"
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Download the installer zip file
echo "Downloading aws-cli installer for ${OS}/${ARCH}..."
curl -O --output-dir ~/tools/aws-cli/ "https://awscli.amazonaws.com/awscli-exe-${OS}-${ARCH}.zip" --create-dirs

# Extract the zip file
unzip ~/tools/aws-cli/awscli-exe-${OS}-${ARCH}.zip -d ~/tools/aws-cli/

# Install aws-cli
~/tools/aws-cli/aws/install --bin-dir ~/bin --install-dir ~/tools/aws-cli/ --update

# Copy aws-cli source file for additional configuration
cp config/zsh/.zshrc.d/aws-cli.source ~/.zshrc.d/aws-cli.source