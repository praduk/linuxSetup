#!/bin/bash
root=$*
for f in $(find $root -name ".htpasswd")
do
    path=/$(realpath --relative-to="$root" "$f")
    echo "    location $(dirname $path) {"
    echo '        auth_basic "Administrator Login";'
    echo "        auth_basic_user_file $root$path;"
    echo "    }"
done
