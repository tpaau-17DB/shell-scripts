#!/bin/bash

#
# Customizable shell script to automate backup making process
#
# Dependencies: bash, tar, optionally notify-send
#

# Send a notification when finished
notify_user=1

# Various paths
drive_path="/mnt/usb1/"
to_backup="$HOME/* $HOME/.*"
file_name="backup-$(hostname).tar.gz"
backup_location="${drive_path}${file_name}"

handle_exit()
{
    echo "Interrupted by user."
    exit 1
}

# Handle user interruption
trap handle_exit SIGINT

echo "Backup location: $backup_location"

if ! [ -e "${drive_path}" ]; then
    echo "Path $drive_path does not exist!"
    exit 1
fi

if [ -f "$backup_location" ]; then
    read -p "The file $backup_location already exists. Do you want to overwrite it? [y/N]: " choice
    choice="${choice:-N}"
    case "$choice" in
        [Yy]* )
            echo "You chose to overwrite the file."
        ;; [Nn]* )
            echo "$backup_location was not overwritten."
            exit 0
        ;; * )
            echo "Invalid input. Please answer with 'y' or 'n'."
            exit 1
        ;;
    esac
else
    echo "The file $backup_location does not exist. Proceeding with the operation."
fi

# Compress and move the backup
sudo bash -c "tar -cvpzf $backup_location $to_backup" && echo "Compressing the directories finished."

# Notify the user
exit_status=$?
if [ $notify_user -eq 1 ]; then
    if [ $exit_status -eq 0 ]; then
        echo "Backup completed successfully."
        notify-send "Backup completed successfully."
    elif [ $exit_status -eq 130 ]; then
        echo "Interrupded by user."
        exit 2
    else
        echo "Backup failed. Please check the logs."
        notify-send -u critical "Backup failed. Please check the logs."
    fi
fi
