#!/bin/bash

#Check root privilages
if [[ $EUID -ne 0 ]]; then
   echo "This script needs root privilages." 
   exit 1
fi

# Audio Players
apt-get install -qq -y mpg123 mpg321
apt-get install -qq -y --no-install-recommends pulseaudio pulseaudio-module-bluetooth bluez-tools bluez
hcitool cmd 0x3F 0x01C 0x01 0x02 0x00 0x01 0x01

adduser root pulse-access
adduser pradu pulse-access
useradd -g bluetooth pulse

pip install lifxlan
pip install suntime
apt-get install lightdm unclutter python-tk


cd ~
rm -rf LCD-show
git clone https://github.com/goodtft/LCD-show.git
cd LCD-show
chmod -R 755 LCD-show
./LCD35-show

echo "dtparam=act_led_trigger=none" >> /boot/config.txt
echo "dtparam=act_led_activelow=off" >> /boot/config.txt
echo "dtparam=pwr_led_trigger=none" >> /boot/config.txt
echo "dtparam=pwr_led_activelow=off" >> /boot/config.txt
echo "dtoverlay=piscreen,speed=16000000,rotate=90" >> /boot/config.txt


# Authorize PulseAudio - which will run as user pulse - to use BlueZ D-BUS interface:
############################################################################
#cat <<EOF >/etc/dbus-1/system.d/pulseaudio-bluetooth.conf
#<busconfig>
#
#  <policy user="pulse">
#    <allow send_destination="org.bluez"/>
#  </policy>
#
#</busconfig>
#EOF
############################################################################
#### SEE https://github.com/davidedg/NAS-mod-config/blob/master/bt-sound/bt-sound-Bluez5_PulseAudio5.txt
###########################################################################
