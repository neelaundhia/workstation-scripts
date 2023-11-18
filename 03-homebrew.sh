#!/bin/bash

# Install Homebrew
#
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
#
# End

# Configure Homebrew
#
sudo apt-get install build-essential gcc
cp config/zsh/.zshrc.d/homebrew.source ~/.zshrc.d/homebrew.source
#
# End
