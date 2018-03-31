#!/bin/bash

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

# Create Data User and Group
if [ "$(getent passwd data)" == "" ]; then
    echo "* Adding user 'data'"
    useradd -g data data
fi

if [ "$(getent passwd data)" != "" ]; then
    echo "* Adding user 'www-data' to group 'data'"
    usermod -a -G data www-data
fi

./setupWWW.sh
