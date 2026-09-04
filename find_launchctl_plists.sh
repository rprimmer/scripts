#!/usr/bin/env bash

# Report installed third-party launchd plists and their current service state.
# User and system domains are readable without sudo on current macOS releases.

set -u

USER_DOMAIN="gui/$(id -u)"
FOUND_PLIST=0

print_header() {
    printf "%-8s %-13s %-14s %-6s %s\n" "LOADED" "STATE" "LAST-EXIT" "DOMAIN" "LABEL / PLIST"
    printf "%-8s %-13s %-14s %-6s %s\n" "------" "-----" "---------" "------" "-------------"
}

service_value() {
    local key="$1"
    awk -F ' = ' -v key="$key" '$1 ~ "^[[:space:]]*" key "$" { print $2; exit }'
}

report_plist() {
    local plist="$1"
    local domain="$2"
    local domain_name="$3"
    local label details state last_exit

    if ! label=$(plutil -extract Label raw "$plist" 2>/dev/null); then
        printf "%-8s %-13s %-14s %-6s %s\n" "invalid" "-" "-" "$domain_name" "$plist"
        return
    fi

    if details=$(launchctl print "$domain/$label" 2>/dev/null); then
        state=$(printf '%s\n' "$details" | service_value state)
        last_exit=$(printf '%s\n' "$details" | service_value "last exit code")
        [[ -n "$state" ]] || state="unknown"
        [[ -n "$last_exit" ]] || last_exit="never exited"
        printf "%-8s %-13s %-14s %-6s %s / %s\n" "yes" "$state" "$last_exit" "$domain_name" "$label" "$plist"
    else
        printf "%-8s %-13s %-14s %-6s %s / %s\n" "no" "-" "-" "$domain_name" "$label" "$plist"
    fi
}

scan_directory() {
    local directory="$1"
    local domain="$2"
    local domain_name="$3"
    local plist

    [[ -d "$directory" ]] || return

    for plist in "$directory"/*.plist; do
        [[ -e "$plist" ]] || continue
        FOUND_PLIST=1
        report_plist "$plist" "$domain" "$domain_name"
    done
}

print_header
scan_directory "$HOME/Library/LaunchAgents" "$USER_DOMAIN" "user"
scan_directory "/Library/LaunchAgents" "$USER_DOMAIN" "user"
scan_directory "/Library/LaunchDaemons" "system" "system"

if (( ! FOUND_PLIST )); then
    printf "No third-party launchd plist files found.\n" >&2
    exit 1
fi
