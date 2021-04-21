#!/bin/sh

PIDFILE="~/.xmonad/background.pid" 

if [ -f "$PIDFILE" ] ; then
  OLDPID=$(cat "$PIDFILE")

  if ! kill $OLDPID > /dev/null 2>&1; then
      echo "Could not send SIGTERM to process $pid" >&2
  fi
fi

echo "$$" > $PIDFILE

SLEEP_T=50
PICS=$1

while true; do
	F=$(find $PICS -type f  | sort -R | tail -1)
	echo "Changing background to $F"
	feh --bg-fill "$F"
	sleep $SLEEP_T;
done
