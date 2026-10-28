#!/usr/bin/env bash

# After an update of Xcode it is sometimes necessary to reinstall CommandLineTools
# It's necessary to first remove the old CommandLineTools to force an upgrade
sudo rm -rf /Library/Developer/CommandLineTools

# Install latest. This will create a confirmation pop-up dialog box
sudo xcode-select --install
