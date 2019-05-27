#!/bin/bash

#SPEAKERID=B8:B3:DC:3B:A8:CD
#
#function bluetoothcmds()
#{
#    sleep 3
#    echo "power on"
#    sleep 1
#    echo "agent on"
#    sleep 1
#    echo "default-agent"
#    sleep 1
#    echo "trust $SPEAKERID"
#    sleep 1
#    echo "connect $SPEAKERID"
#    sleep 5
#}
#
#bluetoothcmds | bluetoothctl

#Setup TouchScreen
export DISPLAY=:0
xhost +local:
if ! xinput --set-prop 'ADS7846 Touchscreen' 'Coordinate Transformation Matrix' -1, 0, 1, 0, 1, 0, 0, 0, 1
then
    exit 1
fi

#Run GUI
python ~/linuxSetup/gui.py &

#Unclutter cursor
unclutter -idle 0 &

#Mycroft
~/mycroft/start-mycroft.sh all

#Turn off Screensaver
xset s off
xset -dpms
xset s noblank

#Constant "Quiet"
while true; do
    aplay /usr/local/share/veryQuiet.wav
done


return 0
