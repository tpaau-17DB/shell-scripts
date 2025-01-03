#!/bin/bash

#
# Customizable shell script to automate backup making process
#
# Dependencies: bash, tar, optionally libnotify
#

# Send a notification when finished
notify_user=1

# Various paths
to_backup="make-backup.sh $HOME/"
drive_path="/mnt/usb1/"
file_name="backup.tar.gz"
backup_location="${drive_path}${file_name}"

handle_exit()
{
    echo "Interrupted by user."
    exit 0
}

# Handle user interruption
trap handle_exit SIGINT

echo "Backup location: $backup_location"

if ! [ -e "${drive_path}" ]; then
    echo "Path $drive_path does not exist!"
    exit 1
fi

if [ -f "$backup_location" ]; then
  read -p "The file $backup_location already exists. Do you want to overwrite it? (y/n): " choice
  case "$choice" in
    [Yy]* )
      echo "You chose to overwrite the file."
      ;;
    [Nn]* )
      exit 0
      ;;
    * )
      echo "Invalid input. Please answer with 'y' or 'n'."
      exit 1
      ;;
  esac
else
  echo "The file $backup_location does not exist. Proceeding with the operation."
fi

# Compress and move the backup
sudo bash -c "tar -cvpzf $file_name $to_backup && mv $file_name $backup_location"

# Notify the user
if [ $? -eq 0 ]; then
    if [ $notify_user -eq 1 ]; then
        echo "Backup completed successfully."
        notify-send "Backup completed successfully."
    fi
else
    if [ $notify_user -eq 1 ]; then
        echo "Backup failed. Please check the logs."
        notify-send -u critical "Backup failed. Please check the logs."
    fi
    exit 1
fi
