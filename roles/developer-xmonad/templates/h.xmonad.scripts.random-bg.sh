#!/bin/sh

SLEEP_T=50
PICS=$1

while true; do
	F=$(find $PICS -type f  | sort -R | tail -1)
	echo "Changing background to $F"
	feh --bg-fill "$F"
	sleep $SLEEP_T;
done
