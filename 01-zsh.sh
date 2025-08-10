#!/bin/bash

# Install ZSH
sudo apt update
sudo apt install curl zsh -y

# Install Oh My ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Copy tez.zsh-theme to Oh My ZSH themes directory
cp config/zsh/themes/* ~/.oh-my-zsh/themes

# Set theme to tez
sed -i 's#robbyrussell#tez#g' ~/.zshrc

# Configure ZSH
mkdir -p ~/.zshrc.d
cp config/zsh/.zshrc.d/base.source ~/.zshrc.d/base.source
echo $'\n# Source custom scripts from ~/.zshrc.d\nsource <(cat ~/.zshrc.d/*.source)' >>~/.zshrc

# Set ZSH as default shell without prompting (optional)
# chsh -s $(which zsh)
