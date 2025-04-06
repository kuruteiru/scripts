#!/bin/sh

AREA=$(slurp)
[ -z "$AREA" ] && exit 1

DEFAULT_NAME="screenshot_$(date '+%d-%m-%Y_%H:%M:%S').png"
FILE=$(zenity --file-selection --save --confirm-overwrite --filename="$HOME/images/screenshots/$DEFAULT_NAME")
[ -z "$FILE" ] && exit 1

grim -g "$AREA" "$FILE"
