#!/bin/bash
# hd kamera wird aktiviert und live video nach ustream hochgeladen

source /etc/owlscript

if [ "$STREAMMODE" == "ustream" ]; then
	raspivid -n -t 0 -w 1600 -h 900 -fps 25 -b 500000 -o - | /usr/local/bin/ffmpeg -i - -vcodec copy -an -metadata title="Streaming from raspberry pi camera" -f flv $STREAMURL 
fi



