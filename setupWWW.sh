#!/bin/bash
#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi


pushd . > /dev/null
SCRIPT_PATH="${BASH_SOURCE[0]}"
if ([ -h "${SCRIPT_PATH}" ]); then
  while([ -h "${SCRIPT_PATH}" ]); do cd `dirname "$SCRIPT_PATH"`; 
  SCRIPT_PATH=`readlink "${SCRIPT_PATH}"`; done
fi
cd `dirname ${SCRIPT_PATH}` > /dev/null
SCRIPT_PATH=`pwd`;
popd  > /dev/null

./chdata.sh
cd /data/www

echo "* Setting Up Hosting of Every Website in /data"

#if [[ -f /etc/nginx/sites-enabled/default ]]; then
   echo "|- Removing Existing Configurations"
   #rm -f /etc/nginx/sites-enabled/default
   rm -f /etc/nginx/sites-enabled/*
#fi



default_server="pradu.us"
for d in * ; do
    fullPath=$(readlink -f $d)
    if [[ -d $d/html ]]; then
        ssl_only=0
        have_ssl=0
        if [[ "${d:0:4}" == "ssl_" ]]; then
            ssl_only=1
            have_ssl=1
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
        echo "# Server" >> $fn
        echo "server {" >> $fn
        #echo "    rewrite_log on;" >> $fn
        if [[ ssl_only -eq 0 ]]; then
            if [[ $n == $default_server ]]; then
                echo "    listen 80 default_server;" >> $fn
                echo "    listen [::]:80 default_server;" >> $fn
            else
                echo "    listen 80;" >> $fn
                echo "    listen [::]:80;" >> $fn
            fi

            if [[ -f /data/www/$d/ssl.conf ]]; then
                if [[ $n == $default_server ]]; then
                    echo "    listen 443 ssl default_server;" >> $fn
                    echo "    listen [::]:443 ssl default_server;" >> $fn
                else
                    echo "    listen 443 ssl;" >> $fn
                    echo "    listen [::]:443 ssl;" >> $fn
                fi
                have_ssl=1
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
        echo "    server_name $n;"  >> $fn
        echo "    root /data/www/$d/html;" >> $fn
        echo "    index index.php index.html index.htm main.html main.htm;" >> $fn
        echo "    location / {" >> $fn
        echo "        try_files \$uri \$uri/ =404;" >> $fn
        echo "    }" >> $fn
        echo "    location ~ \\.php$ {" >> $fn
        echo "        include snippets/fastcgi-php.conf;" >> $fn
        echo "        fastcgi_pass unix:/run/php/php7.4-fpm.sock;" >> $fn
        echo "    }" >> $fn
        $SCRIPT_PATH/autohtaccess.sh $fullPath >> $fn
        echo "    location ~ /\\.ht {" >> $fn
        echo "        deny all;" >> $fn
        echo "    }" >> $fn
        echo "}" >> $fn
        if [[ ssl_only -eq 1 ]]; then
            echo "" >> $fn
            echo "# Redirects http to https" >> $fn
            echo "server {" >> $fn
            #echo "    rewrite_log on;" >> $fn
            echo "    listen 80;" >> $fn
            echo "    listen [::]:80;" >> $fn
            echo "    server_name $n;"  >> $fn
            echo "    return 301 https://$n\$request_uri;" >> $fn
            echo "}" >> $fn
        else
            if [[ have_ssl -eq 0 ]]; then
                echo "" >> $fn
                echo "# Redirects https to http" >> $fn
                echo "server {" >> $fn
                #echo "    rewrite_log on;" >> $fn
                echo "    listen 443 ssl;" >> $fn
                echo "    listen [::]:443 ssl;" >> $fn
                if [[ -f /data/www/$d/ssl.conf ]]; then
                    echo "    include /data/www/$d/ssl.conf;" >> $fn
                else
                    echo "    include snippets/snakeoil.conf;" >> $fn
                fi
                echo "    server_name $n;"  >> $fn
                echo "    return 301 http://$n\$request_uri;" >> $fn
                echo "}" >> $fn
            fi
        fi
        echo "" >> $fn
        echo "# Redirects www to no www" >> $fn
        echo "server {" >> $fn
        #echo "    rewrite_log on;" >> $fn
        echo "    listen 80;" >> $fn
        echo "    listen [::]:80;" >> $fn
        echo "    listen 443 ssl;" >> $fn
        echo "    listen [::]:443 ssl;" >> $fn
        if [[ -f /data/www/$d/ssl.conf ]]; then
            echo "    include /data/www/$d/ssl.conf;" >> $fn
        else
            echo "    include snippets/snakeoil.conf;" >> $fn
        fi
        echo "    server_name www.$n ;" >> $fn
        if [[ have_ssl -eq 1 ]]; then
            echo "    return 301 \$scheme://$n\$request_uri;" >> $fn
        else
            echo "    return 301 http://$n\$request_uri;" >> $fn
        fi
        echo "}" >> $fn
    fi
done

echo "* Restarting NGINX"
systemctl restart nginx
