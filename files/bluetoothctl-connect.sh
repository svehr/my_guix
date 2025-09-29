#!/bin/sh

device_mac="$(bluetoothctl devices Paired | dmenu | cut -f 2 -d ' ')"
bluetoothctl connect "$device_mac"
