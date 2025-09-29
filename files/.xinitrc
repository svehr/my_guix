#!/bin/sh

test -f ~/.Xresources && xrdb -merge ~/.Xresources

brightnessctl set 1000

# disable bell
set bell-style none
xset b off

# turn off screensaver and dpms
xset s off -dpms

keyboard_setup.sh
monitor_setup.sh

exec stumpwm
