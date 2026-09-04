#!/bin/sh
# Find large files

# Set lower size limit for return
FILE_SIZE=${FILE_SIZE:-+2G}
DIR_SIZE=${DIR_SIZE:-6G}
ROOT=${1:-.}

if [ ! -d "$ROOT" ]; then
    echo "Directory not found: $ROOT" >&2
    exit 1
fi

# In macOS, if Terminal does not have "Full Disk Access" you'll need to redirect stderr
# find . -size $SZ -exec du -hs {} \; 2>/dev/null | sort -hr

# Else, not necessary
echo "Finding large files..."
find "$ROOT" -type f -size "$FILE_SIZE" -exec du -hs {} \; 2>/dev/null | sort -hr

printf "\n %s \n" "Finding large dirs..."
du -h -t "$DIR_SIZE" "$ROOT" 2>/dev/null | sort -hr
