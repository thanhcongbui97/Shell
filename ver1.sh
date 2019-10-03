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

    sed -i $LINE_NO's/\\/BSLASH/g' $FILE
    sed -i $LINE_NO's/&/AND/g' $FILE
    sed -i $LINE_NO's/\[/OSBRK/g' $FILE
    sed -i $LINE_NO's/]/CSBRK/g' $FILE
           
    if [[ $FIRST_WORD == "{" ]]
    then

        #Check if the line has more word 
        if [[ ${#CONTENT} > 1 ]]
        then
            #Replace curly bracket by a curly bracket and a carriage return
            sed -i "${LINE_NO}s/{/{\n/" $FILE
            
            #Get the content of line again
            GET_CONTENT $LINE_NO
        fi

        #Set the content to current tab level
        CORRECT_CONTENT=$TAB$CONTENT

        #Increase tab level by 1
        CUR_TAB=$[ $CUR_TAB + 1 ]

        #Set the length of current tab
        TAB=$TAB$SPACE

    elif [[ $FIRST_WORD == "}" ]]
    then
        A_CUR=$(echo $CONTENT | grep "}t.*" -o)

        #Check if the line has more word
        if [[ (${#CONTENT} > 1)  &&  ($CONTENT != "};") ]]
        then
            #echo $LINE_NO = $A_CUR = ${#A_CUR}
            if [[ ${#A_CUR} > 0 ]]
            then
                echo ${#A_CUR}
            else
            #Replace curly bracket by a curly bracket and a carriage return
                sed -i "${LINE_NO}s/}/}\n/" $FILE
            fi
            #Get the content of line again
            #GET_CONTENT $LINE_NO
        fi

        #Get the content of line again
        GET_CONTENT $LINE_NO

        #Decrease tab level by 1
        CUR_TAB=$[ $CUR_TAB - 1 ]
        
        #Calculate the length of current tab
        C_TAB=$CUR_TAB
        STAB=""
        while [[ C_TAB -gt 0 ]]
        do
            STAB=$SPACE$STAB
            C_TAB=$[ $C_TAB - 1 ]
        done

        #Set the length of current tab
        TAB=$STAB

        #Set content to current tab (After decrease)
        CORRECT_CONTENT=$TAB$CONTENT
        
    elif [[ ${CONTENT:0:2} == "/*" ]]
    then
        comment_flag=1
        
        GET_CONTENT $LINE_NO
        CORRECT_CONTENT=$TAB$CONTENT
        if [[ $CONTENT =~ "*/" ]]
        then
            #Ran out of comment
            comment_flag=0
        fi

    elif [[ ${CONTENT:0:4} == "for " || ${CONTENT:0:4} == "for(" ]]
    then
        sed -i "${LINE_NO}s/{/\n{/g" $FILE
        sed -i "${LINE_NO}s/}/\n}/g" $FILE

        GET_CONTENT $LINE_NO
        CORRECT_CONTENT=$TAB$CONTENT
        
    else 
        #The content is default started by a character

        sed -i "${LINE_NO}cCONTENT"  $FILE

        #Get the content after a colon
        COLON=$(sed -n ${LINE_NO}p $FILE | grep ";.*" -o )
        COCO=${COLON:1}

        #Check if these content is contain more commands
        if [[ ${#COLON} > 1 ]]
        then
            #echo $COLON
            #Let this commands fall down to the next line
            sed -i "${LINE_NO}s/${COCO}/\n${COCO}/" $FILE
        fi

        ARR_DEC=$(sed -n ${LINE_NO}p $FILE | grep "=[ ]*{" -o )
        if [[ ${#ARR_DEC} > 1 ]]
        then
            echo "Declare an array"
        else
        #Put all curly bracket to next line
        sed -i "${LINE_NO}s/{/\n{/" $FILE
        sed -i "${LINE_NO}s/}/\n}/" $FILE
        fi
        #Get the content again
        GET_CONTENT $LINE_NO

        VAR=$(echo $CONTENT | grep "if.*(.*$VAR_MARK.*==" -o | grep "(.*" -o | grep "$VAR_MARK*" -o)
        if [[ ${#VAR} > 0 ]]
        then
        CONST=$(echo $CONTENT | grep "==.*[0-9]*.*)" -o | grep "[0-9]*" -o)
        #echo $VAR $CONST
        CONTENT="if ( $CONST == $VAR );"
        #echo $CONTENT
        fi

        DUP=$(echo $CONTENT | grep "($VAR_MARK" )
        if [[ ${#DUP} > 1 ]]
        then
            #echo $DUP
            #echo $LINE_NO
            sed -i "${LINE_NO}s/(/( /" $FILE
        fi
        
        CORRECT_CONTENT=$TAB$CONTENT

    fi
    fi

    #echo $CORRECT_CONTENT
    #echo $LINE_NO = $COLON

    #Replace current content by a corrected content
        sed -i $LINE_NO's/\\/?/g' $FILE
        
        if [[ ${CONTENT:0:3} != "for" ]]
        then
            sed -i "${LINE_NO}c+${CORRECT_CONTENT}" $FILE
            sed -i "${LINE_NO}s/+//" $FILE
        else
            sed -i "${LINE_NO}s/${LINE}/${CORRECT_CONTENT}/" $FILE
        fi

        sed -i "${LINE_NO}s/STR/$STR/g" $FILE
    
        sed -i $LINE_NO's/BSLASH/\\/g' $FILE
        sed -i $LINE_NO's/AND/\&/g' $FILE
        sed -i $LINE_NO's/OSBRK/[/g' $FILE
        sed -i $LINE_NO's/CSBRK/]/g' $FILE
        #sed -i $LINE_NO's/BLANK//g' $FILE
    LINE_NO=$(( $LINE_NO + 1 ))
done