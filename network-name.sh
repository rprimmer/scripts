#!/bin/sh
# Return WiFi network name

wifi_device=$(networksetup -listallhardwareports 2>/dev/null | awk '
    /^Hardware Port: (Wi-Fi|AirPort)$/ {
        getline
        sub(/^Device: /, "")
        print
        exit
    }
')

if [ -z "$wifi_device" ]; then
    echo "Wi-Fi interface not found" >&2
    exit 1
fi

network=$(networksetup -getairportnetwork "$wifi_device") || exit 1
case $network in
    *": "*) printf '%s\n' "${network#*: }" ;;
    *) echo "$network" >&2; exit 1 ;;
esac
