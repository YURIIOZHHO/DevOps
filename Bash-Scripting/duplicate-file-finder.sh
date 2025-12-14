#!/bin/bash

#Duplicate File Finder
#Description: Make a script to find and list duplicate files in a folder. Use file size and content comparison to spot duplicates and offer choices to delete or move them.
#Skills: File comparison, hashing, arrays, user interaction

declare -A CHECKSUM_MAP
DUPLICATES=()

read -p "Enter the full path to folder: " DIR_PATH

if [[ ! -d "$DIR_PATH" ]]; then
    echo "Directory does not exist"
    exit 1
fi

for file in "$DIR_PATH"/*; do
    [[ -f "$file" ]] || continue

    checksum=$(sha256sum "$file" | awk '{print $1}')

    if [[ -n "${CHECKSUM_MAP[$checksum]}" ]]; then
        echo "Duplicate found:"
        echo "Original: ${CHECKSUM_MAP[$checksum]}"
        echo "Duplicate: $file"
        echo
        DUPLICATES+=("$file")
    else
        CHECKSUM_MAP[$checksum]="$file"
    fi
done

if (( ${#DUPLICATES[@]} == 0 )); then
    echo "No duplicates found"
    exit 0
fi

echo "What do you want to do with duplicate files?"
echo "1 - Delete duplicates"
echo "2 - Move duplicates"

read -p "Answer: " answer

case "$answer" in
    1)
        echo "Deleting duplicates..."
        for file in "${DUPLICATES[@]}"; do
            rm -i "$file"
        done
        ;;
    2)
        read -p "Enter destination folder for duplicates: " DEST_DIR
        mkdir -p "$DEST_DIR"

        echo "Moving duplicates..."
        for file in "${DUPLICATES[@]}"; do
            mv -i "$file" "$DEST_DIR/"
        done
        ;;
    *)
        echo "Wrong option"
        ;;
esac

