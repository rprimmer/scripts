#!/bin/sh
# Return external IP address

curl --fail --silent --show-error --max-time 10 https://api.ipify.org
printf '\n'
