#!/bin/bash

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

# Create Data User and Group
if [ "$(getent group data)" == "" ]; then
    echo "* Adding group 'data'"
    groupadd data
fi

if [ "$(getent passwd data)" == "" ]; then
    echo "* Adding user 'data'"
    useradd -g data data
    chsh -s /bin/bash data
fi

if [ "$(getent passwd www-data)" != "" ]; then
    echo "* Adding user 'www-data' to group 'data'"
    usermod -a -G data www-data
fi

./setupWWW.sh

echo "* Configuring Pure FTP-D"
id -u data > /etc/pure-ftpd/conf/MinUID
rm -f /etc/pure-ftpd/auth/50pure
ln -s /etc/pure-ftpd/conf/PureDB /etc/pure-ftpd/auth/50pure
echo no > /etc/pure-ftpd/conf/PAMAuthentication
echo no > /etc/pure-ftpd/conf/UnixAuthentication
