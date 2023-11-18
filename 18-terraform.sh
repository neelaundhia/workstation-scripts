#!/bin/bash

TARGET_USER=neelaundhia

# Install Terraform CLI
#
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
cp -f config/zsh/.zshrc.d/terraform.source /home/${TARGET_USER}/.zshrc.d/terraform.source
#
#
# End
