#!/bin/sh

source_ids=$(pactl list short sources | cut -f 1)
for id in $source_ids; do
	pactl set-source-mute $id 1
done
