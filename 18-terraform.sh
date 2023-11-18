#!/bin/bash

# Install Terraform CLI
#
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
cp -f config/zsh/.zshrc.d/terraform.source ~/.zshrc.d/terraform.source
#
#
# End
