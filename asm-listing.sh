#!/usr/bin/env bash

# Disassemble a C file with its source lines interleaved, as a .lst file that
# VS Code highlights as ARM64 assembly (MKornelsen.vscode-arm64, with
# "files.associations": { "*.lst": "arm64" } in settings.json).
#
# What it runs, and why each flag is there:
#
#   clang -O0 -g -c foo.c -o foo.o
#       -O0  do not optimize the C code (e.g., with -O2) as it makes the resulting assembly harder to follow
#       -g   record which C line each instruction came from (needed by --source)
#       -c   compile to an object file only; don't link
#
#   objdump -d -r --source --no-show-raw-insn foo.o | sed 's|;|//|' > foo.lst
#       -d                  disassemble the code
#       -r                  name the function each call goes to (bl _bzero, not bl 0x1f8)
#       --source            print the C lines above their instructions
#       --no-show-raw-insn  hide each instruction's hex encoding
#       sed 's|;|//|'       Apple's assembler comments start with ';', but
#                           the VS Code highlighter only knows '//'. Only the
#                           first ';' on a line changes, so C statements keep
#                           their own semicolons.
#
# Related commands worth remembering:
#   clang -O0 -S foo.c              plain assembly in foo.s (no C source;
#                                   -fverbose-asm adds nothing, it is the default)
#   clang -O0 -S -o - foo.c         the same, to the terminal
#   godbolt.org                     the same idea in a browser, any compiler
#
# At -O2 the compiler reorders code, so C lines can appear out of order or
# more than once; compare with -O0 or -O1 when it gets confusing.

set -euo pipefail

usage() {
    cat <<EOF
usage: $(basename "$0") [-o OUT.lst] FILE.c [COMPILER FLAGS...]

Writes FILE.lst next to FILE.c: the disassembly with the C source between
the instructions. Compiler flags default to -O0; any given replace it
(e.g. $(basename "$0") foo.c -O2).

options:
  -o OUT   write the listing here instead (- for standard output)
  -h       show this help
EOF
}

out=""
while getopts ":o:h" opt; do
    case $opt in
        o) out=$OPTARG ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift $((OPTIND - 1))

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 2
fi
src=$1
shift
if [[ ! -f $src ]]; then
    echo "$(basename "$0"): no such file: $src" >&2
    exit 1
fi
flags=("$@")
for f in "${flags[@]}"; do
    # Everything after FILE.c goes to clang, so a misplaced -o would quietly
    # become clang's output flag and the listing would land in FILE.lst.
    if [[ $f == -o* || $f == -h ]]; then
        echo "$(basename "$0"): put $f before FILE.c (arguments after it go to clang)" >&2
        exit 2
    fi
done
if [[ ${#flags[@]} -eq 0 ]]; then
    flags=(-O0)
fi
out=${out:-${src%.*}.lst}

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

clang "${flags[@]}" -g -c "$src" -o "$tmp/obj.o"
if [[ $out == - ]]; then
    objdump -d -r --source --no-show-raw-insn "$tmp/obj.o" | sed 's|;|//|'
else
    objdump -d -r --source --no-show-raw-insn "$tmp/obj.o" | sed 's|;|//|' > "$out"
    echo "wrote $out (clang ${flags[*]})" >&2
fi
