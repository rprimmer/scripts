#!/bin/sh
# End-to-end test of cc-transcript: carry hostile values (NUL, backtick runs,
# </details>, <script>, bytes that are not UTF-8, an unfinished final record)
# through every record kind, then check the Markdown's structure.
# With --all, also check the transcript of every local session.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
script="$here/../../cc-transcript"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

python3 "$here/gen_hostile.py" "$tmp/s.jsonl"
"$script" "$tmp/s.jsonl" -o "$tmp/full.md" 2>/dev/null
"$script" "$tmp/s.jsonl" --brief -o "$tmp/brief.md" 2>/dev/null
for f in full brief; do
    printf '%s: ' "$f"
    python3 "$here/check_md.py" "$tmp/$f.md"
done
grep -q 'Record of type `brand-new-type`' "$tmp/full.md" || { echo "unknown record type not reported"; exit 1; }
grep -q 'bad .* bytes' "$tmp/full.md" || { echo "record with bytes that are not UTF-8 lost"; exit 1; }

if [ "${1:-}" = --all ]; then
    n=0
    for s in "$HOME"/.claude/projects/*/*.jsonl; do
        "$script" "$s" -o "$tmp/x.md" 2>/dev/null || continue
        python3 "$here/check_md.py" "$tmp/x.md" >/dev/null || { echo "FAIL: $s"; exit 1; }
        n=$((n + 1))
    done
    echo "all local sessions: $n OK"
fi
