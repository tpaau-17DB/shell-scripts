#!/bin/bash

#
# This script changes the artist metadata of .webm files.
# I created it because, when metadata is missing,
# cmus uses the full file path as the artist name, often making the display hard to read.
#
# Requirements: bash, ffmpeg
#

NEW_ARTIST="MISSING_METADATA"

for file in *.webm; do
    if [ -f "$file" ]; then
        output="new_meta/$file"
        ffmpeg -i "$file" -metadata artist="$NEW_ARTIST" -codec copy "$output"
    else
        echo "No .webm files found."
    fi
done
