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

backup_database laravel /tmp/backups

