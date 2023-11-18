#!/bin/bash

# Install Flux CLI
#
brew install fluxcd/tap/flux
mkdir -p ~/.oh-my-zsh/completions
flux completion zsh >~/.oh-my-zsh/completions/_flux
#
#
# End
