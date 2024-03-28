#! /bin/sh
# Find large files

# Set lower size limit for return
FileSZ="+2G"
DirSZ="6G"

# In macOS, if Terminal does not have "Full Disk Access" you'll need to redirect stderr
# find . -size $SZ -exec du -hs {} \; 2>/dev/null | sort -hr

# Else, not necessary
echo "Finding large files..."
find . -size $FileSZ -exec du -hs {} \; | sort -hr 

printf "\n %s \n" "Finding large dirs..."
du -h -t$DirSZ | sort -hr 
