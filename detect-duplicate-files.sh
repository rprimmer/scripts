#! /bin/sh
# Detect duplicate files in a dir tree

# Set the min file size of duplicates you want to flag
SZ="+40M"

# Set the check algorithm you want to use. macOS by default has: cksum and md5
# ALGO="md5" -- note that using MD5 requires some code changes
ALGO="cksum"

find . -type f -size $SZ -exec $ALGO {} \; | tee /tmp/tempfilelist.tmp | cut -f 1,2 -d ' ' | sort | uniq -d | grep -hif - /tmp/tempfilelist.tmp | sort -nrk2 | awk -F\  '$1!=x&&x{print ""}{x=$1}1'
