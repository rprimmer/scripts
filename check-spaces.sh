#!/usr/bin/env bash

cleanup() {
    printf "\nInterrupt received. Exiting...\n"
    exit 1
}

trap cleanup SIGINT

usage() {
    cat <<EOF
usage: $(basename $0) [OPTIONS] <arguments>
    OPTIONS
        -n  Run in non-interactive mode, automatically removing trailing spaces without prompting

    ARGUMENTS
        files to scan

INFO
    This script checks files for trailing spaces, optionally removing the trailing spaces or display as dots.
    Runs interactively by default. Use the -n flag to run in batch.
    Useful for checking makefiles and markdown, where trailing spaces can cause issues.

EOF
}

[[ $# = 0 ]] && usage && exit 1

declare -i interactive=1 # Default to interactive mode

while getopts ":n" opt; do
    case ${opt} in
        n)  interactive=0 ;;
        ?)  echo "Invalid option: $OPTARG" 1>&2 ; usage ; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

declare -a stat_cmd
if [[ $(uname) == "Darwin" ]]; then
    stat_cmd=(stat -f %z) # macOS
else
    stat_cmd=(stat -c %s) # Linux et al.
fi

check_trailing_spaces() {
    grep -q '[[:space:]]$' "$1"
    return $?
}

display_lines() {
    echo "Displaying lines with trailing spaces in: $1"
    awk '/[[:space:]]+$/ {
            # Replace all spaces at the end with dots
            gsub(/ /, ".", $0);
            # Print the line number and the modified line
            print "[" NR "] " $0
         }' "$1"
}

remove_trailing_spaces() {
    echo "Removing trailing spaces from: $1"
    perl -pi -e 's/[[:blank:]]+$//g' "$1"
}

for file in "$@"; do
    if [ ! -f "$file" ] || [ ! -r "$file" ]; then
        echo "Error: File is missing or not readable - $file"
        continue
    fi

    filetype=$(file --brief --mime-type "$file")
    if [[ "$filetype" != text/* && "$filetype" != application/json && "$filetype" != application/xml ]]; then
        echo "Error: Unsupported file type - $file"
        continue
    fi

    filesize=$("${stat_cmd[@]}" "$file")
    if ((filesize > 10000000)); then
        echo "Error: File size exceeds 10MB limit - $file"
        continue
    fi

    if check_trailing_spaces "$file"; then
        if ((interactive)); then
            echo "Trailing spaces found in: $file"
            echo "Options for $file:"
            echo "  [d] Display lines with trailing spaces"
            echo "  [r] Remove trailing spaces"
            echo "  [s] Skip file"
            echo "  [x] Exit"
            read -p "Choose an option [d/r/s/x]: " -n 1 -r option
            echo

            case $option in
                d) display_lines "$file" ;;
                r) remove_trailing_spaces "$file" ;;
                s) echo "Skipping $file" ;;
                x) echo "Exiting..." ; exit 0 ;;
                *) echo "Invalid option, skipping $file." ;;
            esac
            echo
        else
            remove_trailing_spaces "$file"
        fi
    else
        echo "No trailing spaces found in: $file"
    fi
done
