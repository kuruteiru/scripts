#!/bin/sh

show_help() {
	printf '%s\n' \
		"Usage: $0 [-r] [directory]" \
		"" \
		"Options:" \
		"  -r           Rename files recursively in subdirectories" \
		"  -h           Show this help message" \
		"" \
		"Description:" \
		"  Renames all files in the specified directory (default: current)" \
		"  to lowercase snake_case, preserving extensions." 
	exit 0
}

recursive=0
dir="."

while [ $# -gt 0 ]; do
	case "$1" in
		-r) recursive=1 ;;
		-h) show_help ;;
		-*) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
		*) dir=$1 ;;
	esac
	shift
done

find_cmd="find \"$dir\""
[ "$recursive" -eq 0 ] && find_cmd="$find_cmd -maxdepth 1"
find_cmd="$find_cmd -type f"

eval "$find_cmd" | while IFS= read -r file; do
	dn=$(dirname "$file")
	bn=$(basename "$file")
	case "$bn" in
		*.*) name=${bn%.*}; ext=.${bn##*.} ;;
		*)   name=$bn;        ext=   ;;
	esac
	ns=$(printf '%s\n' "$name" \
	| sed 's/\([[:lower:][:digit:]]\)\([[:upper:]]\)/\1_\2/g' \
	| tr '[:upper:]' '[:lower:]' \
	| sed 's/[^a-z0-9]\+/_/g; s/^_//; s/_$//')
	new="$dn/$ns$ext"
	[ "$file" != "$new" ] && mv -- "$file" "$new"
done
