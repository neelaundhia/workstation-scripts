#!/bin/bash

TARGET_USER=neelaundhia

# Install Terraform CTL
#
brew install weaveworks/tap/tfctl
cp -f config/zsh/.zshrc.d/terraform.source /home/${TARGET_USER}/.zshrc.d/terraform.source
tfctl completion zsh >/home/${TARGET_USER}/.oh-my-zsh/completions/_tfctl
#
#
# End
