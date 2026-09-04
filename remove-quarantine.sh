#!/usr/bin/env bash

# Remove apple quarantine property from a file

set -u

if [[ $# -ne 1 || ! -e $1 ]]; then
    echo "Usage: $(basename "$0") file-or-directory" >&2
    exit 1
fi

target=$1
if [[ $target == -* ]]; then
    target="./$target"
fi

echo "Before:"
xattr -lr "$target" || true
xattr -dr com.apple.quarantine "$target"
echo "After:"
xattr -lr "$target" || true
