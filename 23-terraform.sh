#!/bin/bash

# Install Terraform
mkdir -p ~/bin
mkdir -p ~/tools/terraform

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

# Get latest Terraform version
TERRAFORM_VERSION=$(curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

# Print the Terraform version
echo "Installing Terraform ${TERRAFORM_VERSION}"

# Create a temporary directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download the binary to the temp directory
echo "Downloading Terraform ${TERRAFORM_VERSION} for ${OS}/${ARCH}..."
curl -Lo "${TEMP_DIR}/terraform-${TERRAFORM_VERSION}.zip" "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION#v}/terraform_${TERRAFORM_VERSION#v}_${OS}_${ARCH}.zip"

# Extract the binary in the temp directory
cd "${TEMP_DIR}"
unzip -q "terraform-${TERRAFORM_VERSION}.zip"

# Move the binary to the tools directory
mv "terraform" "${HOME}/tools/terraform/terraform-${TERRAFORM_VERSION}"

# Make it executable
chmod +x "${HOME}/tools/terraform/terraform-${TERRAFORM_VERSION}"

# Create/Update symlink
ln -sf ~/tools/terraform/terraform-${TERRAFORM_VERSION} ~/bin/terraform

# Generate shell completions
mkdir -p ~/.oh-my-zsh/completions
~/bin/terraform -install-autocomplete 2>/dev/null || true

echo "Terraform ${TERRAFORM_VERSION} has been installed successfully for ${OS}/${ARCH}"
