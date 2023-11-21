#!/bin/bash

# Install kubectl
#
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mkdir -p ~/.oh-my-zsh/completions
./kubectl completion zsh >~/.oh-my-zsh/completions/_kubectl
cp config/zsh/.zshrc.d/kubectl.source ~/.zshrc.d/kubectl.source
mkdir -p ~/.local/bin
mv ./kubectl ~/.local/bin/kubectl
#
#
# End
