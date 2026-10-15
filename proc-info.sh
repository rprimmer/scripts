#!/bin/sh

# Show process environment for a running program. 
# arg 1 is the PID of the process

sudo launchctl procinfo $1
