#!/bin/sh

# Display
#xrandr --output HDMI-0 --mode 3840x2160 --rate 120
xrandr --output HDMI-0 --mode 3840x2160 --rate 144

# Audio Setup
pacmd set-default-sink alsa_output.usb-Generic_USB_Audio-00.analog-stereo 

# Background
feh --bg-scale ${HOME}/.config/awesome/backgrounds/kuiper.png
