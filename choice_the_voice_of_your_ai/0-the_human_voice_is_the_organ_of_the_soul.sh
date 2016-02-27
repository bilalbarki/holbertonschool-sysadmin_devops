#!/bin/bash
file=$(echo $1 | awk '{print $1}')
IP=$3;
case $2 in
    m)
        espeak -ven-us+m4 -s100 "$1" --stdout > $file.wav;;
    f)
        espeak -ven-us+f4 -s100 "$1" --stdout > $file.wav;;
    x)
	espeak -s 40 -v en+m5 -p 70 "$1" --stdout > $file.wav;;
esac

scp $file.wav admin@$IP:/var/www/html/$file.wav
echo "Listen to the message on http://$IP/$file.wav"
rm $file.wav
