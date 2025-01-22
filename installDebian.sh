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
#if [[ $EUID -ne 0 ]]; then
#   echo "This script needs root privilages." 
#   exit 1
#fi

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
sudo cp -f /etc/apt/sources.list /etc/apt/sources.list.backup

echo "|- Updating /etc/apt/sources.list with main, contrib and non-free ${DISTRO_VER} repositories"
echo "#Apt Sources file" | sudo tee /etc/apt/sources.list

function add_source() {
    echo "$*" | sudo tee -a /etc/apt/sources.list
}

if [[ "${DISTRO}" == "Ubuntu"  ]]; then
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} main restricted" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} main restricted" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates main restricted" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates main restricted" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} universe" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} universe" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates universe" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates universe" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} multiverse" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER} multiverse" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates multiverse" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-updates multiverse" 
    add_source "deb http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-backports main restricted universe multiverse" 
    add_source "# deb-src http://us.archive.ubuntu.com/ubuntu/ ${DISTRO_VER}-backports main restricted universe multiverse" 
    add_source "deb http://archive.canonical.com/ubuntu ${DISTRO_VER} partner" 
    add_source "# deb-src http://archive.canonical.com/ubuntu ${DISTRO_VER} partner" 
    add_source "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security main restricted" 
    add_source "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security main restricted" 
    add_source "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security universe" 
    add_source "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security universe" 
    add_source "deb http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security multiverse" 
    add_source "# deb-src http://security.ubuntu.com/ubuntu ${DISTRO_VER}-security multiverse" 
else
    add_source "deb http://ftp.us.debian.org/debian/ ${DISTRO_VER} main contrib non-free" 
    add_source "deb-src http://ftp.us.debian.org/debian/ ${DISTRO_VER} main contrib non-free" 
    add_source "" 
    add_source "deb http://security.debian.org/debian-security ${DISTRO_VER}/updates main contrib non-free" 
    add_source "deb-src http://security.debian.org/debian-security ${DISTRO_VER}/updates main contrib non-free" 
    add_source "" 
    add_source "# ${DISTRO_VER}-updates, previously known as 'volatile'" 
    add_source "deb http://ftp.us.debian.org/debian/ ${DISTRO_VER}-updates main contrib non-free" 
    add_source "deb-src http://ftp.us.debian.org/debian/ ${DISTRO_VER}-updates main contrib non-free" 
fi

# LLVM
add_source "deb http://apt.llvm.org/${DISTRO_VER}/ llvm-toolchain-${DISTRO_VER} main" 
add_source "deb-src http://apt.llvm.org/${DISTRO_VER}/ llvm-toolchain-${DISTRO_VER} main" 
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -

# Instal Node Package Manager
echo "* Install Node Package Manager"
sudo apt-get install npm

# # LiNode
# echo "|- Updating /etc/apt/sources.list with LiNode"
# add_source ""
# add_source "# LiNode" 
# add_source "deb http://apt.linode.com/ $DISTRO_VER main" 
# wget -O- https://apt.linode.com/linode.gpg | sudo apt-key add -

# Wine Builds
# if [[ $DESKTOP -eq 1 ]]; then
#     echo "|- Updating /etc/apt/sources.list with Wine builds"
#     add_source "" 
#     add_source "# Wine Builds" 
#     add_source "deb https://dl.winehq.org/wine-builds/debian/ $DISTRO_VER main" 
#     wget -O- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
# fi
#
#if [[ $SERVER -eq 1 ]]; then
#    echo "|- Updating /etc/apt/sources.list with Cheerp"
#    add_source "" 
#    add_source "# Cheerp C++ to JS compiler" 
#    add_source "deb http://ppa.launchpad.net/leaningtech-dev/cheerp-ppa/ubuntu xenial main" 
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 84540D4B9BF457D5
#fi
################### END /etc/apt/sources.list ###################

echo "* Performing sudo apt-get -qq update"
sudo apt-get -qq -y update

echo "* Install software properties-common"
sudo apt-get -qq -y install software-properties-common

