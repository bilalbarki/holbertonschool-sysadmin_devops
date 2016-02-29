#!/bin/bash
get=0
head=0
IFS=''
while read -r line #|| [ -n "$line" ]
do
    if [ $(echo $line | grep -o HEAD) ]
    then
	head=$((head+1))
    elif [ $(echo $line | grep -o GET) ]
    then
	get=$((get+1))
    fi
done < "$1"

echo $head
echo $get
