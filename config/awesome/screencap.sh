#!/usr/bin/env bash
sleep 0.1
scrot -o -s /dev/stdout | xclip -selection clipboard -t image/png
