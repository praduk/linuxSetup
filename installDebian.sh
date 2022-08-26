#!/bin/bash

# Make sure we're in the script directory
pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
if ([ -h "${SCRIPT_PATH}" ]); then
  while([ -h "${SCRIPT_PATH}" ]); do cd `dirname "$SCRIPT_PATH"`; 
  SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

DESKTOP=0
SERVER=0
while getopts ":sdp" opt; do
    case "$opt" in
    s)  SERVER=1
        ;;
    d)  DESKTOP=1
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
	;;
    esac
done


##################### START /etc/apt/sources.list #####################
# Add contrib and non-free repositories
#DISTRO_VER="$(cat /etc/os-release | grep "VERSION=" | cut -f2 -d'(' | cut -f1 -d')')"
DISTRO=$(lsb_release -is)
DISTRO_VER=$(lsb_release -cs)
echo "* Setting up /etc/apt/sources.list for **${DISTRO}** ${DISTRO_VER}"
echo "|- Making Backup /etc/apt/sources.list.backup"
cp -f /etc/apt/sources.list /etc/apt/sources.list.backup

echo "|- Updating /etc/apt/sources.list with main, contrib and non-free ${DISTRO_VER} repositories"
echo "#Apt Sources file" > /etc/apt/sources.list

if [[ "${DISTRO}" == "Ubuntu"  ]]; then
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} main restricted" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} main restricted" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates main restricted" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates main restricted" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} universe" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} universe" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates universe" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates universe" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} multiverse" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} multiverse" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates multiverse" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates multiverse" >> /etc/apt/sources.list
    echo "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-backports main restricted universe multiverse" >> /etc/apt/sources.list
    echo "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-backports main restricted universe multiverse" >> /etc/apt/sources.list
    echo "deb http://archive.canonical.com/ubuntu ${DISTRO_VER} partner" >> /etc/apt/sources.list
    echo "# deb-src http://archive.canonical.com/ubuntu ${DISTRO_VER} partner" >> /etc/apt/sources.list
    echo "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security main restricted" >> /etc/apt/sources.list
    echo "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security main restricted" >> /etc/apt/sources.list
    echo "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security universe" >> /etc/apt/sources.list
    echo "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security universe" >> /etc/apt/sources.list
    echo "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security multiverse" >> /etc/apt/sources.list
    echo "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security multiverse" >> /etc/apt/sources.list
else
    echo "deb http://ftp.us.debian.org/debian/ ${DISTRO_VER} main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://ftp.us.debian.org/debian/ ${DISTRO_VER} main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "deb http://security.debian.org/debian-security ${DISTRO_VER}/updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://security.debian.org/debian-security ${DISTRO_VER}/updates main contrib non-free" >> /etc/apt/sources.list
    echo "" >> /etc/apt/sources.list
    echo "# ${DISTRO_VER}-updates, previously known as 'volatile'" >> /etc/apt/sources.list
    echo "deb http://ftp.us.debian.org/debian/ ${DISTRO_VER}-updates main contrib non-free" >> /etc/apt/sources.list
    echo "deb-src http://ftp.us.debian.org/debian/ ${DISTRO_VER}-updates main contrib non-free" >> /etc/apt/sources.list
fi

# # LiNode
# echo "|- Updating /etc/apt/sources.list with LiNode"
# echo "" >> /etc/apt/sources.list
# echo "# LiNode" >> /etc/apt/sources.list
# echo "deb http://apt.linode.com/ $DISTRO_VER main" >> /etc/apt/sources.list
# wget -O- https://apt.linode.com/linode.gpg | apt-key add -

# Wine Builds
# if [[ $DESKTOP -eq 1 ]]; then
#     echo "|- Updating /etc/apt/sources.list with Wine builds"
#     echo "" >> /etc/apt/sources.list
#     echo "# Wine Builds" >> /etc/apt/sources.list
#     echo "deb https://dl.winehq.org/wine-builds/debian/ $DISTRO_VER main" >> /etc/apt/sources.list
#     wget -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
# fi
#
#if [[ $SERVER -eq 1 ]]; then
#    echo "" >> /etc/apt/sources.list
#    echo "# Cheerp C++ to JS compiler" >> /etc/apt/sources.list
#    echo "deb http://ppa.launchpad.net/leaningtech-dev/cheerp-ppa/ubuntu xenial main" >> /etc/apt/sources.list
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 84540D4B9BF457D5
#fi
################### END /etc/apt/sources.list ###################

echo "* Performing apt-get -qq update"
apt-get -qq -y update

echo "* Install software properties-common"
apt-get -qq -y install software-properties-common

add-apt-repository ppa:neovim-ppa/stable

echo "* Performing apt-get -qq update"
apt-get -qq -y update

echo "* Install JetBrainsMono"
wget -O /tmp/font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip -o -d /usr/local/share/fonts/ /tmp/font.zip
rm -f /tmp/font.zip

echo "* Update Font Cache"
fc-cache -fv

echo "* Installing RipGrep"
apt-get -qq -y install ripgrep

echo "* Installing Build-Essential"
apt-get -qq -y install build-essential

echo "* Installing Git"
apt-get -qq -y install git

echo "* Installing LLVM and Clang"
apt-get -qq -y install llvm clang

echo "* installing boost"
apt-get -qq -y install libboost-all-dev

