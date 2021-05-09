#!/bin/bash

CURRENT_PATH="$(dirname $(readlink -f $0))"
cts=$(date +"%y%m-%s")

echo "Current path $CURRENT_PATH"

for sf in `find "$CURRENT_PATH/home" -type f` ; do
	
	sfd="$HOME/${sf##$CURRENT_PATH/home/}"
	sfd_base=$(dirname "$sfd")

	if [ ! -d "$sfd_base" ] ; then
		mkdir -p "$sfd_base"
	fi

	if [ -f "$sfd" ] || [ -L "$sfd" ] ; then
		echo "Exists file $sfd making backup $sfd.bkup.$cts"
		mv "$sfd" "$sfd.bkup.$cts"
	fi

	echo "linking $sf to $sfd"
	ln -s "$sf" "$sfd"
done
