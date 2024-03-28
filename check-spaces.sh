#!/usr/bin/env bash

# Check files for trailing spaces, optionally remove the trailing spaces or display as dots.
# Useful for checking makefiles and markdown, where trailing spaces can cause issues.

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
    perl -pi -e 's/[[:space:]]+$//' "$1"
}

for file in "$@"; do
    if check_trailing_spaces "$file"; then
        echo "Trailing spaces found in: $file"
        echo "Options for $file:"
        echo "  [d] Display lines with trailing spaces"
        echo "  [r] Remove trailing spaces"
        echo "  [s] Skip file"
        echo "  [x] Exit"
        read -p "Choose an option [d/r/s/x]: " -n 1 -r option
        echo

        case $option in
            d)
                display_lines "$file"
                ;;
            r)
                remove_trailing_spaces "$file"
                ;;
            s)
                echo "Skipping $file"
                ;;
            x)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option, skipping $file."
                ;;
        esac
        echo
    else
        echo "No trailing spaces found in: $file"
    fi
done
