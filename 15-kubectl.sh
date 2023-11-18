#!/bin/bash

TARGET_USER=neelaundhia

# Install kubectl
#
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mkdir -p /home/${TARGET_USER}/.oh-my-zsh/completions
./kubectl completion zsh >/home/${TARGET_USER}/.oh-my-zsh/completions/_kubectl
mkdir -p /home/${TARGET_USER}/.local/bin
mv ./kubectl /home/${TARGET_USER}/.local/bin/kubectl
#
#
# End
