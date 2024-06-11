#!/usr/bin/env bash

# Function to get plist names from launchctl
get_plist_names() {
    launchctl list | grep -v apple | awk 'NR>1 {print $3".plist"}'
    sudo launchctl list | grep -v apple | awk 'NR>1 {print $3".plist"}'
}

# Get the list of plist files from launchctl, skipping the header row and removing duplicates
plist_names=$(get_plist_names | sort -u)

# Define an array of common directories to search
dirs=(
    "/Library/LaunchAgents"
    "/Library/LaunchDaemons"
    "/System/Library/LaunchAgents"
    "/System/Library/LaunchDaemons"
    "$HOME/Library/LaunchAgents"
)

# Function to search for a single plist file
search_plist() {
    local plist_name="$1"
    for dir in "${dirs[@]}"; do
        if [ -e "$dir/$plist_name" ]; then
            printf "Found: %s/%s\n" "$dir" "$plist_name"
            return 0
        fi
    done
    return 1
}

# Arrays to store found and not found plist files
found_plists=()
not_found_plists=()

# Main script execution
if [ -z "$plist_names" ]; then
    printf "No plist files found by launchctl.\n"
    exit 1
fi

for plist_name in $plist_names; do
    printf "Searching for: %s\n" "$plist_name"
    plist_path=$(search_plist "$plist_name")
    if [ $? -eq 0 ]; then
        found_plists+=("$plist_path")
    else
        not_found_plists+=("$plist_name")
    fi
done

# Print found and not found plist files
if [ ${#found_plists[@]} -gt 0 ]; then
    printf "\nFound plist files:\n"
    for plist in "${found_plists[@]}"; do
        printf "%s\n" "$plist"
    done
else
    printf "\nNo plist files found in common directories.\n"
fi

if [ ${#not_found_plists[@]} -gt 0 ]; then
    printf "\nPlist files not found in common directories:\n"
    for plist in "${not_found_plists[@]}"; do
        printf "%s\n" "$plist"
    done
fi
