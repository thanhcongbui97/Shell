#!/bin/bash

LINK="/home/thanhcong/Desktop/Shell/Project/"
cd $LINK
FILE='main.c'
LINE_START=1
LINE_END=100
LINE_NO=$LINE_START

#Define a tab length
SPACE="    "

#These starting content to be skipped
SKIP_CONTENT="[^ \t]"

#Variable marking
VAR_MARK="[a-zA-Z_&*]"

#Default Tab Indent
TAB=""

#Default tab level 
CUR_TAB=0

while [[ LINE_NO -lt 100 ]]
do
    sed -i $LINE_NO's/\\/?/g' $FILE
    sed -i $LINE_NO's/&/AND/g' $FILE
    
    LINE=$(sed -n $LINE_NO'p' $FILE)
    CONTENT=$(sed -n $LINE_NO'p' $FILE)

    CUR_TAB=$[ $CUR_TAB + 1 ]
    C_TAB=$[ $RANDOM % 7]
    STAB=""
    while [[ C_TAB -gt 0 ]]
    do
        STAB=$SPACE$STAB
        C_TAB=$[ $C_TAB - 1 ]
    done
    TAB=$STAB
    CORRECT_CONTENT=$TAB$CONTENT

    sed -i "${LINE_NO}c+${CORRECT_CONTENT}" $FILE
    sed -i "${LINE_NO}s/+//" $FILE

    sed -i $LINE_NO's/?/\\/g' $FILE
    sed -i $LINE_NO's/AND/\&/g' $FILE
    LINE_NO=$(( $LINE_NO + 1 ))
done