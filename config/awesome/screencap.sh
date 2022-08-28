#!/usr/bin/env bash
scrot -o -s /dev/stdout | xclip -selection clipboard -t image/png
