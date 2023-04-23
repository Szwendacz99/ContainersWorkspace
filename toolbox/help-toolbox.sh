#!/bin/bash

# print $1 element $2 times, or if only one argument
# supplied then print space $1 times
function repeat() {
    x=0
    
    if [ $# -eq 2 ]; then
        char="$1"
        count="$2"
    else
        char=" "
        count="$1"
    fi
    while [ $x -lt "$count" ]; 
        do
            echo -n "$char"
            x=$((x+1))
        done
}
# print "fancy title"
function printTitle() {
    termWidth=$(tput cols)
    textWidth=$(echo -n "$1" | wc -c)
    spaces1=$(((termWidth-textWidth-2) / 2))
    spaces2=$((termWidth-spaces1-textWidth-2))

    repeat "#" "$termWidth"
    echo ""
    echo -n "#"
    repeat $spaces1 
    echo -n "$1"
    repeat $spaces2
    echo "#"
    repeat "#" "$termWidth"
}

# print tools sorted by category

printTitle "Toolbox pkgs"

printTitle "General"
printTitle "Processes"
printTitle "Network"
printTitle "Memory"
printTitle "Storage"
