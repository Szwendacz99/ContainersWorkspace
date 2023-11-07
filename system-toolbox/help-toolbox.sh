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
echo "htop -  interactive process viewer"
echo "btop - interactive multipurpose viewer"
echo "mpstat - monitor cpu usage with usage type distinction"
echo "iostat - monitor storage traffic"
printTitle "Processes"
echo "ps - list processes"
echo "strace - see syscalls of a process"
printTitle "Network"
echo "host - resolve addresses"
echo "dig - resolve adresses"
echo "nmap - advanced network scanning"
echo "telnet - open interactive tcp connection"
echo "tcpdump - monitor network packets"
echo "iftop - monitor network traffic per hosts"
echo 
printTitle "Memory"
printTitle "Storage"
echo "smartctl - check smart disks interfaces"
printTitle "Hardware"
echo "sensors - check temperatures"
