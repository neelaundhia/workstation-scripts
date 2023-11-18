#!/bin/bash

TARGET_USER=neelaundhia

# Install Flux CLI
#
brew install fluxcd/tap/flux
mkdir -p /home/${TARGET_USER}/.oh-my-zsh/completions
flux completion zsh >/home/${TARGET_USER}/.oh-my-zsh/completions/_flux
#
#
# End
