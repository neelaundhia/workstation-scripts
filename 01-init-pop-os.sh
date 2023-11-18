#!/bin/bash

NEW_HOSTNAME="bhairav"

## Full Upgrade
sudo apt update
sudo apt full-upgrade -y

## Naming the Machine
sudo sed -i 's#pop-os#${NEW_HOSTNAME}#g' /etc/hostname
sudo sed -i 's#pop-os#${NEW_HOSTNAME}#g' /etc/hosts

## Reboot
sudo reboot
