#!/bin/bash
cd ~
mv .bashrc .bashrc_orig
git init
git remote add origin git@github.com:praduk/private.git
git pull origin master
