#!/bin/bash

# Add contrib and non-free repositories
DEBIAN_DISTRO="$(cat /etc/os-release | grep "VERSION=" | cut -f2 -d'(' | cut -f1 -d')')"
echo "* Setting up /etc/apt/sources.list for Debian ${DEBIAN_DISTRO}"
echo "|- Making Backup /etc/apt/sources.list.backup"
sudo cp -f /etc/apt/sources.list /etc/apt/sources.list.backup

echo "|- Updating /etc/apt/sources.list with main, contrib and non-free ${DEBIAN_DISTRO} repositories"
sudo echo "#Synaptic Sources file"
sudo echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free" >
sudo echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free"
sudo echo ""
sudo echo "deb http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free"
sudo echo "deb-src http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free"
sudo echo ""
sudo echo "# ${DEBIAN_DISTRO}-updates, previously known as 'volatile'"
sudo echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free"
sudo echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free"

echo "* Performing apt-get update"
sudo apt-get -y update

echo "* Installing Build-Essential"
sudo apt-get -y install build-essential

echo "* Installing Vim-Gnome"
sudo apt-get -y install vim-gnome

echo "* Installing Cmake"
sudo apt-get -y install cmake

echo "* Installing Qt"
sudo apt-get -y install libgtkmm-3.0-dev libgtkmm-3.0-dev

echo "* Installing Chromium"
sudo apt-get -y install chromium

echo "* Installing xxdiff"
sudo apt-get -y install xxdiff

echo "* Installing Lua 5.3"
sudo apt-get -y install lua5.3-dev lua5.3

echo "* Installing TeX-live"
sudo apt-get -y install texlive-full

echo "* Installing Vulkan"
sudo apt-get -y install libvulkan-dev vulkan-utils

#sudo apt-get -y install libglm-dev
#sudo apt-get -y install libglew-dev
#sudo apt-get -y install vulkan-utils
#sudo apt-get -y install libglfw3-dev

#sudo apt-get -y upgrade
