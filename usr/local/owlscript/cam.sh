#!/bin/bash
# statische usb oder interne hd kamera wird aktiviert und bild(er) auf FTP geschoben

source /etc/owlscript

if [ -z "$1" ]; then
	echo "need argument 'cam|hd' to choose source"
	exit 1
fi

TMPDIR=/tmp/cam
mkdir -p $TMPDIR
cd $TMPDIR

# Hum / Temp Variable definieren
[ -d $OWLLOG ] || mkdir -p $OWLLOG
hum=$(grep "Humidity" $OWLLOG/temp.txt | awk -F" " {'print $3'})
temp=$(grep "Temperature" $OWLLOG/temp.txt | awk -F" " {'print $7'})
out="Temp: ${temp}°C - Hum: ${hum}%"
#echo "$out"


# Take a picture
echo "Taking picture"
timestamp=$(date +%s)
date=$(date +"%d.%m.%Y %H:%M:%S")
filename=${timestamp}.jpg
#filename_small=${timestamp}_small.jpg

CAMDIR="cam"

if [ "$1" == "usb"]; then
	CAMDIR="cam2"
	/usr/bin/fswebcam -r $USBRESOLUTION --no-banner $filename

	#Schriftzug erstellen als PNG
	/usr/bin/convert -size $USBRESOLUTION xc:transparent -font Courier-bold -pointsize 20 -fill white -draw \
	"text 10,460 '$out | $date " watermark.png
	# Cam-Bild und Schriftzug zusammenbringen
	/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename $filename
fi

if [ "$1" == "hd"]; then
	CAMDIR="cam1"
	/opt/vc/bin/raspistill -t 500 -o $filename -vf -hf --rotation 180 -v --nopreview -q 40 -w 1600 -h 1
	  
	#Schriftzug erstellen als PNG
	/usr/bin/convert -size $HDRESOLUTION xc:transparent -font Courier-bold -pointsize 50 -fill white -draw 
	"text 20,1150 '$out | $date " watermark.png
	# Cam-Bild und Schriftzug zusammenbringen
	/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename $filename
						
	/opt/vc/bin/raspistill -t 500 -o $filename_small -vf -hf --rotation 180 -v --nopreview -q 80 -w 800
	  
	##Schriftzug erstellen als PNG         
	#/usr/bin/convert -size 800x600 xc:transparent -font Courier-bold -pointsize 25 -fill white -draw \ 
	#"text 20,575 '$out | $date " watermark.png
	##Cam-Bild und Schriftzug zusammenbringen
	#/usr/bin/composite -dissolve 50% -quality 100 watermark.png $filename_small $filename_small        
fi

if [ $AUTOFTPUPLOAD ] ;then
echo "Uploading picture..."
/usr/bin/ftp -inv $FTPSERVER << EOF
user $FTPUSERNAME $FTPPASSWORD
cd box1
cd $CAMDIR
put $filename
bye
EOF
fi 

echo "Remove CAM folder directory"
rm $TMPDIR -rf

