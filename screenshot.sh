#!/bin/bash

AREA=$(slurp)
if [ -z "$AREA" ]; then
  echo "No area selected. Exiting."
  exit 1
fi

DEFAULT_NAME="screenshot_$(date '+%d-%m-%Y_%H:%M:%S').png"
DEFAULT_PATH="$HOME/images/screenshots/$DEFAULT_NAME"

mkdir -p "$HOME/images/screenshots"

FILE=$(kdialog --getsavefilename "$DEFAULT_PATH" "*.png")
if [ -z "$FILE" ]; then
  echo "No file selected. Exiting."
  exit 1
fi

grim -g "$AREA" "$FILE"
