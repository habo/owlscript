#!/bin/bash

source /etc/owlscript

if [ $RUNBOOTSCRIPT ] ; then
	$DEBUG && echo "run boot script"
	$DEBUG && echo "stream startet in $STREAMDELAY"
	sleep $STREAMDELAY && $OWLBASE/streamupload.sh &
fi
