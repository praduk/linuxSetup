#!/bin/bash

mkdir -p ~/mycroft
cd ~/mycroft
echo "In ~/install/mycroft"
git clone -b master --depth=1 https://github.com/MycroftAI/mycroft-core.git .
cd ~/mycroft
./dev_setup.sh
