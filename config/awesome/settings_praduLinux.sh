#!/bin/sh

# Display
xrandr --output HDMI-0 --mode 3840x2160 --rate 120

# Audio Setup
pacmd set-default-sink alsa_output.usb-Generic_USB_Audio-00.analog-stereo 

# Background
feh --bg-scale backgrounds/kuiper.png
