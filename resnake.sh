#!/bin/sh

# this was vibe coded so there's no guarantee that it will work correctly

show_help() {
	printf '%s\n' \
		"Usage: $0 [-r] path" \
		"" \
		"Options:" \
		"  -r    Recursive when path is a directory" \
		"  -h    Show this help message" \
		"" \
		"Behavior:" \
		"  If 'path' is a file it will be renamed. If not a file and" \
		"  'path' is a directory, files inside that directory will be" \
		"  renamed (non-recursive by default)."
	exit 0
}

recursive=0
path=""

while [ $# -gt 0 ]; do
	case "$1" in
		-r) recursive=1 ;;
		-h) show_help ;;
		-*) printf 'Unknown option: %s\n' "$1" >&2; exit 1 ;;
		*) path=$1 ;;
	esac
	shift
done

if [ -z "$path" ]; then
	printf 'Missing path. Usage: %s [-r] path\n' "$0" >&2
	exit 2
fi

if [ -f "$path" ]; then
	process_single_file() {
		item=$1
		dn=$(dirname "$item")
		bn=$(basename "$item")
		case "$bn" in
			?*.*) name=${bn%.*}; ext=.${bn##*.} ;;
			*)    name=$bn;        ext= ;;
		esac
		ns=$(printf '%s\n' "$name" \
			| sed -e 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' \
			      -e 's/\([[:lower:][:digit:]]\)\([[:upper:]]\)/\1_\2/g' \
			| tr '[:upper:]' '[:lower:]' \
			| sed 's/[^a-z0-9]\+/_/g; s/^_//; s/_$//')
		new="$dn/$ns$ext"
		if [ "$item" = "$new" ]; then
			printf 'No change: %s\n' "$item"
			return
		fi
		if [ -e "$new" ]; then
			printf 'Target exists, skipping: %s -> %s\n' "$item" "$new" >&2
			return
		fi
		mv -- "$item" "$new"
		printf 'Renamed: %s -> %s\n' "$item" "$new"
	}

	process_single_file "$path"
	exit 0
fi

if [ -d "$path" ]; then
	find_cmd="find \"$path\""
	[ "$recursive" -eq 0 ] && find_cmd="$find_cmd -maxdepth 1"
	find_cmd="$find_cmd -type f"
	eval "$find_cmd" | while IFS= read -r file; do
		dn=$(dirname "$file")
		bn=$(basename "$file")
		case "$bn" in
			?*.*) name=${bn%.*}; ext=.${bn##*.} ;;
			*)    name=$bn;        ext= ;;
		esac
		ns=$(printf '%s\n' "$name" \
			| sed -e 's/\([[:upper:]]\)\([[:upper:]][[:lower:]]\)/\1_\2/g' \
			      -e 's/\([[:lower:][:digit:]]\)\([[:upper:]]\)/\1_\2/g' \
			| tr '[:upper:]' '[:lower:]' \
			| sed 's/[^a-z0-9]\+/_/g; s/^_//; s/_$//')
		new="$dn/$ns$ext"
		if [ "$file" = "$new" ]; then
			printf 'No change: %s\n' "$file"
			continue
		fi
		if [ -e "$new" ]; then
			printf 'Target exists, skipping: %s -> %s\n' "$file" "$new" >&2
			continue
		fi
		mv -- "$file" "$new"
		printf 'Renamed: %s -> %s\n' "$file" "$new"
	done
	exit 0
fi

printf 'No such file or directory: %s\n' "$path" >&2
exit 3
