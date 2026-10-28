#!/usr/bin/env bash

set -euo pipefail

EXTENSIONS=("py" "sh")
SCRIPTS_DIR="${SCRIPTS_DIR:-$HOME/src/scripts}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/bin}"
PROGRAM_NAME=$(basename "$0")
LOG_FILE="${SCRIPTS_DIR}/_logs/${PROGRAM_NAME}-$(date +%Y%m%d-%H%M%S).log"
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
    Files with a listed extension (${EXTENSIONS[*]}) are made executable and linked;
    other files are linked only if already executable.
    Default values:
      LOCAL_BIN:    $LOCAL_BIN
      SCRIPTS_DIR:  $SCRIPTS_DIR

    You can change these directories by setting the environment vars: LOCAL_BIN & SCRIPTS_DIR
EOF
}

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}

echo_and_log() {
  echo "$1"  
  log "$1"   
}

create_soft_link() {
    local src_file="$1"
    local dest_file="$2"
    
    if [[ -e "$dest_file" || -L "$dest_file" ]]; then
        if (( ! overwrite )); then
            echo_and_log "Skipping existing destination: $dest_file"
            return 0
        fi
        if [[ -d "$dest_file" && ! -L "$dest_file" ]]; then
            echo_and_log "Refusing to replace directory: $dest_file" >&2
            return 1
        fi
        echo_and_log "Overwriting existing link or file: $dest_file"
        if ! /bin/unlink "$dest_file"; then
            echo_and_log "Failed to remove existing soft link: $dest_file" >&2
            return 1
        fi
    fi

    if ! ln -s "$src_file" "$dest_file"; then
        echo_and_log "Failed to create soft link: $dest_file" >&2
        return 1
    fi

    echo_and_log "Created soft link: $dest_file"
}

scan_dir() {
    local file
    for file in "$SCRIPTS_DIR"/*; do
        [[ -f "$file" ]] || continue 

        local filename
        filename=$(basename "$file")
        local extension="${filename##*.}"

        # Listed extensions are made executable; any other file is linked
        # only if it already is (cc-transcript, mdnumber and the like)
        if [[ " ${EXTENSIONS[*]} " == *" $extension "* ]]; then
            chmod +x "$file"
        elif [[ ! -x "$file" ]]; then
            continue
        fi
        create_soft_link "$file" "$LOCAL_BIN/$filename"
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

    # _logs/ is git-ignored, so a fresh clone doesn't have it
    if ! mkdir -p "${LOG_FILE%/*}"; then
        echo "Failed to create directory: ${LOG_FILE%/*}" >&2
        exit 1
    fi

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