sudo add-apt-repository ppa:neovim-ppa/stable
sudo add-apt-repository ppa:gekkio/xmonad

echo "* Performing sudo apt-get -qq update"
sudo apt-get -qq -y update

echo "* Install JetBrainsMono"
wget -O /tmp/font.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
sudo unzip -o -d /usr/local/share/fonts/ /tmp/font.zip
rm -f /tmp/font.zip

echo "* Update Font Cache"
sudo fc-cache -fv

echo "* Installing RipGrep"
sudo apt-get -qq -y install ripgrep

echo "* Installing Build-Essential"
sudo apt-get -qq -y install build-essential

echo "* Install Rust"
sudo apt-get -qq -y install rust-all

echo "* Installing Git"
sudo apt-get -qq -y install git

echo "* Installing LLVM and Clang"
sudo apt-get -qq -y install llvm clang

echo "* installing boost"
sudo apt-get -qq -y install libboost-all-dev

echo "* Installing Curl"
sudo apt-get -qq -y install libcurl4-nss-dev curl

echo "* Installing Fuse"
sudo apt-get -qq -y install fuse

echo "* Installing Vim-Gnome, Nvim and TMux"
# sudo apt-get -qq -y install tmux neovim python3-pynvim lua-nvim-dev python3-venv
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage
sudo mv ./nvim.appimage /usr/bin/nvim
#sudo update-alternatives --set editor $(which nvim)
sudo update-alternatives --set editor /usr/bin/nvim
sudo update-alternatives --install /usr/bin/ex ex     "/usr/bin/nvim" 110
sudo update-alternatives --install /usr/bin/vi vi     "/usr/bin/nvim" 110
sudo update-alternatives --install /usr/bin/view view "/usr/bin/nvim" 110
sudo update-alternatives --install /usr/bin/vim vim   "/usr/bin/nvim" 110
sudo update-alternatives --install /usr/bin/vimdiff vimdiff "/usr/bin/nvim" 110

echo "* Installing Cmake"
sudo apt-get -qq -y install cmake

echo "* Installing Ninja"
sudo apt-get -qq -y install ninja-build

echo "* Installing Lua 5.4"
sudo apt-get -qq -y install lua5.4-dev lua5.4

#echo "* Installing Web Tookit"
#sudo apt-get -qq -y install witty witty-dev witty-doc witty-dbg witty-examples

#echo "* Installing MPI"
#sudo apt-get -qq -y install libopenmpi-dev

#echo "* Installing LiNode CLI"
#sudo apt-get -qq -y install linode-cli

echo "* Installing NSS"
sudo apt-get -qq -y install libnss3-dev

echo "* Installing OpenSSL"
sudo apt-get -qq install openssl

echo "* Installing Python3 and PIP"
sudo apt-get -qq install python3 python3-pip
echo "* Installing Python Packages"
echo "|- pytz"
pip3 install pytz
echo "|- Google APIs"
pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib pytz requests
#echo "|- meson"
#pip3 install --user meson
#sudo apt-get -qq install python python-pip
#echo "* Installing Python Packages"
#echo "|- httpsig"
#pip3 install httpsig
#echo "|- s2protocol"
#pip3 install s2protocol
#echo "|- parse"
#pip3 install parse

#echo "* Installing OpenBLAS"
#sudo sudo apt-get -qq install libopenblas-dev

#echo "* Installing SOX"
#sudo apt-get -qq -y install sox libsox-fmt-all

