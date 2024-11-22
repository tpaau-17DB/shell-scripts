#!/bin/bash

#
# This script safely copies files from source_path to
# target_path. If it detects that target_path is not empty,
# it asks user whether they want to overwrite the content of
# target_path.
#
# Dependencies: bash
#

# Paths of the source and target files
source_path="conf/*"
target_path="$HOME/.config/glitch-effect/"

# Simply copies the files
copy_files()
{
  echo "Copying ${source_path} to ${target_path}"
  cp $source_path $target_path
}

# Make sure target_path exists
mkdir -p "$target_path"

# Check if target_path is empty to avoid overwrite
if [ -d "$target_path" ] && [ "$(ls -A "$target_path")" ]; then
  read -p "$target_path exists and is not empty. Do you wish to overwrite it? (y/n): " choice
  case "$choice" in
    [Yy]* )
      echo "You chose to overwrite the file."
      copy_files
    ;;
    [Nn]* )
      echo "${target_path} was not overwritten."
      exit 0
  esac
else
  # If folder is empty, proceed
  echo "OK: ${target_path} is empty"
  copy_files
fi
