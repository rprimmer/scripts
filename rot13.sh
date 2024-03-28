#! /usr/bin/env bash 
 
# Choose your favorite table
 
# classic
# SIGNS=( a b c d e f g h i j k l m n o p q r s t u v w x y z )
 
# advanced
SIGNS=( a b c d f e h g j i l k m n o p q r s t u v w x y z . - ? ! "#" "+" )
 
# full
# SIGNS=( a b c d e f g h i j k l m n o p q r s t u v w x y z
# A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
# 0 1 2 3 4 5 6 7 8 9 0 )  
 
query() { 
    nc=0
    while [ $nc -lt ${#SIGNS[@]} ]; do 
        if [ "$1" = "${SIGNS[$nc]}" ]; then
            local ORIGNUM=$nc
        fi
        ((nc++))
    done
 
    if [  -z $ORIGNUM ]; then
        printf "%s " "$1"
        return
    fi
    ENCRYPTNUM=$(($ORIGNUM + ${#SIGNS[@]} / 2))
    if [ $ENCRYPTNUM -ge ${#SIGNS[@]} ]; then
        ENCRYPTNUM=$(($ENCRYPTNUM - ${#SIGNS[@]} ))
    fi
    
    printf "%s" ${SIGNS[$ENCRYPTNUM]} 
}

table() {
    for x in ${SIGNS[@]}; do
        printf "%s: " "$x"
        query $x
        echo
    done
}

main() {    
    if [ $# -eq 0 ]; then
        set -- "$(cat /dev/stdin)"
    fi
    local sc=0
    while [ $sc -lt ${#1} ]; do
        if [ "${1:$sc:1}" = " " ]; then 
            printf " "
        else
            query "${1:$sc:1}"
        fi 
        ((sc++))
    done
    echo 
}

case $1 in 
    -t) table ;;
    *) main "$@" ;;  
esac
