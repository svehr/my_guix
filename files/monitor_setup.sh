#!/bin/sh
# NOTE: it does not work the same when merged into 1 command
# TODO: why?
# xrandr --output HDMI-A-0 --left-of eDP --scale 1.5x1.5
monitor="$(xrandr | grep  ' connected' | cut -d ' ' -f 1 | sed '2!d')"
if [ -n "$monitor" ]; then
    echo "external monitor: $monitor"
    xrandr --output "$monitor" --mode 1920x1080 --left-of eDP --scale 1.5x1.5
fi
xrandr --output eDP --pos +2880x0 --primary
