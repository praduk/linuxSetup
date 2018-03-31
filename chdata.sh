#!/bin/bash
#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

echo "* Setting Permissions on /data"
mkdir -p /data/www
chgrp -R data /data
chown -R data /data
chmod -R u+rwX,g+rwX,o-rwx /data
