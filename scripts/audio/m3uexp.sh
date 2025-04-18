#!/bin/bash

BOLD_WHITE="\033[1;37m"
BLUE="\033[34m"
YELLOW="\033[33m"
RED="\033[31m"
ESC="\033[0m"

info()
{
	if [[ "$2" == *"\\r"* ]]; then
        echo -en "\r\033[K"
    fi
	echo -e${3} "${2}${BOLD_WHITE}[${ESC}${BLUE}i${ESC}${BOLD_WHITE}]${ESC} ${1}" >&2
}

warning()
{
	if [[ "$2" == *"\\r"* ]]; then
        echo -en "\r\033[K"
    fi
	echo -e${3} "${2}${BOLD_WHITE}[${ESC}${YELLOW}W${ESC}${BOLD_WHITE}]${ESC} ${1}" >&2
}

error()
{
	if [[ "$2" == *"\\r"* ]]; then
        echo -en "\r\033[K"
    fi
	echo -e${3} "${2}${BOLD_WHITE}[${ESC}${RED}E${ESC}${BOLD_WHITE}]${ESC} ${1}" >&2
}

print_usage()
{
	echo "m3uconv [mode] [command] [args]"
	echo ""
	echo "modes:"
	echo "  export: Pack playlists and audio files to a tarball"
	echo "    cmus: Use cmus playlists as the source"
	echo ""
	echo "  import: Import data from a tarball"
	echo "    cmus: Import the playlists to cmus"
	echo ""
	echo "  create: Create an m3u playlist from a list of paths"
	echo ""
	echo "args:"
	echo "  --help: Show this help message"
}

# Print a progress bar
progress_bar()
{
    let progress=(${1}*100/${2}*100)/100
    let done=(${progress}*4)/10
    let left=40-$done
    fill=$(printf "%${done}s")
    empty=$(printf "%${left}s")
	printf "\r[${3}/${4}] [${fill// /#}${empty// /-}] ${progress}%%" >&2
}

file_accessible()
{
	file="$1"
	if [ -e "$file" ]; then
		if [[ -n "$file" ]]; then
			return 0
		else
			error "File '$file' is empty!" "\r"
		fi
	else
		return 2
	fi
	return 1
}

check_dependencies()
{
	info "Checking dependencies..." "" "n"
	status=0

	for cmd in ffprobe grep awk head cut pwd cd ls cat date hostname basename dirname; do
        if ! command -v "$cmd" >/dev/null; then
			if [ $status -eq 0 ]; then
				echo ""
				error "missing: $cmd"
			else
				error "missing: $cmd"
			fi
            status=1
        fi
    done

	if [ $status -eq 0 ]; then
		echo " ok"
	fi

	return $status
}

# Get a single m3u entry from path
get_m3u_entry() {
    file="$1"
	prepend="$2"
	
	file_accessible "$1"
	status="$?"
	if [ $status -eq 2 ]; then
		return 1
	elif [ $status -ne 0 ]; then
		error "File not accessible!"
		return 1
	fi

	out=$(ffprobe -v error -hide_banner -show_format -show_streams -threads $(nproc) "$file" 2>&1)
	status="$?"
    if [ $status -ne 0 ]; then
		if [[ "$out" == *"Invalid data found when processing input"* ]]; then
			warning "Likely not an audio file: '$file'                     " "\r"
			return 1
		fi
		error "Failed extracting some metadata from '$file'" "\r"
        return 1
	fi

    title=$(echo "$out" | grep -i "title" | head -n 1 | cut -d: -f2- | awk '{$1=$1};1')
    artist=$(echo "$out" | grep -i "artist" | head -n 1 | cut -d: -f2- | awk '{$1=$1};1')
    genre=$(echo "$out" | grep -i "genre" | head -n 1 | cut -d: -f2- | awk '{$1=$1};1')

	if [[ -z "$title" ]]; then
		warning "Possibly missing title metadata in '$file'" "\r"
	fi
	if [[ -z "$artist" ]]; then
		warning "Possibly missing artist metadata in '$file'" "\r"
	fi
	if [[ -z "$genre" ]]; then
		warning "Possibly missing genre metadata in '$file'" "\r"
	fi

    echo "#EXTLAB:$title"
    echo "#EXTART:$artist"
    echo "#EXTGEN:$genre"

	if [[ "$prepend" == "" ]]; then
		echo "$file"
	else
		echo "$prepend$(basename "$file")"
	fi
    return 0
}