echo "* Installing Vim-Gnome, Nvim and TMux"
apt-get -qq -y install tmux neovim python3-pynvim lua-nvim-dev
sudo update-alternatives --set editor $(which nvim)

echo "* Installing Cmake"
apt-get -qq -y install cmake

echo "* Installing Ninja"
apt-get -qq -y install ninja-build

echo "* Installing Lua 5.4"
apt-get -qq -y install lua5.4-dev lua5.4

#echo "* Installing Web Tookit"
#apt-get -qq -y install witty witty-dev witty-doc witty-dbg witty-examples

#echo "* Installing MPI"
#apt-get -qq -y install libopenmpi-dev

#echo "* Installing LiNode CLI"
#apt-get -qq -y install linode-cli

echo "* Installing NSS"
apt-get -qq -y install libnss3-dev

echo "* Installing Curl"
apt-get -qq -y install libcurl4-nss-dev

echo "* Installing OpenSSL"
apt-get -qq install openssl

echo "* Installing Python3 and PIP"
apt-get -qq install python3 python3-pip
#echo "* Installing Python Packages"
#echo "|- meson"
#pip3 install --user meson
#apt-get -qq install python python-pip
#echo "* Installing Python Packages"
#echo "|- httpsig"
#pip3 install httpsig
#echo "|- s2protocol"
#pip3 install s2protocol
#echo "|- parse"
#pip3 install parse

#echo "* Installing OpenBLAS"
#sudo apt-get -qq install libopenblas-dev

#echo "* Installing SOX"
#apt-get -qq -y install sox libsox-fmt-all

if [[ $DESKTOP -eq 1 ]]; then
    #echo "* Installing pico2wave"
    #apt-get -qq -y install libttspico-dev libttspico-utils

    #echo "* Installing Vim-YouCompleteMe"
    #apt-get -qq -y install vim-youcompleteme

    echo "* Installing Kitty"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ${HOME}/.local/kitty.app/bin/kitty 0
    sudo update-alternatives --set x-terminal-emulator ${HOME}/.local/kitty.app/bin/kitty

    echo "* Installing Awesome"
    apt-get -qq -y install awesome

    echo "* Installing GDB"
    apt-get -qq -y install gdb
    
    echo "* Installing valgrind"
    apt-get -qq -y install valgrind

    echo "* Installing OpenBLAS"
    sudo apt-get -qq install libopenblas-dev

    #echo "* Install JRE"
    #apt-get -qq -y install default-jre

    echo "* Installing gfortran"
    apt-get -qq -y install gfortran

    echo "* Installing TeX-live"
    apt-get -qq -y install texlive-full

    echo "* WmCtrl"
    apt-get -qq -y install wmctrl
    
    #echo "* Installing Qt"
    #apt-get -qq -y install qt5-default
    
    #echo "* Installing FLTK"
    #apt-get -qq -y install fltk1.3-dev
    
    #echo "* Installing GTKMM"
    #apt-get -qq -y install libgtkmm-3.0-dev libgtkmm-3.0-dev
    
    #echo "* Installing Chromium"
    #apt-get -qq -y install chromium
    #xdg-settings set default-web-browser google-chrome.desktop
    
    echo "* Installing xxdiff"
    apt-get -qq -y install xxdiff
    
    echo "* Installing Vulkan"
    apt-get -qq -y install libvulkan-dev vulkan-utils
    
    #echo "* Installing Android Development Kit"
    #apt-get -qq -y install android-sdk
    
    echo "* Installing GLM/GLEW/GLFW"
    apt-get -qq -y install libglm-dev
    apt-get -qq -y install libglew-dev
    apt-get -qq -y install libglfw3-dev
    
    #echo "* Installing Nvidia Drivers and CUDA"
    #apt-get -qq -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') 
    #dpkg --add-architecture i386
    #apt-get -qq -y install firmware-linux nvidia-driver nvidia-settings nvidia-xconfig
    #apt-get -qq -y install nvidia-cuda-toolkit
    #nvidia-xconfig
    
    ## echo "* Installing festival Text to Voice"
    #apt-get -qq install festival-dev festival-doc festvox-us*

    #echo "* Installing Cheerp"
    #apt-get -qq -y install chreep-core

    #echo "* Installing Nim"
    #apt-get -qq -y install nim nim-doc

    # Interactive Plotting
    #echo "* Installing udav"
    #apt-get -qq -y install udav
    ##./installAdept

    #echo "* JDK and ANT"
    #apt-get -qq -y install default-jdk ant

    #echo "* Discord"
    #mkdir -p /tmp
    #wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    #sudo dpkg -i /tmp/discord.deb
    #sudo apt --fix-broken install
fi

if [[ $SERVER -eq 1 ]]; then
    echo "* Installing PHP"
    apt-get -qq -y install php8.1-fpm

    echo "* Installing NGINX"
    apt-get -qq -y install nginx-full
    
    echo "* Installing pureFPTd"
    apt-get -qq -y install pure-ftpd
    
    echo "* Installing mailutils"
    apt-get -qq -y install mailutils

    echo "* Websockify"
    apt-get -qq -y install websockify
    
    echo "* Supervisor"
    apt-get -qq -y install supervisor
fi

apt-get -qq -y upgrade

if [[ $SERVER -eq 1 ]]; then
    ./serverSetup.sh
fi
