#!/usr/bin/env bash

# A temporary folder filled with many, many new files causes macOS MDS to take up all CPU.
# I can never remember the name of the command to control the MDS on macOS. 

usage() {
    echo "Usage: $(basename "$0") <ACTION>"
    echo 
    echo "Actions:"
    echo "  pause         Pause indexing service"
    echo "  resume        Resume indexing service"
    echo
    echo "Example:"
    echo "  $(basename "$0") pause"
    echo
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

if [[ "$1" = "pause" ]]; then   
    sudo mdutil -i off
elif [[ "$1" = "resume" ]]; then
    sudo mdutil -i on
else 
    usage
fi
