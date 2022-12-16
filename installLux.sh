#!/bin/bash
cd /tmp
git clone https://github.com/Ventto/lux.git
cd lux
sudo make install
sudo lux
cd ..
rm -rf lux
