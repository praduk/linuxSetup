#!/bin/bash
pullServer /data/music
pullServer /data/mycroft
cd ~/linuxSetup
git pull
cd /opt/mycroft/skills/pradu-skill.praduk/
git pull
#reboot
