#!/bin/bash

app_name=$1

if [ $app_name == "" ]; then
	echo "no argument given"
else
	echo "app name: $app_name"
fi

for $arg in $@
do
	case $arg in
		"-v")
			echo "verbose"
			;;
		*)
			echo "invalid argument"
			;;
done

app_path=`find /var/lib/flatpak/exports/bin -iname "*$app_name*"`
a=`ls /var/lib/flatpak/exports/bin | grep *$app_name*`

echo "app path: $app_path"
echo "a: $a"

sudo ln -s /var/lib/flatpak/exports/bin/com.spotify.Client /usr/bin/spotify