if [[ $DESKTOP -eq 1 ]]; then
    #echo "* Installing pico2wave"
    #sudo apt-get -qq -y install libttspico-dev libttspico-utils

    #echo "* Installing Vim-YouCompleteMe"
    #sudo apt-get -qq -y install vim-youcompleteme

    echo "* Installing Kitty"
    #curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    #update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator ${HOME}/.local/kitty.app/bin/kitty 0
    #sudo update-alternatives --set x-terminal-emulator ${HOME}/.local/kitty.app/bin/kitty
    sudo apt-get -qq -y install kitty

    echo "* Installing Awesome"
    sudo apt-get -qq -y install awesome
    
    echo "* Installing XMonad"
    sudo apt-get -qq -y install xmonad libghc-xmonad-contrib-dev libghc-xmonad-dev suckless-tools xmobar stalonetray dmenu rofi trayer xsecurelock compton
    pip3 install --upgrade google-api-python-client google-auth-httplib2 google-auth-oauthlib

    echo "* Installing GDB"
    sudo apt-get -qq -y install gdb
    
    echo "* Installing valgrind"
    sudo apt-get -qq -y install valgrind

    echo "* Installing OpenBLAS"
    sudo sudo apt-get -qq install libopenblas-dev

    #echo "* Install JRE"
    #sudo apt-get -qq -y install default-jre

    echo "* Installing gfortran"
    sudo apt-get -qq -y install gfortran

    echo "* Installing TeX-live"
    sudo apt-get -qq -y install texlive-full

    echo "* WmCtrl"
    sudo apt-get -qq -y install wmctrl
    
    #echo "* Installing Qt"
    #sudo apt-get -qq -y install qt5-default
    
    #echo "* Installing FLTK"
    #sudo apt-get -qq -y install fltk1.3-dev
    
    #echo "* Installing GTKMM"
    #sudo apt-get -qq -y install libgtkmm-3.0-dev libgtkmm-3.0-dev
    
    #echo "* Installing Chromium"
    #sudo apt-get -qq -y install chromium
    #xdg-settings set default-web-browser google-chrome.desktop
    
    echo "* Installing xxdiff"
    sudo apt-get -qq -y install xxdiff
    
    echo "* Installing Vulkan"
    sudo apt-get -qq -y install libvulkan-dev vulkan-tools vulkan-validationlayers-dev spirv-tools libxxf86vm-dev libxi-dev
    
    #echo "* Installing Android Development Kit"
    #sudo apt-get -qq -y install android-sdk
    
    echo "* Installing GLM/GLEW/GLFW"
    sudo apt-get -qq -y install libglm-dev
    sudo apt-get -qq -y install libglew-dev
    sudo apt-get -qq -y install libglfw3-dev

    echo "* Installing ibus ibus-authy im-config"
    sudo apt-get install ibus ibus-anthy im-config
    im-config ibus
    
    #echo "* Installing Nvidia Drivers and CUDA"
    #sudo apt-get -qq -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') 
    #dpkg --add-architecture i386
    #sudo apt-get -qq -y install firmware-linux nvidia-driver nvidia-settings nvidia-xconfig
    #sudo apt-get -qq -y install nvidia-cuda-toolkit
    #nvidia-xconfig
    
    ## echo "* Installing festival Text to Voice"
    #sudo apt-get -qq install festival-dev festival-doc festvox-us*

    #echo "* Installing Cheerp"
    #sudo apt-get -qq -y install chreep-core

    #echo "* Installing Nim"
    #sudo apt-get -qq -y install nim nim-doc

    # Interactive Plotting
    #echo "* Installing udav"
    #sudo apt-get -qq -y install udav
    ##./installAdept

    #echo "* JDK and ANT"
    #sudo apt-get -qq -y install default-jdk ant

    #echo "* Discord"
    #mkdir -p /tmp
    #wget -O /tmp/discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
    #sudo dpkg -i /tmp/discord.deb
    #sudo apt --fix-broken install
fi

if [[ $SERVER -eq 1 ]]; then
    echo "* Installing PHP"
    sudo apt-get -qq -y install php8.1-fpm

    echo "* Installing NGINX"
    sudo apt-get -qq -y install nginx-full
    
    echo "* Installing pureFPTd"
    sudo apt-get -qq -y install pure-ftpd
    
    echo "* Installing mailutils"
    sudo apt-get -qq -y install mailutils

    echo "* Websockify"
    sudo apt-get -qq -y install websockify
    
    echo "* Supervisor"
    sudo apt-get -qq -y install supervisor
fi

sudo apt-get -qq -y upgrade

if [[ $SERVER -eq 1 ]]; then
    sudo ./serverSetup.sh
fi

./linkconfig.sh
