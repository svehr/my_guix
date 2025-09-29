#!/bin/sh

setxkbmap -layout us -variant altgr-intl

# enable sticky keys; do not enable 'twokey' or 'latchlock' options
xkbset sticky -twokey -latchlock
