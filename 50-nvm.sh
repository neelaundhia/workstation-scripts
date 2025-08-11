#!/bin/zsh

echo "Fetching latest nvm version..."
NVM_VERSION=$(curl -s https://api.github.com/repos/nvm-sh/nvm/releases/latest | grep '"tag_name"' | awk -F'"' '{print $4}')
echo "Latest nvm version: $NVM_VERSION"

echo "Installing nvm $NVM_VERSION..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash

echo "Copying nvm.source to ~/.zshrc.d/"
cp ./config/zsh/.zshrc.d/nvm.source ~/.zshrc.d/
echo "Done!"

echo "Installation completed successfully! Please remove unwanted stuff in .bashrc, .zshrc and other files."