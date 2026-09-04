#!/usr/bin/env bash

# Resolve an IPv4 address iteratively from a root DNS server.

if [ "$#" -ne 1 ]; then
    echo "Usage: $(basename "$0") domain" >&2
    exit 1
fi

case $1 in
    *[!A-Za-z0-9.-]*|'') echo "Invalid domain: $1" >&2; exit 1 ;;
esac

lookup () {
    echo dig "$@" >&2
    dig +time=2 +tries=1 +norecurse +noall +authority +answer +additional "$@"
}

resolve() {
   DOMAIN=${1%.}
   # start with a `.` nameserver. That's easy.
   NAMESERVER="198.41.0.4"
   attempts=0
   while [ "$attempts" -lt 50 ]
   do
       attempts=$((attempts + 1))
       RESPONSE=$(lookup @"$NAMESERVER" "$DOMAIN")
       IP=$(printf '%s\n' "$RESPONSE" | awk -v domain="$DOMAIN." '$1 == domain && $4 == "A" { print $5; exit }')
       CNAME=$(printf '%s\n' "$RESPONSE" | awk -v domain="$DOMAIN." '$1 == domain && $4 == "CNAME" { print $5; exit }')
       GLUEIP=$(printf '%s\n' "$RESPONSE" | awk '$4 == "A" { print $5; exit }')
       NS=$(printf '%s\n' "$RESPONSE" | awk '$4 == "NS" { print $5; exit }')
       if [ -n "$IP" ]; then
           echo "$IP"
           return 0
       elif [ -n "$CNAME" ]; then
           DOMAIN=${CNAME%.}
           NAMESERVER="198.41.0.4"
       elif [ -n "$GLUEIP" ]; then
           NAMESERVER="$GLUEIP"
       elif [ -n "$NS" ]; then
           NAMESERVER=$(dig +short "$NS" A | awk 'NF { print; exit }')
           [ -n "$NAMESERVER" ] || break
       else
           break
       fi
   done
   echo "Iterative lookup unavailable; trying the system resolver." >&2
   IP=$(dig +time=2 +tries=1 +short "$DOMAIN" A | awk '/^[0-9]+(\.[0-9]+){3}$/ { print; exit }')
   if [ -n "$IP" ]; then
       echo "$IP"
       return 0
   fi

   echo "No IPv4 address found for $DOMAIN" >&2
   return 1
}

resolve "$1"
