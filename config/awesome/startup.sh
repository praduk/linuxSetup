#!/usr/bin/env bash
sleep 0.5
function run {
    if ! command -v $1 &> /dev/null
    then
        echo "$1 could not be found"
        return 1
    fi
    if ! pgrep -f $1 ;
    then
        $@&
    fi
}

# Keyboard Repeat Rates
run xset r rate 150 50 &
# Policy kit (needed for GUI apps to ask for password)
# run /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
# Computer Specific Settings
run $HOME/.config/awesome/settings_$(uname -n).sh &
# Start compositor
# run picom --experimental-backend &
# sxhkd Hotkeys
#run sxhkd &
# Start Volume Control applet
#run volctl &
# Start Network Manager Applet 
#run nm-applet &
# Set Numlock key to active.
#run numlockx &
# Screensaver
#run xscreensaver -no-splash &
# Pamac system update notifications
#run pamac-tray &
# Start Dropbox
#run dropbox &
# Bluetooth
#run blueman-tray &
# MPD
#run mpd ~/.config/mpd/mpd.conf &
# Unclutter - (hides mouse pointer after 5 seconds of inactivity)
#run unclutter &
