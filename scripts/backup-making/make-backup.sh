#!/bin/bash

#
# Customizable shell script to automate backup making process
#
# Requires `tar` to run.
#

notify_user=1
HOME="/home/user/"
to_backup="make-backup.sh ${HOME}Documents/ ${HOME}Downloads/ ${HOME}.local/ ${HOME}.config/ ${HOME}gitrepos/ ${HOME}Pictures/ ${HOME}Songs"
drive_path="/mnt/drive1/"
file_name="backup.tar.gz"
backup_location="${drive_path}${file_name}"

echo "Backup location: $backup_location"

if ! [ -e "${drive_path}" ]; then
    echo "Path does not exist"
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

sudo tar -cvpzf "${file_name} " ${to_backup} && \
sudo mv "${file_name} " ${backup_location}

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