# Get a m3u entries from a list of files
m3u_from_paths()
{
	files="$1"
	playlist_name="$2"
	prepend="$3"

	info "Creating an m3u playlist from paths..." "\r"

	echo "#EXTM3U"
	echo "#PLAYLIST:$playlist_name"

	i=1
	max=$(echo "$files" | wc -l)
	echo -e "$files" | while IFS= read -r file; do
		get_m3u_entry "$file" "$prepend"
		progress_bar $i $max "1" "1"
		((i++))
	done
}

set -o pipefail

CMUS_PLAYLISTS="$HOME/.config/cmus/playlists"
TMP_DIR="$HOME/.m3uexp"
EXPORT_NAME="cmus-export-$(date +"%d-%m-%Y")-$(hostname)"

MODE=$1
COMMAND=$2

if [[ -z $MODE ]]; then
	error "Expected mode!"
	echo ""
	print_usage
	exit 1
elif [ $MODE == "--help" ]; then
	print_usage
	exit 0
fi

check_dependencies
if [ $? -ne 0 ]; then
	error "Some dependency checks have failed!"
    exit 1
fi

if [[ $MODE == "export" ]]; then
	if [[ $COMMAND == "cmus" ]]; then
		info "Exporting cmus playlists..."
		info "Creating a temporary directory $TMP_DIR/"

		target="$TMP_DIR/$EXPORT_NAME"
		mkdir -p "$target/"

		previous_wd=$(pwd)
		cd "$target"

		playlists=$(ls "$CMUS_PLAYLISTS/")

		iter=1
		playlist_count=$(echo "$playlists" | wc -l)
		echo -e "$playlists" | while IFS= read -r playlist; do
			file_accessible "$CMUS_PLAYLISTS/$playlist"
			if [ $? -eq 0 ]; then
				songs=$(cat "$CMUS_PLAYLISTS/$playlist")

				info "Creating an m3u playlist from paths..." "\r"

				echo "#EXTM3U" > "$playlist.m3u" 
				echo "#PLAYLIST:$playlist" >> "$playlist.m3u"

				subiter=1
				song_count=$(echo "$songs" | wc -l)
				echo -e "$songs" | while IFS= read -r song; do
					base_dir=$(basename $(dirname "$song"))
					mkdir -p "$base_dir"
					cp "$song" "$base_dir"
					get_m3u_entry "$song" "$base_dir/" >> "$playlist.m3u"
					progress_bar $subiter $song_count $iter $playlist_count
					((subiter++))
				done
			fi
			((iter++))
		done
		echo ""
		info "Packing up..."
		cd ..
		tar cf "$previous_wd/$EXPORT_NAME.tar.gz" "$EXPORT_NAME"
		info "Exported as '$EXPORT_NAME.tar.gz'"
		info "Cleaning up..."
		rm -rf "$TMP_DIR/"
		info "All done."
	elif [[ -z $COMMAND ]]; then
		error "Expected a command after $MODE"
		echo ""
		print_usage
		exit 1
		else
		error "Unknown command '$COMMAND' for $MODE"
		echo ""
		print_usage
		exit 1
	fi
elif [[ $MODE == "import" ]]; then
	if [[ $COMMAND == "cmus" ]]; then
		info "'$MODE $COMMAND' is currently a WIP"
	elif [[ -z $COMMAND ]]; then
		error "Expected a command after '$MODE'"
		echo ""
		print_usage
		exit 1
	else
		error "Unknown command for '$MODE'"
		echo ""
		print_usage
		exit 1
	fi
elif [[ $MODE == "create" ]]; then
	playlist_name=$(basename "$PWD")
	paths=""
	info "Reading from stdin..."
	while read file; do
		paths+="$file"$'\n'
	done

	m3u_from_paths "$paths" "$playlist_name" > "$playlist_name.m3u"
else
	error "Unknown mode!"
	echo ""
	print_usage
	exit 1
fi
