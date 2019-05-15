#!/bin/bash

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

apt-get -qq -y install libusb-1.0.0-dev

git clone https://github.com/todbot/blink1-tool.git
cd blink1-tool
make
make install
cd ..
rm -rf blink1-tool
chmod a+s $(which blink1-tool)
