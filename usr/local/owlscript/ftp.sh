#!/bin/bash

source /etc/owlscript

filename=ustream2.log
#filename=test.txt

echo "Uploading picture..."
/usr/bin/ftp -inv $FTPSERVER << EOF
user $FTPUSERNAME $FTPPASSWORD
cd cam1
put $filename
bye
EOF

