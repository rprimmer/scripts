#!/usr/bin/env bash
 
# This uses the selected half-rotation table. The active "advanced" table is a
# custom substitution cipher; select the classic 26-letter table for ROT13.
 
# classic
# SIGNS=( a b c d e f g h i j k l m n o p q r s t u v w x y z )
 
# advanced
SIGNS=( a b c d f e h g j i l k m n o p q r s t u v w x y z . - ? ! "#" "+" )
 
# full
# SIGNS=( a b c d e f g h i j k l m n o p q r s t u v w x y z
# A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
# 0 1 2 3 4 5 6 7 8 9 0 )  
 
query() { 
    local nc=0 ORIGNUM=""
    while (( nc < ${#SIGNS[@]} )); do
        if [ "$1" = "${SIGNS[$nc]}" ]; then
            ORIGNUM=$nc
        fi
        ((nc++))
    done
 
    if [[ -z "$ORIGNUM" ]]; then
        printf "%s " "$1"
        return
    fi
    local ENCRYPTNUM=$((ORIGNUM + ${#SIGNS[@]} / 2))
    if (( ENCRYPTNUM >= ${#SIGNS[@]} )); then
        ENCRYPTNUM=$((ENCRYPTNUM - ${#SIGNS[@]}))
    fi
    
    printf "%s" "${SIGNS[$ENCRYPTNUM]}"
}

table() {
    local x
    for x in "${SIGNS[@]}"; do
        printf "%s: " "$x"
        query "$x"
        echo
    done
}

main() {    
    local input
    if [ $# -eq 0 ]; then
        input=$(cat /dev/stdin)
    else
        input="$*"
    fi
    local sc=0
    while (( sc < ${#input} )); do
        if [[ "${input:$sc:1}" == " " ]]; then
            printf " "
        else
            query "${input:$sc:1}"
        fi 
        ((sc++))
    done
    echo 
}

case ${1:-} in
    -t) table ;;
    *) main "$@" ;;  
esac
