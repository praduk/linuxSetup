#!/bin/bash
# ftpasswd <name> <password>

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

if [[ $# < 2 ]]; then
   echo "ftppasswd <name> <password>" 
   exit 1
fi

pure-pw passwd $2 $1
pure-pw mkdb
