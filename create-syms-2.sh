#!/bin/bash

# Default directory locations, customizable via environment variables
SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/scr/scripts}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/bin}"
LOG_DIR="$SCRIPTS_DIR"
PROGRAM=$(basename "$0")
LOG_FILE="$LOG_DIR/$PROGRAM-$(date '+%Y-%m-%d-%H-%M-%S').log"

# Extensions of files to be linked
EXTENSIONS=(".py" ".sh")  # Initial list of extensions, extendable

# Option to delete existing log files
if [[ $1 == "-d" ]]; then
    echo "Deleting existing logs..."
    rm -f "$LOG_DIR/$PROGRAM-"*.log
fi

# Creating the log directory if it does not exist
mkdir -p "$LOG_DIR"

# Ensuring LOCAL_BIN exists
mkdir -p "$LOCAL_BIN"

# Check for and create soft link for the script itself in LOCAL_BIN
if [[ ! -L "$LOCAL_BIN/$PROGRAM" ]]; then
    ln -s "$SCRIPTS_DIR/$PROGRAM" "$LOCAL_BIN/$PROGRAM"
fi

echo "Starting link creation process..." | tee -a "$LOG_FILE"

# Process files in SCRIPTS_DIR
for file in "$SCRIPTS_DIR"/*; do
    if [[ -f "$file" ]]; then
        extension="${file##*.}"
        filename=$(basename "$file")

        # Check if the file's extension is in the list of extensions
        if [[ " ${EXTENSIONS[@]} " =~ " .$extension " ]]; then
            # Ensure the file is executable
            chmod +x "$file"

            # Create a soft link in LOCAL_BIN
            ln -fs "$file" "$LOCAL_BIN/$filename"
            echo "Link created for $filename" | tee -a "$LOG_FILE"
        fi
    fi
done

echo "Link creation process completed." | tee -a "$LOG_FILE"
