#!/bin/sh

usage() {
    echo "Usage: $0 [OPTION]... APP_NAME [ALIAS]"
}

help() {
    usage
    echo
    echo "This script creates a symbolic link for a Flatpak application in /usr/bin."
    echo
    echo "Options:"
    echo "  -v        Enable verbose output. Displays detailed information about the app."
    echo "  -f        Forces the creation of the symbolic link, even if an existing link exists."
    echo "  -h        Show this help page."
    echo
    echo "Arguments:"
    echo "  app_name  The name of the Flatpak application to link."
    echo "  alias     (Optional) The alias for the symbolic link. If not provided, the app_name is used."
    echo
    echo "Example usage:"
    echo "  $0 -v app_name        # Verbose output for app_name"
    echo "  $0 -vf app_name alias # Force the link creation with verbose output"
}

if [ "$#" -eq 0 ]; then
    echo "No arguments given"
    exit 1
fi

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
    echo "This script needs root privileges"
    exit 1
fi

shift $((OPTIND - 1))

if [ "$#" -lt 1 ]; then
    usage
    exit 1
fi

app_name="$1"
app_alias="${2:-"$app_name"}"
app_path=$(find /var/lib/flatpak/exports/bin -iname "*$app_name*")

if [ -z "$app_path" ]; then
    echo "Flatpak app not found"
    exit 1
fi

if [ $(echo "$app_path" | wc -l) -gt 1 ]; then
    echo "Multiple Flatpak apps match provided name:"
    count=1
    for app in $app_path; do
        echo "$count. $(basename $app)"
        count=$((count + 1))
    done
    read -p "Select app: " choice
    app_path=$(echo "$app_path" | sed -n "${choice}p")
fi

if [ "$force" -eq 0 ] && [ -e "/usr/bin/$app_alias" ]; then
    echo "Symbolic link /usr/bin/$app_alias already exists. Use -f to force overwriting."
    exit 1
fi

ln "-s$options" "$app_path" /usr/bin/"$app_alias"

exit 0
