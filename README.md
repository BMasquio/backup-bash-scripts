# backup-bash-scripts

## Setup
### Install postfix
```sudo apt-get install postfix```

### Setup cron
```crontab -e```

### Cron logs
```sudo tail -f /var/mail/root```

### 

Bash toolkit in bash for backup web applications

## make_incremental_folder_backup

```
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
```
### Example
`make_incremental_folder_backup "/var/www/laravel" "/tmp/backups"`

Create incremental backup of app "/var/www/laravel" in the folder "/tmp/backups"

## restore_web_app_with_exclusion

```
restore_web_app_with_exclusion() {
  local APP_NAME=$1
  local BACKUP_DIR=$2
  local RESTORE_LOCATION=$3
  local EXCLUDE_COUNT=$4
  
  # Check if the backup directory exists, create it if it doesn't
  if [ ! -d "$RESTORE_LOCATION" ]; then
    mkdir -p "$RESTORE_LOCATION"
  fi

  # Determine the incremental backups to apply
  
  local REGEX_STRING="^$APP_NAME-(....)-(..)-(..)-(..)-(..)-(..)\.tar\.gz\$"
  local INCREMENTAL_BACKUPS=($(ls "$BACKUP_DIR" | grep -E "$REGEX_STRING" | head -n -$((EXCLUDE_COUNT))))

  # Apply the incremental backups
  for incremental_backup in "${INCREMENTAL_BACKUPS[@]}"; do
    tar --listed-incremental="$BACKUP_DIR/$incremental_backup" -xzf "$BACKUP_DIR/${incremental_backup%.snar}" -C "$RESTORE_LOCATION"
  done
}
```

### Example

`restore_web_app_with_exclusion laravel "/tmp/backups/a/b" "/tmp/backups/a/b/laravel" 2`

Restore the incremental backups for app "laravel" from /tmp/backups/a/b except the last 2 ones.


## PostgreSQL full backup routine

```
function backup_database() {
  local DB_NAME="$1"
  local BACKUP_DIR="$2/$(date +%Y-%m)/postgres"
  local TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
  local BACKUP_FILENAME="${DB_NAME}_${TIMESTAMP}.sql.gz"

  # Create the backup directory if it doesn't exist
  if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
  fi

  # Backup the database and compress the output using gzip
  pg_dump "$DB_NAME" | gzip > "${BACKUP_DIR}/${BACKUP_FILENAME}"
}


### Example
sudo su - postgres -c "source ~/.bashrc && backup_database laravel /tmp/backups"

