#!/bin/bash

##### START /etc/apt/sources.list #####
# Add contrib and non-free repositories
DEBIAN_DISTRO="$(cat /etc/os-release | grep "VERSION=" | cut -f2 -d'(' | cut -f1 -d')')"
echo "* Setting up /etc/apt/sources.list for Debian ${DEBIAN_DISTRO}"
echo "|- Making Backup /etc/apt/sources.list.backup"
sudo cp -f /etc/apt/sources.list /etc/apt/sources.list.backup

echo "|- Updating /etc/apt/sources.list with main, contrib and non-free ${DEBIAN_DISTRO} repositories"
sudo echo "#Apt Sources file" > /etc/apt/sources.list
sudo echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free" >> /etc/apt/sources.list
sudo echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free" >> /etc/apt/sources.list
sudo echo "" >> /etc/apt/sources.list
sudo echo "deb http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free" >> /etc/apt/sources.list
sudo echo "deb-src http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free" >> /etc/apt/sources.list
sudo echo "" >> /etc/apt/sources.list
sudo echo "# ${DEBIAN_DISTRO}-updates, previously known as 'volatile'" >> /etc/apt/sources.list
sudo echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free" >> /etc/apt/sources.list
sudo echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free" >> /etc/apt/sources.list

# Wine Builds
echo "|- Updating /etc/apt/sources.list with Wine builds"
sudo echo "" >> /etc/apt/sources.list
sudo echo "# Wine Builds" >> /etc/apt/sources.list
sudo echo "deb https://dl.winehq.org/wine-builds/debian/ stretch main" >> /etc/apt/sources.list
##### END /etc/apt/sources.list #####

echo "* Performing apt-get update"
sudo apt-get -y update

echo "* Installing Build-Essential"
sudo apt-get -y install build-essential

echo "* Installing GDB"
sudo apt-get -y install gdb

echo "* Installing valgrind"
sudo apt-get -y install valgrind

echo "* Installing LLVM and Clang"
sudo apt-get -y install llvm clang

echo "* installing boost"
sudo apt-get -y install libboost-all-dev

echo "* installing asio"
sudo apt-get -y install libasio-dev

echo "* Installing Vim-Gnome"
sudo apt-get -y install vim-gnome

echo "* Installing Vim-YouCompleteMe"
sudo apt-get -y install vim-youcompleteme

echo "* WmCtrl"
sudo apt-get -y install wmctrl

echo "* Installing Cmake"
sudo apt-get -y install cmake

echo "* Installing Qt"
sudo apt-get -y install qt5-default

echo "* Installing FLTK"
sudo apt-get -y install fltk1.3-dev

echo "* Installing GTKMM"
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

echo "* Installing Android Development Kit"
sudo apt-get -y install android-sdk

echo "* Installing GLM/GLEW/GLFW"
sudo apt-get -y install libglm-dev
sudo apt-get -y install libglew-dev
sudo apt-get -y install libglfw3-dev

echo "* Installing Web Tookit"
sudo apt-get -y install witty witty-dev witty-doc witty-dbg witty-examples

echo "* Installing MPI"
sudo apt-get -y install libopenmpi-dev

echo "* Install JRE"
sudo apt-get -y install default-jre

echo "* Installing Nvidia Drivers and CUDA"
sudo apt-get -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') 
sudo dpkg --add-architecture i386
sudo apt-get -y install firmware-linux nvidia-driver nvidia-settings nvidia-xconfig
sudo apt-get -y install nvidia-cuda-toolkit


sudo apt-get -y upgrade

sudo nvidia-xconfig
