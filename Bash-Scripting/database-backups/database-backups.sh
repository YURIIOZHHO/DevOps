#!/bin/bash
set -e

DATE=$(date +%F-%H-%M)
DB_NAME="mysql"
DB_USER="root"
DB_PASS="111111"
BACKUP_DIR="/var/db_backups"
TF_DIR="$(pwd)/s3"

sudo mkdir -p "$BACKUP_DIR"

terraform -chdir="$TF_DIR" init -input=false
terraform -chdir="$TF_DIR" apply -auto-approve

BUCKET_NAME=$(terraform -chdir="$TF_DIR" output -raw bucket_name)

FILE_NAME="${DB_NAME}_${DATE}.sql.gz"
FILE_PATH="${BACKUP_DIR}/${FILE_NAME}"

sudo bash -c "mysqldump -u '$DB_USER' -p'$DB_PASS' '$DB_NAME' | gzip > '$FILE_PATH'"

aws s3 cp "$FILE_PATH" "s3://${BUCKET_NAME}/mysql/${FILE_NAME}"

sudo find "$BACKUP_DIR" -type f -mtime +7 -delete

