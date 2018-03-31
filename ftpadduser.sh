#!/bin/bash
# ftpadduser <name> <password> <directory> 

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

if [[ $# < 3 ]]; then
   echo "ftpadduser <name> <password> <directory>" 
   exit 1
fi

(echo $2; echo $2) | pure-pw useradd $1 -u data -d $3
pure-pw mkdb
systemctl restart pure-ftpd
