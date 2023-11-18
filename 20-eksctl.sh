#!/bin/bash

# Install EKS CTL
#
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
brew install weaveworks/tap/eksctl
mkdir -p ~/.oh-my-zsh/completions/
eksctl completion zsh >~/.oh-my-zsh/completions/_eksctl
#
# End
