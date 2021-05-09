#!/bin/bash

MSG="Do you wnat to shutdown ?"
CONFIRM=$(printf "No\nReboot\nYes" | rofi -dmenu -multi-select -no-custom -p "$MSG")
RETV="$?"

if [  "$RETV" != "0" ] ; then
    exit $RETV
fi

if [ "$CONFIRM" == "Reboot" ] ; then
    sudo reboot
fi

if [ "$CONFIRM" == "Yes" ] ; then
    sudo poweroff
fi
