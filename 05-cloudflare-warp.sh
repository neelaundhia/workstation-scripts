#!/bin/bash

# Install Cloudflare Warp
#
# Add cloudflare gpg key
curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg
#
# Add this repo to your apt repositories
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/cloudflare-client.list
#
# Install
sudo apt-get update && sudo apt-get install -y cloudflare-warp
#
# Completion
mkdir -p ~/.oh-my-zsh/completions
warp-cli generate-completions zsh >~/.oh-my-zsh/completions/_warp-cli
#
# End
