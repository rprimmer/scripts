#!/usr/bin/env bash

keyword=""
total_count=0
show_files=true

# -t: Only display total occurrences and show a dot as a progress indicator for each file with occurrences.

while getopts ":t" opt; do
  case ${opt} in
    t )
      show_files=false
      ;;
    \? )
      echo "Invalid option: $OPTARG" 1>&2
      exit -1
      ;;
  esac
done
shift $((OPTIND -1))

directory="$1"
keyword="$2"

if [[ -z "$directory" ]] || [[ -z "$keyword" ]]; then
    echo "Usage: $(basename $0) [-t] <directory> <keyword>"
    exit 1
fi

search_files() {
    for file in "$1"/*; do
        if [[ -f "$file" ]]; then
            file_count=$(grep -Io "$keyword" "$file" | wc -l | xargs)
            if [[ $file_count -gt 0 ]]; then
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
    echo "Total occurrences of '$keyword' in all files: $total_count"
else
    printf "\nTotal occurrences of '$keyword' in all files: $total_count\n"
fi
