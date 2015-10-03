#!/bin/bash
source /etc/owlscript

DIR=/var/www/still/
[ -d $DIR ] || mkdir -p $DIR
mount -t tmpfs -o size=$RAMDISKSIZE none $DIR
