#!/bin/sh

main() {
	if ! check_privilages; then
	    exit 1
	fi
	
	if [ "$#" -le 0 ]; then
		echo "no block device specified" >&2
		exit 1
	fi

	if ! check_devices "$@"; then
		exit 1
	fi

	wipe_all "$@"
}

check_privilages() {
	if [ "$(id -u)" -ne 0 ]; then
		echo "this script needs root privilages, run: sudo $0" >&2
		return 1
	fi
	return 0
}

check_devices() {
	for arg in "$@"; do
		dev="$(device_path "$arg")"
		if [ ! -b "$dev" ]; then
			echo "$dev doesn't exist" >&2
			return 1
		fi
	done 
	return 0
}

device_name() {
	case "$1" in
		"/mnt/"*) name="${arg#"/mnt/"}" ;;
		"/dev/"*) name="${arg#"/dev/"}" ;;
		*) name="$arg" ;;
	esac
	echo "$name"
}

device_path() {
	name="$(device_name "$1")"
	echo "/dev/$name"
}

device_mountpoint() {
	name="$(device_name "$1")"
	echo "/mnt/$name"
}

# wip
umount_disk() {
	path="$(device_path "$1")"

	for part in $path*; do
		echo "$part"
	done

	# get mountpoints and unmount them all wip
	mountpoint="$(device_mountpoint "$1")"
	mountpoints="$(grep -i "^$path[[:blank:]]" /proc/mounts)"
	if [ -n  "$mountpoints" ]; then
		echo "$path is mounted"
		umount "$mountpoint"
	fi
}

# wip
wipe_disk() {
	echo "wipe"
	# dd if=/dev/zero of="$path" bs=10M status=progress
	wipefs -a "$path"
	
	echo "gpt"
	parted "$path" mklabel gpt

	echo "part"
	parted -a optimal "$path" mkpart primary ext4 0% 100%

	echo "fs"
	mkfs.ext4 "${path}1"

	echo "mount"
	mount "$path" "$mountpoint"
	
	return 0
}

wipe_all() {
	for arg in "$@"; do
		wipe_disk "$arg" &
		wait
	done
	return 0
}

main "$@"
exit 0
