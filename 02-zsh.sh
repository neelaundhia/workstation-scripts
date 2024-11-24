#!/bin/bash

# Install ZSH
#
sudo apt update
sudo apt install zsh -y
#
# End

# Install Oh My ZSH
#
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#
# End

# Configure Oh My ZSH
#
mkdir -p ~/.zshrc.d
cp config/zsh/.zshrc.d/base.source ~/.zshrc.d/base.source
echo $'\n# Source custom scripts from ~/.zshrc.d\nsource <(cat ~/.zshrc.d/*.source)' >>~/.zshrc
#
# End
