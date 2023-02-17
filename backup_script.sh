#!/bin/bash

function make_incremental_folder_backup {
  # Define the web app directory
  local WEB_APP_DIR="$1"

  # Define the backup directory
  BACKUP_DIR="$2/$(date +%Y-%m)/app"

  APP_NAME="${WEB_APP_DIR##*/}"

  # Define the current date and time
  DATE=$(date +%Y-%m-%d-%H-%M-%S)

  # Check if the backup directory exists, create it if it doesn't
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
  fi

  local SNAPSHOT_PATH=$BACKUP_DIR/$APP_NAME
  local SAVE_PATH=$SNAPSHOT_PATH-$DATE

  # Make an incremental backup of the web app directory
  tar -czf "$SAVE_PATH.tar.gz" -g "$SNAPSHOT_PATH.snapshot" "$WEB_APP_DIR"

  # Print a message indicating that the backups were successfully created
  echo "Incremental backups created successfully on $SAVE_PATH.tar.gz."
}

make_incremental_folder_backup /var/www/laravel /tmp/backups
