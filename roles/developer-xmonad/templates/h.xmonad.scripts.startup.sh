#!/bin/sh

kill_if_runing () {
    tPID=$(pidof $1)

    if [ "$tPID" != "" ] ; then
        kill $tPID
    fi
} 

kill_if_runing trayer

(
    sleep 10 && (
       (kill_if_runing xfce4-power-manager &&   xfce4-power-manager) &
       (kill_if_runing xfce4-clipman       &&   xfce4-clipman ) & 
       (kill_if_runing nm-applet           &&   nm-applet) &       
     )
) &

(
    (kill_if_runing xscreensaver && xscreensaver -no-splash ) &
    (kill_if_runing picom && picom --experimental-backends ) &
    ~/.xmonad/scripts/random-bg.sh ~/Pictures/bg/ &
) &
trayer --edge bottom --align right --SetDockType true --SetPartialStrut true --expand true --width 8 --transparent true --tint 0xF0F0F0 --alpha 0 --height 17 --monitor primary --alpha 90 




