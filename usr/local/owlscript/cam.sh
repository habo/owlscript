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
$DEBUG && echo "$out"


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
	CAMDIR="CAM$INPUT"
	if [ -e /dev/video$INPUT ]; then
		/usr/bin/fswebcam -r $USBRESOLUTION --no-banner $filename -i $INPUT
		#Schriftzug erstellen als PNG
		/usr/bin/convert -size $USBRESOLUTION xc:transparent -font Courier-bold -pointsize 20 -fill white -draw "text 10,460 '$out | $date " watermark.png
		# Cam-Bild und Schriftzug zusammenbringen
		/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename $filename
	else
		echo "no such file or cam: /dev/video$INPUT"
	fi
fi

if [ "$1" == "hd" ]; then
	CAMDIR="cam1"
	/opt/vc/bin/raspistill -t 500 -o $filename -vf -hf --rotation 180 -v --nopreview -q 40 -w 1600 -h 1200
	  
	#Schriftzug erstellen als PNG
	/usr/bin/convert -size $HDRESOLUTION xc:transparent -font Courier-bold -pointsize 50 -fill white -draw "text 20,1150 '$out | $date " watermark.png
	# Cam-Bild und Schriftzug zusammenbringen
	/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename $filename
fi

$DEBUG && echo "use CAMDIR=$CAMDIR"

if $AUTOFTPUPLOAD ;then
echo "Uploading picture..."
/usr/bin/ftp -inv $FTPSERVER << EOF
user $FTPUSERNAME $FTPPASSWORD
cd $FTPBASEDIRECTORY
cd $CAMDIR
put $filename
bye
EOF
fi 

echo "Remove CAM folder directory"
$DEBUG || rm $TMPDIR -rf

