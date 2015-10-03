#!/bin/sh

source /etc/owlscript

datum=$(date +%d.%m.%y)
zeit=$(date +%H:%M:%S)

echo "Restart::" $datum - $zeit >> $OWLLOG/restart.log
sudo /sbin/shutdown -r now

