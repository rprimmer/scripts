#!/usr/bin/env bash

usage() {
    cat << EOF 
usage: $(basename $0) [options] <arguments>
    OPTIONS
        -t Only display total occurrences and show a dot as a progress indicator for each file with occurrences

    ARGUMENTS
        argument 1: directory tree to search
        argument 2: keyword to search for in files

INFO
    This script walks a dir tree, checking each valid file for occurencens of <keyword>.
    By default, the files that have <keyword> present will be displayed with a count.
    The -t flag suppresses this output, instead showing progress dots for each file examined.
    In both cases a grand total is displayed.

EOF
}

show_files=true

while getopts ":t" opt; do
  case ${opt} in
    t)  show_files=false ;;
    ?)  echo "Invalid option: $OPTARG" 1>&2 ; usage ; exit 1 ;;
  esac
done
shift $((OPTIND -1))

directory="$1"
keyword="$2"

[[ -z "$directory" ]] || [[ -z "$keyword" ]] && usage && exit 1

directory="${directory%/}"
declare -i total_count=0

search_files() {
    for file in "$1"/*; do
        if [[ -f "$file" ]]; then
            declare -i file_count=$(grep -Io "$keyword" "$file" | wc -l | xargs)
            if (($file_count > 0)) ; then
                if $show_files ; then
                    echo "$file: $file_count occurrences"
                else
                    printf "."
                fi
                total_count=$((total_count + file_count))
            fi
        elif [[ -d "$file" ]]; then
            search_files "$file"
        fi
    done
}

search_files "$directory"

if $show_files ; then
    printf "Total occurrences of '$keyword' in all files: %d\n" $total_count
else
    printf "\nTotal occurrences of '$keyword' in all files: %d\n" $total_count
fi
