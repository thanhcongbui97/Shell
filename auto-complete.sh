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

while [[ LINE_NO -lt $LINE_END ]]
do
    #Get the full content of each line, to replace later
    LINE=$(sed -n ${LINE_NO}p $FILE)

    #Get only content that has been skipped
    CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)

    #Get the first character of content, which indicator line type
    FIRST_WORD=${CONTENT:0:1}
    #echo $LINE_NO

    if [[ $FIRST_WORD == "{" ]]
    then

        #Check if the line has more word 
        if [[ ${#CONTENT} > 1 ]]
        then
            #Replace curly bracket by a curly bracket and a carriage return
            sed -i "${LINE_NO}s/{/{\n/" $FILE
            
            #Get the content of line again
            LINE=$(sed -n $LINE_NO'p' $FILE)
            CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)
        fi

        #Set the content to current tab level
        CORRECT_CONTENT=$TAB$CONTENT

        #Increase tab level by 1
        CUR_TAB=$[ $CUR_TAB + 1 ]

        #Set the length of current tab
        TAB=$TAB$SPACE

    elif [[ $FIRST_WORD == "}" ]]
    then

        #Check if the line has more word
        if [[ ${#CONTENT} > 1 ]]
        then
            #Replace curly bracket by a curly bracket and a carriage return
            sed -i "${LINE_NO}s/}/}\n/" $FILE
            
            #Get the content of line again
            LINE=$(sed -n $LINE_NO'p' $FILE)
            CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)
        fi

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

    elif [[ ${CONTENT:0:2} == "//" || ${CONTENT:0:2} == "/*" ]]
    then

        LINE=$(sed -n $LINE_NO'p' $FILE)   
        CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)
        CORRECT_CONTENT=$TAB$CONTENT
        echo ${#CONTENT}
        echo ${#CORRECT_CONTENT}
        echo $CORRECT_CONTENT

    elif [[ ${CONTENT:0:3} == "for" ]]
    then
        sed -i "${LINE_NO}s/{/\n{/g" $FILE
        sed -i "${LINE_NO}s/}/\n}/g" $FILE

        LINE=$(sed -n $LINE_NO'p' $FILE)
        CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)
        CORRECT_CONTENT=$TAB$CONTENT
        
    else #[[ $FIRST_WORD == [a-zA-Z] ]]
    #then
        #The content is default started by a character

        COLON=$(sed -n ${LINE_NO}p $FILE | grep ";.*" -o )
        COCO=${COLON:1}

        if [[ ${#COLON} > 1 ]]
        then
            sed -i "${LINE_NO}s/${COCO}/\n${COCO}/" $FILE
        fi
        sed -i "${LINE_NO}s/{/\n{/" $FILE
        sed -i "${LINE_NO}s/}/\n}/" $FILE

        LINE=$(sed -n $LINE_NO'p' $FILE)
        CONTENT=$(echo $LINE | grep "${SKIP_CONTENT}.*" -o)
        CORRECT_CONTENT=$TAB$CONTENT
    fi

    #echo $CORRECT_CONTENT

    #Replace current content by a corrected content
    if [[ ${CONTENT:0:3} != "for" ]]
    then
        sed -i "${LINE_NO}s+${LINE}+${CORRECT_CONTENT}+" $FILE
    else
        sed -i "${LINE_NO}/${LINE}/${CORRECT_CONTENT}/" $FILE
    fi
    
    LINE_NO=$(( $LINE_NO + 1 ))
done