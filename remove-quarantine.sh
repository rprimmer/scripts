#! /usr/bin/env bash

# Remove apple quarantine property from a file

xattr -r $1
xattr -d -r com.apple.quarantine $1
xattr -r $1
