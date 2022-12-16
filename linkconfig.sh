#!/bin/bash
for d in config/*/ ;  do
    relpath=$(realpath --relative-to="config" $d)
    rm -rf ${HOME}/.config/$relpath
    ln -s $(realpath $d) ${HOME}/.config/$relpath 
done
rm -f "${HOME}/.xmonad"
ln -s $(realpath xmonad) "${HOME}/.xmonad"
ln -s $(realpath xmobarrc) "${HOME}/.xmobarrc"
ln -s $(realpath xsessionrc) "${HOME}/.xsessionrc"
