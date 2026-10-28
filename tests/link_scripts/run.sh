#!/bin/sh
# End-to-end test of link_scripts.sh in a scratch SCRIPTS_DIR and LOCAL_BIN:
# which files get linked, that subfolders are not entered, that existing
# links are kept without -o, and names with spaces and % survive.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../../link_scripts.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
src="$tmp/scripts"
bin="$tmp/bin"
mkdir -p "$src/sub"
fail=0
check() {   # check DESCRIPTION TEST...
    d=$1; shift
    if "$@"; then echo "ok   $d"; else echo "FAIL $d"; fail=1; fi
}

printf 'echo a\n' > "$src/plain.sh"              # extension, no x bit
printf 'echo b\n' > "$src/tool"; chmod +x "$src/tool"   # no extension, x bit
printf 'echo c\n' > "$src/my tool %20"; chmod +x "$src/my tool %20"
printf 'notes\n'  > "$src/notes.txt"              # neither
printf 'readme\n' > "$src/README"                 # neither
printf 'echo d\n' > "$src/sub/deep"; chmod +x "$src/sub/deep"
ln -s tool "$src/alias"                           # link to an executable
printf 'echo e\n' > "$src/kept.sh"
mkdir -p "$bin"; ln -s /dev/null "$bin/kept.sh"   # existing link, not ours

SCRIPTS_DIR=$src LOCAL_BIN=$bin "$script" -k >"$tmp/out" 2>&1 || {
    echo "FAIL script exited non-zero:"; cat "$tmp/out"; exit 1; }

check "extension: linked"           test -L "$bin/plain.sh"
check "extension: x bit set"        test -x "$src/plain.sh"
check "executable, no extension"    test -L "$bin/tool"
check "space and % in name"         test "$(readlink "$bin/my tool %20")" = "$src/my tool %20"
check "link to an executable"       test -L "$bin/alias"
check "not executable: skipped"     test ! -e "$bin/notes.txt"
check "no extension, no x: skipped" test ! -e "$bin/README"
check "README keeps its mode"       test ! -x "$src/README"
check "subfolder not entered"       test ! -e "$bin/deep"
check "subfolder itself skipped"    test ! -e "$bin/sub"
check "existing link kept"          test "$(readlink "$bin/kept.sh")" = /dev/null

SCRIPTS_DIR=$src LOCAL_BIN=$bin "$script" -k -o >/dev/null 2>&1
check "-o replaces existing link"   test "$(readlink "$bin/kept.sh")" = "$src/kept.sh"

exit $fail
