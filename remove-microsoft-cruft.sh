#!/bin/bash

# It's nearly impossible to get rid of all the MS cruft that comes with installing their apps.
# This is particularly true for Office and Edge. The only app they have that I like is VSC.

# Terminate OneDrive process
sudo pkill -9 OneDrive

# Remove OneDrive application
sudo rm -rf /Applications/OneDrive.app/

# Remove OneDrive launch agents and daemons
sudo rm /Library/LaunchAgents/com.microsoft.OneDriveStandaloneUpdater.plist
sudo rm /Library/LaunchDaemons/com.microsoft.OneDriveStandaloneUpdaterDaemon.plist
sudo rm /Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist
sudo rm -rf /Library/Logs/Microsoft/OneDrive

# Remove OneDrive receipts
sudo rm /private/var/db/receipts/com.microsoft.OneDrive-mac.bom
sudo rm /private/var/db/receipts/com.microsoft.OneDrive-mac.plist
sudo rm /private/var/db/receipts/com.microsoft.OneDrive.bom
sudo rm /private/var/db/receipts/com.microsoft.OneDrive.plist
sudo rm /Library/LaunchDaemons/com.microsoft.OneDriveUpdaterDaemon.plist

# Remove OneDrive containers
sudo rm -rf ${HOME}/Library/Containers/com.microsoft.OneDrive-mac
sudo rm -rf ${HOME}/Library/Containers/com.microsoft.OneDrive-mac.FinderSync
sudo rm -rf ${HOME}/Library/Containers/com.microsoft.OneDrive.FinderSync
sudo rm -rf ${HOME}/Library/Containers/com.microsoft.OneDriveLauncher
sudo rm -rf ${HOME}/Library/WebKit/com.microsoft.OneDrive

# Remove OneDrive application scripts
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive-mac"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.FinderSync"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.DownloadAndGo"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive.FinderSync"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDriveLauncher"
sudo rm -rf "${HOME}/Library/Application Support/com.microsoft.OneDriveStandaloneUpdater"
sudo rm -rf "${HOME}/Library/Application Support/com.microsoft.OneDriveUpdater"

# Remove OneDrive application support
sudo rm -rf "${HOME}/Library/Application Support/OneDriveStandaloneUpdater"
sudo rm -rf "${HOME}/Library/Application Support/OneDriveUpdater"

# Remove OneDrive group containers
sudo rm -rf "${HOME}/Library/Group Containers/UBF8T346G9.OfficeOneDriveSyncIntegration"
sudo rm -rf "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveStandaloneSuite"
sudo rm -rf "${HOME}/Library/Group Containers/UBF8T346G9.OneDriveSyncClientSuite"

# Additional removals
sudo rm "${HOME}/Library/HTTPStorages/com.microsoft.OneDrive.binarycookies"
sudo rm "${HOME}/Library/HTTPStorages/com.microsoft.OneDriveStandaloneUpdater.binarycookies"
sudo rm "${HOME}/Library/HTTPStorages/com.microsoft.OneDriveUpdater.binarycookies"

sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive-mac.FileProvider"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive-mac.FinderSync"
sudo rm -rf "${HOME}/Library/Application Scripts/com.microsoft.OneDrive.FileProvider"
sudo rm -rf "${HOME}/Library/Application Scripts/UBF8T346G9.OfficeOneDriveSyncIntegration"
sudo rm -rf "${HOME}/Library/Application Scripts/UBF8T346G9.OneDriveStandaloneSuite"
sudo rm -rf "${HOME}/Library/Application Scripts/UBF8T346G9.OneDriveSyncClientSuite"
sudo rm -rf "${HOME}/Library/HTTPStorages/com.microsoft.OneDrive"
sudo rm -rf "${HOME}/Library/HTTPStorages/com.microsoft.OneDriveUpdater"
sudo rm -rf "${HOME}/Library/HTTPStorages/com.microsoft.OneDriveStandaloneUpdater"
sudo rm -rf "${HOME}/Library/Containers/com.microsoft.OneDrive.FileProvider"
sudo rm -rf "${HOME}/Library/Application Support/FileProvider/com.microsoft.OneDrive.FileProvider"
sudo rm -rf "${HOME}/Library/Application Support/FileProvider/com.microsoft.OneDrive-mac.FileProvider"

# Remove privileged helpers
sudo rm -rf "/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper"
sudo rm -rf "/Library/PrivilegedHelperTools/com.microsoft.office.licensingV2.helper"

# Remove Microsoft Application Support and Preferences
sudo rm -rf "/Library/Application Support/Microsoft"
sudo rm -rf "/Library/Preferences/com.microsoft.office.plist"
sudo rm -rf "/Library/Preferences/com.microsoft.edgemac.plist"

# Remove other Microsoft Applications
sudo rm -rf /Applications/Microsoft\ Excel.app/
sudo rm -rf /Applications/Microsoft\ Word.app/
sudo rm -rf /Applications/Microsoft\ PowerPoint.app/
sudo rm -rf /Applications/Microsoft\ Outlook.app/
sudo rm -rf /Applications/Microsoft\ OneNote.app/
sudo rm -rf /Applications/Microsoft\ Teams.app/
sudo rm -rf /Applications/Microsoft\ Edge.app/

# Ensure no leftover Microsoft processes are running
sudo pkill -9 "Microsoft"

echo "Microsoft software and related files have been removed."
