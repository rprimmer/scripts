#!/usr/bin/env bash

# Change the shebang line of one or more scripts. T
# This can be useful for changing groups of python scripts 
# Example: change-shebang.sh python2.7 *.py
# Dependencies:  realpath  
# if realpath is not available on macOS you can get it on homebrew 
# run:  brew install coreutils 

interpreter="$1"
shift

if [ -z "$(type -P $interpreter)" ] ; then
  echo "Error: '$interpreter' is not executable." >&2
  exit 1
fi

if [ ! -d "$interpreter" ] && [ -x "$interpreter" ] ; then
  shebang='#!'"$(realpath -e $interpreter)" || exit 1
else
  shebang='#!'"$(type -P $interpreter)"
fi

for f in "$@" ; do
  printf "%s\n" 1 i "$shebang" . w | ed "$f"
done