#!/bin/sh
# encrypt/decrypt files or directories. Action depends on name of the linked script called
# Usage: encrypt | decrypt <file | directory>
# bcrypt(1) uses blowfish encryption

# Installation
# 1) copy file 'decrypt' to a local bin dir
# 2) create a soft link to the decrypt file:  ln decrypt encrypt
# This step is needed as the script determines the appropriate action based on the filename of the script

BCRYPT="/usr/local/bin/bcrypt"

boolean_query() {
    printf "%s " "$1"
    read response
    case $response in
	"y" | "Y" | [yY][eE][sS]) return 0;;
	"n" | "N" | [nN][oO])     return 1;;
	*) echo 'Invalid response'; boolean_query "$1";;
    esac
    return
}

# Veryify environment
[[ ! -e $BCRYPT ]] && { echo "Abort: $BCRYPT not found";  exit 1; }

[[ $# -eq 0 ]] && { echo "Usage: $(basename "$0") file | directory";  exit 1; }

[[ ! -e $1 ]] && { echo "File: $1 does not exist";  exit 1; }

TARGET=$1

# Decryption path
if [ $(basename "$0") = "decrypt" ]  ;  then
    echo Decrypting "$TARGET"
    $BCRYPT "$TARGET"
    [[ $? -ne 0 ]] && { echo "bcrypt failed!"; exit $?; }
    # check to see if this is a tarball
    if [[  $TARGET =~ .*.tar.* ]]  ;  then
        if boolean_query "Expand Tarball (y/n)"  ;  then
            # bcrypt adds a .bfe suffix to encrypted files, need to strip that out to untar
	        tar zxvf "${TARGET%.bfe}"
	        rm "${TARGET%.bfe}"
        else
	        echo Leaving tarball intact. Exiting...
        fi
    fi
    exit 0
fi

# Encryption path - directory
if [ -d "$TARGET" ]  ;  then
    # Must remove trailing / if present on directory name
    TARGET=$(echo "${TARGET}" | sed 's#/*$##')
    echo "$TARGET" is a directory. Creating tarball...
    if [ -f "$TARGET".tar -o -f "$TARGET".tar.gz ]  ;  then
        echo Tarball already exists
        ls -las "$TARGET".tar*
        if boolean_query "Delete Tarball (y/n)"  ;  then
            rm "$TARGET".tar*
        else
	        echo Leaving tarball intact. Exiting...
            exit 1
        fi
    fi
  tar zcf "$TARGET".tar.gz "$TARGET"
  $BCRYPT "$TARGET".tar.gz
  [[ $? -ne 0 ]] && { echo "bcrypt failed!";  exit $?; }
  ls -las "$TARGET".tar.gz.bfe
  if boolean_query "Delete directory $TARGET (y/n)"  ;  then
        rm -r "$TARGET"
    else
        echo Leaving directory "$TARGET" intact.
    fi
    exit 0
fi

# Encryption path - file
$BCRYPT "$TARGET"
[[ $? -ne 0 ]] && { echo "bcrypt failed!";  exit $?; }
# bcrypt adds .bfe suffix to encrypted files
[[ ! -e $TARGET.bfe ]] && { echo "Error! File not found: $TARGET.bfe";  exit 1; }

ls -las "$TARGET".bfe
exit 0
