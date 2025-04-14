#!/bin/bash

print_usage()
{
	echo "m3uconv [mode] [command]"
	echo ""
	echo "convert: convert a file to m3u format:"
	echo "    - cmus: generates m3u files from cmus playlist files found"
	echo "        in ~/.config/cmus/playlists/"
	echo ""
	echo "create: Create an m3u from paths loaded from stdin."
}

progress_bar()
{
    let progress=(${1}*100/${2}*100)/100
    let done=(${progress}*4)/10
    let left=40-$done
    fill=$(printf "%${done}s")
    empty=$(printf "%${left}s")
	printf "\r[${fill// /#}${empty// /-}] ${progress}%%"
}

check_dependencies()
{
	echo -n "Checking dependencies..."
	status=0

	for cmd in ffmpeg awk grep; do
        if ! command -v "$cmd" >/dev/null; then
			if [ $status -eq 0 ]; then
				echo ""
				echo "missing: $cmd"
			else
				echo "missing: $cmd"
			fi
            missing=1
        fi
    done

	if [ $status -eq 0 ]; then
		echo " ok"
	fi

	return $status
}

extract_meta()
{
	ffmpeg -i "$1" 2>&1 | grep "$2" | head -n 1 | cut -d: -f2- | awk '{$1=$1};1'
	return $?
}

CWD=$(pwd)
set -o pipefail

if [ $# -lt 1 ]; then
	echo "error: expected at least one argument!"
	echo ""
	print_usage
	exit 1
elif [ $# -gt 2 ]; then
	echo "error: expected at most two arguments!"
	echo ""
	print_usage
	exit 1
else
	i=1
	for arg in "$@"; do
		if [ $i -eq 1 ]; then
			MODE=$arg
		elif [ $i -eq 2 ]; then
			COMMAND=$arg
		fi
		((i++))
	done
fi

check_dependencies
if [ $? -ne 0 ]; then
    echo "Some dependency checks have failed!"
    exit 1
fi

if [ $MODE == "convert" ]; then # CONVERT
	echo "This mode is currently a WIP."
	exit 0
	if [[ $COMMAND == "cmus" ]]; then # CONVERT CMUS
		exit 0
	elif [[ $COMAMND == "" ]]; then
		echo "error: expected a command for $MODE"
		echo ""
		print_usage
		exit 1
	else
		echo "error: unknown command for $MODE"
		echo ""
		print_usage
		exit 1
	fi

elif [ $MODE == "create" ]; then # CREATE
	echo "Creating a playlist from provided paths..."

	# Ensure all the variables are set:
	if [[ $playlist_name == "" ]]; then
		playlist_name=$(basename "$(pwd)")
		playlist_name=${playlist_name,,}
	fi
	if [[ $output == "" ]]; then
		output="$playlist_name.m3u"
	fi

	echo "#EXTM3U" > $output
	echo "#PLAYLIST:$playlist_name" >> $output 

	while read file; do
		if [ ! -e "$file" ]; then
			echo "error: file '$file' does not exist!"
		elif [[ -n "$file" ]]; then
			files+="$file"$'\n'
		fi
	done
	files="${files%$'\n'}"
	max=$(echo "$files" | wc -l)

	echo -e "$files" | while IFS= read -r file; do
		result=0
		title=$(extract_meta "$file" "title")
		(( result += $? ))
		artist=$(extract_meta "$file" "artist")
		(( result += $? ))
		genre=$(extract_meta "$file" "genre")
		(( result += $? ))

		if [ $result -ne 3 ]; then
			echo "failed extracting metadata from '$file'"
			continue
		fi
		echo "#EXTLAB:$title" >> $output
		echo "#EXTART:$artist" >> $output
		echo "#EXTGEN:$genre" >> $output
		echo "$file" >> $output

		progress_bar $i $max
		((i++))
	done
	exit 0
else
	echo "error: unknown mode!"
	echo ""
	print_usage
	exit 1
fi
