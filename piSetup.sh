#!/bin/bash

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

# Audio Players
apt-get install -qq -y mpg123 mpg321
