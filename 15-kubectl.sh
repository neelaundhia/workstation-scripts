#!/bin/bash

# Install kubectl
brew install kubernetes-cli
mkdir -p ~/.oh-my-zsh/completions
kubectl completion zsh >~/.oh-my-zsh/completions/_kubectl
cp config/zsh/.zshrc.d/kubectl.source ~/.zshrc.d/kubectl.source
