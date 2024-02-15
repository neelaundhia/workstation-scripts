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

# Install Special Fonts for P10K
# Note that you will need to apply the fonts in the terminal applicationa as well as in any editors that use an integrated terminal.
#
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf -P ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf -P ~/.local/share/fonts
wget https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf -P ~/.local/share/fonts
sudo apt install fontconfig
fc-cache -f -v
#
# End

# Install P10K
#
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's#robbyrussell#powerlevel10k/powerlevel10k#g' ~/.zshrc
#
# End

# Configure P10K
#
# cp config/zsh/.p10k.zsh ~/.p10k.zsh
#
# End

# Configure Oh My ZSH
#
mkdir -p ~/.zshrc.d
cp config/zsh/.zshrc.d/base.source ~/.zshrc.d/base.source
echo $'\n# Source custom scripts from ~/.zshrc.d\nsource <(cat ~/.zshrc.d/*.source)' >>~/.zshrc
#
# End
