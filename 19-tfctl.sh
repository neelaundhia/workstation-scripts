#!/bin/bash

# Install Terraform CTL
#
brew install weaveworks/tap/tfctl
cp -f config/zsh/.zshrc.d/terraform.source ~/.zshrc.d/terraform.source
tfctl completion zsh >~/.oh-my-zsh/completions/_tfctl
#
#
# End
