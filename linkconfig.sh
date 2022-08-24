#!/bin/bash
for d in config/*/ ;  do
    relpath=$(realpath --relative-to="config" $d)
    rm -rf ${HOME}/.config/$relpath
    ln -s $(realpath $d) ${HOME}/.config/$relpath 
done
