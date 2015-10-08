#!/bin/bash

source /etc/owlscript

if $RUNBOOTSCRIPT ; then
	debug "run boot script and start in $STREAMDELAY"
	$RUNSTREAMJOB && sleep $STREAMDELAY && $OWLBASE/streamupload.sh &
fi
