#!/bin/bash

# Install Dependencies
sudo apt-get install curl git mercurial make binutils bison gcc build-essential

# Install GVM
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# Installing Go!
gvm install go1.20.12 --prefer-binary
gvm use go1.20.12 --default

# Install the GVM Snippet
cat config/zsh/snippets/gvm >>~/.zshrc
