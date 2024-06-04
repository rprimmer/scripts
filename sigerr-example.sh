#!/usr/bin/env bash

# Example error call to print error line when a error signal is raised.
# Triggers when any command completes with a non-zero status

_print_error () {
    echo "Error occurred:"
    awk 'NR>L-4 && NR<L+4 { printf "%-5d%3s%s\n",NR,(NR==L?">>>":""),$0 }' L=$1 $0
}

trap '_print_error "$LINENO"' ERR

echo "This is fine..."
this-isnt-fine
echo "This is fine again"