#!/bin/bash

SPEAKERID=B8:B3:DC:3B:A8:CD

function bluetoothcmds()
{
    sleep 3
    echo "power on"
    sleep 1
    echo "agent on"
    sleep 1
    echo "default-agent"
    sleep 1
    echo "trust $SPEAKERID"
    sleep 1
    echo "connect $SPEAKERID"
    sleep 5
}

bluetoothcmds | bluetoothctl

exit 0
