#!/bin/bash

LINK=$1
cd $LINK
FILE=$2

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

#Backslash
BACK_SLASH=\\

#Default flag for comment
comment_flag=0

function GET_CONTENT()
{
    #Get the full content of each line, to replace later
    LINE=$(sed -n ${LINE_NO}p $FILE)

                
    #Get only content that has been skipped
    CONTENT=$(echo $LINE)
}

function REPLACE_SPECIAL_CHARACTER()
{
    sed -i $LINE_NO's/\\/BSLASH/g' $FILE
    sed -i $LINE_NO's/&/AND/g' $FILE
    sed -i $LINE_NO's/\[/OSBRK/g' $FILE
    sed -i $LINE_NO's/]/CSBRK/g' $FILE
}

function RESTORE_SPECIAL_CHARACTER()
{
    sed -i $LINE_NO's/BSLASH/\\/g' $FILE
    sed -i $LINE_NO's/AND/\&/g' $FILE
    sed -i $LINE_NO's/OSBRK/[/g' $FILE
    sed -i $LINE_NO's/CSBRK/]/g' $FILE
}

while [[ LINE_NO -lt $LINE_END ]]
do
    GET_CONTENT $LINE_NO


    #Get the first character of content, which indicator line type
    FIRST_WORD=${CONTENT:0:1}

    #Check if this line is a comment
    if [[ $comment_flag == 1 || ${CONTENT:0:2} == "//" ]]
    then
        GET_CONTENT $LINE_NO
        CORRECT_CONTENT=$TAB$CONTENT
        if [[ $CONTENT =~ "*/" ]]
        then
            #echo "Out of comment"
            comment_flag=0
        fi

    else
    #Else, this line is a normal instruction

    #Check if content contain a double quotes 
        C_STR=$(echo $CONTENT | grep '".*"' -o)
        if [[ ${#C_STR} > 0 ]]
        then
            STR=$C_STR
            #echo $LINE_NO : $STR
            sed -i "${LINE_NO}s/${STR}/STR/g" $FILE
        fi

        REPLACE_SPECIAL_CHARACTER
           
        if [[ $FIRST_WORD == "{" ]]
        then

            #Check if the line has more word 
            if [[ ${#CONTENT} > 1 ]]
            then
                CLBRK=$(echo ${CONTENT:1})
                echo $CLBRK
                #sed -i "${LINE_NO}s/${CLBRK}/\nCLBRK/g" $FILE
            fi
        fi
    fi
    #sed -i "${LINE_NO}s/CLBRK/${CLBRK}/g" $FILE
    RESTORE_SPECIAL_CHARACTER
    sed -i "${LINE_NO}s/STR/$STR/g" $FILE

    LINE_NO=$(( $LINE_NO + 1 ))
done