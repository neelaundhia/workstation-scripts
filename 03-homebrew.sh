#!/bin/bash

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Configure Homebrew
sudo apt-get install build-essential
cp config/zsh/.zshrc.d/homebrew.source ~/.zshrc.d/homebrew.source
source ~/.zshrc
brew install gcc
