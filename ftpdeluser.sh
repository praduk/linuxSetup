#!/bin/bash
# ftpadduser <name>

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

if [[ $# < 1 ]]; then
   echo "ftpdeluser <name>"
   exit 1
fi

pure-pw userdel $1
