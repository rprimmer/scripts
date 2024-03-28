#!/bin/sh
# Return WiFi network name

networksetup -getairportnetwork en2 | awk -F": " '{print $2}'
