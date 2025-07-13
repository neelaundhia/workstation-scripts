#!/bin/bash

# Create directories if they don't exist
mkdir -p ~/.zshrc.d
mkdir -p ~/.oh-my-zsh/completions

mkdir -p ~/bin
mkdir -p ~/tools/oci-cli

# Install Dependencies
sudo apt update
sudo apt install curl -y

# Detect OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Abort for MacOS, as it is not supported by this script
if [[ "${OS}" == "darwin" ]]; then
    echo "MacOS is not supported for this script."
    exit 1
fi

# Verify supported architecture
case "${ARCH}" in
    x86_64|aarch64)
        echo "Installing OCI CLI for ${OS}/${ARCH}..."
        ;;
    *)
        echo "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac

# Download and run the OCI CLI installer
echo "Downloading OCI CLI installer..."
curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh -o ~/tools/oci-cli/install.sh

# Make installer executable
chmod +x ~/tools/oci-cli/install.sh

# Install OCI CLI with custom installation directory
echo "Installing OCI CLI..."
~/tools/oci-cli/install.sh --accept-all-defaults --install-dir ~/tools/oci-cli --exec-dir ~/bin

