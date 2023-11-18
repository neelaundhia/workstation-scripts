#!/bin/bash

# Install EKS CTL
#
brew install weaveworks/tap/eksctl
mkdir -p ~/.oh-my-zsh/completions/
eksctl completion zsh >~/.oh-my-zsh/completions/_eksctl
#
# End
