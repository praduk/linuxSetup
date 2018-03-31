#!/bin/bash

cd $HOME
rm -rf adept
mkdir adept
cd adept
git clone git://github.com/rjhogan/Adept-2.git .

autoreconf -i
./configure
make
make install

cd $HOME
rm -rf adept
