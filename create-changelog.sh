#!/usr/bin/env bash

# Create ChangeLog

set -u

# Default to ChangeLog or create custom log name with env var or positional arg
LOG_FILE=${LOG_FILE:-ChangeLog}

if [[ $# -gt 1 ]]; then
    echo "Usage: $(basename "$0") [output-file]" >&2
    exit 1
elif [[ $# -eq 1 ]]; then
    LOG_FILE="$1"  
fi

TEMP_FILE=$(mktemp "${LOG_FILE}.tmp.XXXXXX") || exit 1
trap 'rm -f "$TEMP_FILE"' EXIT

{
    echo "This file has been automatically generated using the following command:"
    echo
    printf "\tgit log --pretty=format:'%%h %%d %%ai - %%s'\n"
    echo

    if ! git log --pretty=format:"%h %d %ai - %s"; then
        echo "Error: git log command failed." >&2
        exit 1
    fi
    echo
} > "$TEMP_FILE"

mv "$TEMP_FILE" "$LOG_FILE"
trap - EXIT
cat "$LOG_FILE"
