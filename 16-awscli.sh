#!/bin/bash

# Install AWS CLI
#
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf awscliv2.zip aws
cp -f config/zsh/.zshrc.d/awscli.source ~/.zshrc.d/awscli.source
#
#
# End
