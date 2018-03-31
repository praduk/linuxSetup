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
cd /data/www

echo "* Setting Up Hosting of Every Website in /data"

#if [[ -f /etc/nginx/sites-enabled/default ]]; then
   echo "|- Removing Existing Configurations"
   #rm -f /etc/nginx/sites-enabled/default
   rm -f /etc/nginx/sites-enabled/*
#fi

for d in * ; do
    if [[ -d $d/html ]]; then
        ssl_only=0
        if [[ "${d:0:4}" == "ssl_" ]]; then
            ssl_only=1
            n=${d:4}
            echo "|- Setting up $n restricted to SSL"
        else
	    n=$d
            echo "|- Setting up $n"
	fi
        fn=/etc/nginx/sites-enabled/$n
        echo "# $n Server Configuration" > $fn
        echo "" >> $fn
        echo "" >> $fn

        echo "server {" >> $fn
	if [[ ssl_only -eq 0 ]]; then
            echo "    listen 80;" >> $fn
            echo "    listen [::]:80;" >> $fn
	    if [[ -f /data/www/$d/ssl.conf ]]; then
                echo "    listen 443 ssl;" >> $fn
                echo "    listen [::]:443 ssl;" >> $fn
	        echo "    include /data/www/$d/ssl.conf;" >> $fn
	    fi
        else
            echo "    listen 443 ssl;" >> $fn
            echo "    listen [::]:443 ssl;" >> $fn
	    if [[ -f /data/www/$d/ssl.conf ]]; then
	        echo "    include /data/www/$d/ssl.conf;" >> $fn
            else
	        echo "    include snippets/snakeoil.conf;" >> $fn
	    fi
	fi
        echo "    server_name $n www.$n;" >> $fn
        echo "    root /data/www/$d/html;" >> $fn
        echo "    index index.html index.htm main.html main.htm;" >> $fn
        echo "    location / {" >> $fn
        echo "        try_files $uri $uri/ =404;" >> $fn
        echo "    }" >> $fn
        echo "}" >> $fn
    fi
done

echo "* Restarting NGINX"
systemctl restart nginx
