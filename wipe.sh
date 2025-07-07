#!/bin/sh

check_privilages() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "this script needs root privilages, run: sudo $0" >&2
        return 1
    fi
    return 0
}

check_devices() {
    for arg in "$@"; do
        dev="/dev/$arg"
        if [ ! -b "$dev" ]; then
            echo "$dev doesn't exist" >&2
            return 1
        fi
    done 
    return 0
}

wipe() {
    for arg in "$@"; do
        dev="/dev/$arg"
        # sudo dd if=/dev/zero of="$dev" bs=10M status=progress
        sudo wipefs -a "$dev"
        # sudo parted "$dev" mklabel gpt
        # sudo parted -a optimal "$dev" mkpart primary ext4 0% 100%
        sudo mkfs.ext4 "$dev"
    done
    return 0
}

if ! check_privilages; then
    exit 1
fi

if ! check_devices "$@"; then
    exit 1
fi

wipe "$@"

# test

echo "success"
exit 0
