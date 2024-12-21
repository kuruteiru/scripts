#!/bin/sh

usage() {
    echo "Usage: $0 [OPTION]... FILE..."
}

help() {
    usage
}

options=""
verbose=0
force=0

while getopts "hvf" opt; do
    case "$opt" in
        h)
            help
            exit 0
            ;;
        v) 
            verbose=1
            options="$options$opt"
            ;;
        f) 
            force=1
            options="$options$opt"
            ;;
        ?) 
            usage
            exit 1
            ;;
    esac
done

if [ -z "$SUDO_USER" ] || { [ -n "$EUID" ] && [ "$EUID" -ne 0 ]; }; then
    if [ "$verbose" -eq 1 ]; then
        echo "This script needs root privileges"
    fi
    exit 1
fi

shift $((OPTIND - 1))

scripts_dir="$(cd "$(dirname $0)" && pwd -P)"
script_name="$scripts_dir"/$(basename "$0")
files=$(ls "$scripts_dir" | grep -v $(basename "$0"))

# todo:
# add support for installing individual files?

for file in $files; do
    file_alias="${file%.*}"
    if [ "$force" -eq 0 ] && [ -e "/usr/bin/$file_alias" ]; then
        if [ "$verbose" -eq 1 ]; then
            echo "Symbolic link /usr/bin/$file_alias already exists. Use -f to force overwriting."
        fi
        continue
    fi
    ln "-s$options" "$scripts_dir"/$file /usr/bin/"$file_alias"
done

exit 0
