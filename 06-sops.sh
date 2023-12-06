#!/bin/bash

# Download the binary                                                                                                                                                      ─╯
curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64

# Preparation
mkdir -p ~/.local/bin
source ~/.profile

# Move the binary in to your PATH
mv sops-v3.8.1.linux.amd64 ~/.local/bin/sops

# Make the binary executable
chmod +x ~/.local/bin/sops
