#!/bin/bash

TARGET_USER=neelaundhia

# Install EKS CTL
#
# for ARM systems, set ARCH to: `arm64`, `armv6` or `armv7`
brew install weaveworks/tap/eksctl
mkdir -p /home/${TARGET_USER}/.oh-my-zsh/completions/
eksctl completion zsh >/home/${TARGET_USER}/.oh-my-zsh/completions/_eksctl
#
# End
