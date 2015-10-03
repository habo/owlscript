#!/bin/bash

#temperatur und feuchtigkeitswerte werdenausgelesen und in eine datei geschrieben

source /etc/owlscript
[ -d $OWLLOG ] || mkdir -p $OWLLOG
# nr 7 ist der GPIO PIN
temp=$(sudo $OWLBASE/loldht $DHTPIN)
echo "$temp" > $OWLLOG/temp.txt

#hum=$(grep "Humidity" temp.txt | awk -F" " {'print $3'})
#temp=$(grep "Temperature" temp.txt | awk -F" " {'print $7'})

#out="Temp: ${temp}°C - Hum: ${hum}%"
# echo "$out"

