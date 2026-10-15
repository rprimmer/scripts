"""Write a session file carrying hostile values through every record kind."""
import json, sys
H = "a\u0000b ```` </details> <script>x</script> %s %00 \"q\" 'q'"
recs = [
 {"type": "user", "uuid": "u1", "timestamp": "2026-10-15T18:00:00Z", "cwd": "/tmp/x",
  "message": {"role": "user", "content": "prompt " + H + "\n```\nfenced\n```"}},
 {"type": "assistant", "uuid": "a1", "timestamp": "2026-10-15T18:00:01Z", "message": {"model": "m", "content": [
   {"type": "thinking", "thinking": "think " + H},
   {"type": "text", "text": "reply " + H},
   {"type": "tool_use", "id": "t1", "name": "Bash",
    "input": {"command": "echo '" + H + "'", "description": "desc </summary></details> " + H}}]}},
 {"type": "user", "uuid": "u2", "timestamp": "2026-10-15T18:00:02Z",
  "message": {"role": "user", "content": [{"type": "tool_result", "tool_use_id": "t1", "content": "x"}]},
  "toolUseResult": {"stdout": "out " + H + "\n````\n</details> early close\n<script>alert(1)</script>",
                    "stderr": "err " + H}},
 {"type": "attachment", "uuid": "x1", "timestamp": "2026-10-15T18:00:03Z",
  "attachment": {"type": "hook_system_message", "hookName": "h", "content": "*hook* " + H}},
 {"type": "attachment", "uuid": "x3", "timestamp": "2026-10-15T18:00:04Z",
  "attachment": {"type": "edited_text_file", "filename": "/tmp/a\u0000b </details>.md"}},
 {"type": "brand-new-type", "uuid": "x2", "timestamp": "2026-10-15T18:00:04Z"},
]
with open(sys.argv[1], "wb") as f:
    for r in recs:
        f.write(json.dumps(r).encode() + b"\n")
    f.write(b'{"type":"user","uuid":"u3","timestamp":"2026-10-15T18:00:05Z",'
            b'"message":{"role":"user","content":"bad \xff\xfe bytes"}}\n')
    f.write(b'{"type":"user","uuid":"u4","mess')  # unfinished final record
