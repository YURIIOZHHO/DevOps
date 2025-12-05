#!/bin/bash

FULL_BACKUP_PATH="/backups/full-backup"

PARTIAL_BACKUP_PATH="/backups/partial-backup"

INCREMENTAL_BACKUP_PATH="/backups/incremental-backup"

DIFF_BACKUP_PATH="/backups/differential-backup"

TEST_FULL_BACKUP_PATH="/home/student/DevOps/Bash-Scripting/test-full-backup"

SNAPSHOT_FILE="/backups/full-backup.snar"

function full_backup(){

    sudo mkdir -p "$FULL_BACKUP_PATH"

    sudo tar --listed-incremental="$SNAPSHOT_FILE" -czf "$FULL_BACKUP_PATH/full-backup.tar.gz" -C "$TEST_FULL_BACKUP_PATH" . 
    echo "Full backup was successfully created"

    ls -l "$FULL_BACKUP_PATH"
}

function partial_backup(){

    sudo mkdir -p "$PARTIAL_BACKUP_PATH"

    read -p "Enter the path to the folder: " path

    if [ -d "$path" ]; then
	sudo tar -czf "$PARTIAL_BACKUP_PATH/partial-backup.tar.gz" -C "$path" .
        echo "Partial backup was successfully created"

	ls -l "$PARTIAL_BACKUP_PATH"
    else
	echo "This path is incorrected"
    fi
}


function incremental_backup(){
    sudo mkdir -p "$INCREMENTAL_BACKUP_PATH"

    backup_file="$INCREMENTAL_BACKUP_PATH/incremental-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    sudo tar --listed-incremental="$SNAPSHOT_FILE" -czf "$backup_file" -C "$TEST_FULL_BACKUP_PATH" . 

    echo "Incremental backup created: $backup_file"
}

function differential_backup(){
    mkdir -p "$DIFF_BACKUP_PATH"
    backup_file="$DIFF_BACKUP_PATH/diff-$(date +%Y%m%d-%H%M%S).tar.gz"

    sudo tar --listed-incremental=/dev/null -czf "$backup_file" -C "$TEST_FULL_BACKUP_PATH" 

    echo "Differential backup created: $backup_file"
}

echo -e "Welcome! This script can create full, partial and other different backups:
1 - Full backup;
2 - Partial backup;
3 - Incremental backup;
4 - Differential;
5 - Exit;
In order to choose one of these variants, enter the corresponding number!"


while true; do
    read -p "You choose is? " answer
    case $answer in
	[1]* ) full_backup;;
	[2]* ) partial_backup;;
	[3]* ) incremental_backup;;
	[4]* ) differential_backup;;
	[5]* ) break;;
	* ) echo "other answer";;
    esac
done

