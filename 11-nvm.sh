#!/bin/bash

# Install NVM
#
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
#
# End

# Configure NVM
#
cp -f config/zsh/.zshrc.d/nvm.source ~/.zshrc.d/nvm.source
#
# End
