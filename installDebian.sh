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
while getopts ":sd" opt; do
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
#DEBIAN_DISTRO="$(cat /etc/os-release | grep "VERSION=" | cut -f2 -d'(' | cut -f1 -d')')"
DEBIAN_DISTRO=$(lsb_release -cs)
echo "* Setting up /etc/apt/sources.list for Debian ${DEBIAN_DISTRO}"
echo "|- Making Backup /etc/apt/sources.list.backup"
cp -f /etc/apt/sources.list /etc/apt/sources.list.backup

echo "|- Updating /etc/apt/sources.list with main, contrib and non-free ${DEBIAN_DISTRO} repositories"
echo "#Apt Sources file" > /etc/apt/sources.list
echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO} main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "deb http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/debian-security ${DEBIAN_DISTRO}/updates main contrib non-free" >> /etc/apt/sources.list
echo "" >> /etc/apt/sources.list
echo "# ${DEBIAN_DISTRO}-updates, previously known as 'volatile'" >> /etc/apt/sources.list
echo "deb http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.us.debian.org/debian/ ${DEBIAN_DISTRO}-updates main contrib non-free" >> /etc/apt/sources.list

# LiNode
echo "|- Updating /etc/apt/sources.list with LiNode"
echo "" >> /etc/apt/sources.list
echo "# LiNode" >> /etc/apt/sources.list
echo "deb http://apt.linode.com/ $DEBIAN_DISTRO main" >> /etc/apt/sources.list

# Wine Builds
if [[ $DESKTOP -eq 1 ]]; then
    echo "|- Updating /etc/apt/sources.list with Wine builds"
    echo "" >> /etc/apt/sources.list
    echo "# Wine Builds" >> /etc/apt/sources.list
    echo "deb https://dl.winehq.org/wine-builds/debian/ $DEBIAN_DISTRO main" >> /etc/apt/sources.list
fi
################### END /etc/apt/sources.list ###################

echo "* Performing apt-get update"
apt-get -y update

echo "* Installing Build-Essential"
apt-get -y install build-essential

echo "* Installing Git"
apt-get -y install git

echo "* Installing LLVM and Clang"
apt-get -y install llvm clang

echo "* installing boost"
apt-get -y install libboost-all-dev

echo "* Installing Vim-Gnome"
apt-get -y install vim-gnome

echo "* Installing Cmake"
apt-get -y install cmake

echo "* Installing Lua 5.3"
apt-get -y install lua5.3-dev lua5.3

echo "* Installing Web Tookit"
apt-get -y install witty witty-dev witty-doc witty-dbg witty-examples

echo "* Installing MPI"
apt-get -y install libopenmpi-dev

echo "* Installing LiNode CLI"
apt-get -y install linode-cli

echo "* Installing NSS"
apt-get -y install libnss3-dev

echo "* Installing Curl"
apt-get -y install libcurl4-nss-dev

echo "* Installing OpenSSL"
sudo apt-get install openssl

if [[ $DESKTOP -eq 1 ]]; then
    echo "* Installing Vim-YouCompleteMe"
    apt-get -y install vim-youcompleteme

    echo "* Installing GDB"
    apt-get -y install gdb
    
    echo "* Installing valgrind"
    apt-get -y install valgrind

    echo "* Installing OpenBLAS"
    sudo apt-get install libopenblas-dev

    echo "* Install JRE"
    apt-get -y install default-jre

    echo "* Installing gfortran"
    apt-get -y install gfortran

    echo "* Installing TeX-live"
    apt-get -y install texlive-full

    echo "* WmCtrl"
    apt-get -y install wmctrl
    
    echo "* Installing Qt"
    apt-get -y install qt5-default
    
    echo "* Installing FLTK"
    apt-get -y install fltk1.3-dev
    
    echo "* Installing GTKMM"
    apt-get -y install libgtkmm-3.0-dev libgtkmm-3.0-dev
    
    echo "* Installing Chromium"
    apt-get -y install chromium
    
    echo "* Installing xxdiff"
    apt-get -y install xxdiff
    
    echo "* Installing Vulkan"
    apt-get -y install libvulkan-dev vulkan-utils
    
    echo "* Installing Android Development Kit"
    apt-get -y install android-sdk
    
    echo "* Installing GLM/GLEW/GLFW"
    apt-get -y install libglm-dev
    apt-get -y install libglew-dev
    apt-get -y install libglfw3-dev
    
    echo "* Installing Nvidia Drivers and CUDA"
    apt-get -y install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//') 
    dpkg --add-architecture i386
    apt-get -y install firmware-linux nvidia-driver nvidia-settings nvidia-xconfig
    apt-get -y install nvidia-cuda-toolkit
    nvidia-xconfig
    
    echo "* Installing festival Text to Voice"
    apt-get install festival-dev festival-doc festvox-us*

    #./installAdept
fi

if [[ $SERVER -eq 1 ]]; then
    echo "* Installing NGINX"
    apt-get -y install nginx-full
    
    echo "* Installing pureFPTd"
    apt-get -y install pure-ftpd
    
    echo "* Installing mailutils"
    apt-get -y install mailutils
fi

apt-get -y upgrade

if [[ $SERVER -eq 1 ]]; then
    ./serverSetup.sh
fi


