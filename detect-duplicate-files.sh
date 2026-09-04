#!/usr/bin/env bash

# Detect duplicate files in a directory tree. Files are grouped by size and
# SHA-256 digest, then confirmed byte-for-byte before being reported.

set -u

ROOT=${1:-.}
MIN_SIZE=${MIN_SIZE:-+40M}
declare -A FIRST_FILE=()
declare -A PRINTED_GROUP=()

if [[ ! -d "$ROOT" ]]; then
    echo "Directory not found: $ROOT" >&2
    exit 1
fi

while IFS= read -r -d '' file; do
    size=$(stat -f %z "$file") || continue
    digest=$(shasum -a 256 "$file" | awk '{print $1}') || continue
    key="$size:$digest"

    if [[ -n ${FIRST_FILE[$key]+set} ]]; then
        if cmp -s "${FIRST_FILE[$key]}" "$file"; then
            if [[ -z ${PRINTED_GROUP[$key]+set} ]]; then
                printf '%s bytes\n  %s\n' "$size" "${FIRST_FILE[$key]}"
                PRINTED_GROUP[$key]=1
            fi
            printf '  %s\n' "$file"
        fi
    else
        FIRST_FILE[$key]="$file"
    fi
done < <(find "$ROOT" -type f -size "$MIN_SIZE" -print0)
