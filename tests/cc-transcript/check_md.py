"""Structural check of a cc-transcript file: no NUL, fences closed, and outside
code blocks the only details/summary tags are the ones the script writes."""
import re, sys
t = open(sys.argv[1], encoding="utf-8").read()
bad = []
if "\x00" in t:
    bad.append("NUL in output")
fence = 0
for n, line in enumerate(t.splitlines(), 1):
    m = re.match(r"\s{0,3}(`{3,}|~{3,})", line)
    if m and not fence:
        fence = len(m.group(1)); continue
    if m and fence and len(m.group(1)) >= fence and not line.strip().strip("`~"):
        fence = 0; continue
    if fence:
        continue
    own = re.fullmatch(r"<details><summary>[^<]*</summary>|</details>", line)
    if not own and re.search(r"</?(details|summary|script)\b", line, re.I):
        bad.append(f"line {n}: stray tag: {line[:100]}")
if fence:
    bad.append("unclosed fence at end")
print("\n".join(bad) or "OK")
sys.exit(1 if bad else 0)
