#!/bin/sh

defualt_lang="xkb:us::eng"
current_lang=$(ibus engine)
alter_lang="xkb:il::heb"
selected_lang="$defualt_lang"

if [ "$defualt_lang" = "$current_lang" ] ; then
    selected_lang="$alter_lang"
fi

ibus engine $selected_lang
