#! /bin/sh
# Word frequency count
cat $1 | tr ' ' '\n' | sort | uniq -c | sort

# Another alternative
# cat $1 | awk '{for(i=1;i<=NF;++i){D[$i]++}}END{for(k in D)print k, D[k]}' | sort -k2nr
