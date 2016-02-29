#!/bin/bash
IFS=''
while read -r line #|| [ -n "$line" ]
do
    if [ $(echo $line | grep -o HEAD) ]
    then
	echo $line
    fi
done < "$1"
