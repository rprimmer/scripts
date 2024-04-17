#!/usr/bin/env bash

# Create ChangeLog

# Default to ChangeLog or create custom log name with env var or positional arg
LOG_FILE=${LOG_FILE:-ChangeLog}

if [[ $# -eq 1 ]]; then
    LOG_FILE="$1"  
fi

echo "This file has been automatically generated using the following command:" > "$LOG_FILE"
echo "" >> "$LOG_FILE"
echo -e "\tgit log --pretty=format:'%h %d %ai - %s'" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

if ! git log --pretty=format:"%h %d %ad - %s" >> "$LOG_FILE"; then
    echo "Error: git log command failed." >&2
    exit 1
fi

echo "" >> "$LOG_FILE"

cat "$LOG_FILE"
