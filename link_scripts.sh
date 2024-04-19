#!/usr/bin/env bash

set -euo pipefail

EXTENSIONS=("py" "sh")
SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/src/scripts}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/bin}"
PROGRAM_NAME=$(basename "$0")
LOG_FILE="${SCRIPTS_DIR}/${PROGRAM_NAME}-$(date +%Y%m%d-%H%M%S).log"
declare -i delete_logs=0 keep_logs=0 overwrite=0

usage() {
    cat << EOF 
usage: $(basename "$0") [options]
    OPTIONS
        -d  Delete existing log files when run in batch mode.
        -h  Display this help message.
        -k  Keep log files.
        -o  Overwrite existing soft links

    ARGUMENTS
        None. 

INFO
    This script creates soft links in a local bin dir to a shared scripts dir.
    Default values:
      LOCAL_BIN:    $LOCAL_BIN
      SCRIPTS_DIR:  $SCRIPTS_DIR

    You can change these directories by setting the environment vars: LOCAL_BIN & SCRIPTS_DIR
EOF
}

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $@" >> "$LOG_FILE" 
}

echo_and_log() {
  echo "$1"  
  log "$1"   
}

create_soft_link() {
    local src_file="$1"
    local dest_file="$2"
    
    if (( overwrite )) && [ -e "$dest_file" ]; then
        echo_and_log "Overwriting existing soft link: $dest_file"
        if ! rm "$dest_file"; then
            echo_and_log "Failed to remove existing soft link: $dest_file" >&2
            return 1
        fi
    fi

    if ! ln -sf "$src_file" "$dest_file"; then
        echo_and_log "Failed to create soft link: $dest_file" >&2
        return 1
    fi

    echo_and_log "Created soft link: $dest_file"
}

scan_dir() {
    local file
    for file in "$SCRIPTS_DIR"/*; do
        [[ -f "$file" ]] || continue 

        local filename=$(basename "$file")
        local extension="${filename##*.}"

        if [[ " ${EXTENSIONS[*]} " =~ " $extension " ]]; then
            chmod +x "$file"
            create_soft_link "$file" "$LOCAL_BIN/$filename" 
        fi
    done
}

delete_existing_logs() {
    local file
    for file in "$SCRIPTS_DIR"/"$PROGRAM_NAME"-*.log; do 
        [[ -f "$file" ]] || continue 
        if (( delete_logs )); then  
            rm -f "$file"
            echo_and_log "Log file $file deleted."
        fi
    done 
}

parse_args() {
    while getopts ":dhko" opt; do
        case ${opt} in
            d)  delete_logs=1 ;;  
            h)  usage ; exit 0 ;; 
            k)  keep_logs=1 ;;
            o)  overwrite=1 ;;      
            ?)  echo "Invalid option: -$OPTARG" >&2 ; usage ; exit 1 ;;
        esac
    done
    shift $((OPTIND - 1)) 
}

main() {
    parse_args "$@"

    if (( ! keep_logs )); then
        delete_existing_logs
    fi

    if ! mkdir -p "$LOCAL_BIN"; then
        echo_and_log "Failed to create directory: $LOCAL_BIN" >&2
        exit 1
    fi

    scan_dir
}

main "$@"
