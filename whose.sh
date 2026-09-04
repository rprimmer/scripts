#!/bin/sh

# Display a process tree, optionally limited to branches matching a string.

ps -axo user=,pid=,ppid=,command= | awk -v lookfor="${1:-}" '
{
    user = $1
    pid = $2
    ppid = $3
    $1 = $2 = $3 = ""
    sub(/^[[:space:]]+/, "")
    details[pid] = "(" user "," $0 ")"
    parent[pid] = ppid
    child_count[ppid]++
    children[ppid, child_count[ppid]] = pid
}

END {
    if (lookfor == "") {
        for (pid in details) keep[pid] = 1
    } else {
        needle = tolower(lookfor)
        for (pid in details) {
            if (index(tolower(details[pid]), needle)) mark_branch(pid)
        }
    }

    if (1 in details) print_tree(1, "", "")
    for (pid in details) {
        if (pid != 1 && !(parent[pid] in details)) print_tree(pid, "", "")
    }
}

function mark_branch(pid) {
    while (pid && !keep[pid]) {
        keep[pid] = 1
        pid = parent[pid]
    }
}

function print_tree(pid, own_prefix, child_prefix,    i, child, remaining) {
    if (!keep[pid] || printed[pid]) return
    printed[pid] = 1
    print own_prefix pid " - " details[pid]

    remaining = 0
    for (i = 1; i <= child_count[pid]; i++) {
        child = children[pid, i]
        if (keep[child]) remaining++
    }
    for (i = 1; i <= child_count[pid]; i++) {
        child = children[pid, i]
        if (!keep[child]) continue
        remaining--
        if (remaining > 0)
            print_tree(child, child_prefix "|__", child_prefix "|  ")
        else
            print_tree(child, child_prefix "\\__", child_prefix "   ")
    }
}
'
