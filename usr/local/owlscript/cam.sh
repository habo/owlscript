#!/bin/bash
# statische usb oder interne hd kamera wird aktiviert und bild(er) auf FTP geschoben

source /etc/owlscript

if [ -z "$1" ]; then
	echo "need argument 'hd|usb <n>' to choose source, usb with optional camnr"
	exit 1
fi

TMPDIR=/tmp/cam
[ -d $TMPDIR ] || mkdir -p $TMPDIR
cd $TMPDIR

# Hum / Temp Variable definieren
[ -d $OWLLOG ] || mkdir -p $OWLLOG
hum=$(grep "Humidity" $OWLLOG/temp.txt | awk -F" " {'print $3'})
temp=$(grep "Temperature" $OWLLOG/temp.txt | awk -F" " {'print $7'})
out="Temp: ${temp}°C - Hum: ${hum}%"
debug "$out"


# Take a picture
timestamp=$(date +%s)
date=$(date +"%d.%m.%Y %H:%M:%S")
filename=${timestamp}.jpg

CAMDIR="cam"

if [ "$1" == "usb" ]; then
	INPUT="0"
	if [ -n "$2" ]; then
		INPUT=$2
	fi
	let ID=$INPUT+2
	CAMDIR="CAM$ID"
        DEVICE=/dev/video$INPUT
	TEXTSIZE=20
	TEXT="text 10,460 '$out | $date "
	RESOLUTION=$USBRESOLUTION
	if [ -e $DEVICE ]; then
		/usr/bin/fswebcam -r $USBRESOLUTION --no-banner $filename -d $DEVICE
	else
		echo "no such file or cam: $DEVICE"
		exit 2
	fi
fi

if [ "$1" == "hd" ]; then
	CAMDIR="cam1"
	/opt/vc/bin/raspistill -t 500 -o $filename -vf -hf --rotation $HDROTATE -v --nopreview -q 40 -w $HDWIDTH -h $HDHEIGHT
	TEXTSIZE=50
	TEXT="text 20,1150 '$out | $date "
	RESOLUTION=$HDRESOLUTION
fi

# Cam-Bild und Schriftzug zusammenbringen
if [ -e $filename ]; then
	#Schriftzug erstellen als PNG
	/usr/bin/convert -size $RESOLUTION xc:transparent -font Courier-bold -pointsize $TEXTSIZE -fill white -stroke black -draw "$TEXT" watermark.png
	# und zusammenführen
	/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename $filename
fi

debug "use CAMDIR=$CAMDIR"

if $AUTOFTPUPLOAD ;then
debug "Uploading picture..."
/usr/bin/ftp -inv $FTPSERVER << EOF
user $FTPUSERNAME $FTPPASSWORD
cd $FTPBASEDIRECTORY
mkdir $CAMDIR
cd $CAMDIR
put $filename
bye
EOF
fi 

debug "Remove CAM folder directory"
$DEBUG || rm $TMPDIR -rf

