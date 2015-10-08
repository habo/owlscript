#!/bin/bash

source /etc/owlscript

function checkdependencies(){
	ret=0
	for N in $BINARIESNEEDED; do
		if [ -x $N ] ; then
			echo "OK   $N"
		else
			echo "missing $N"
			ret=1
		fi
	done
	exit $ret
}

function updaterclocal(){
	# insert into rc.local before last line
	debug "updaterclocal"
	if fgrep -q "owlscript" /etc/rc.local ; then
		echo "rc.local already up to date"
	else
		sed -i "/^exit 0/i $OWLBASE/boot.sh" /etc/rc.local
	fi
}
function updateinittab(){
	debug "updateinittab"
	# getty on serial line
	if grep -q "^T0:23:" /etc/inittab; then
		echo "inittab already up to date"
	else
		echo "T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100" >> /etc/inittab
	fi
}
function updatecrontab(){
	debug "updatecrontab"
	fgrep -q "$OWLBASE/restart.sh" /etc/crontab || echo "23 5	* * *	root	source /etc/owlscript; $RUNAUTOREBOOT && test -x $OWLBASE/restart.sh && $OWLBASE/restart.sh" >> /etc/crontab
	fgrep -q "USEOPENVPN" /etc/crontab || echo '*/5 *	* * *	root	source /etc/owlscript; $USEOPENVPN && ping -c 1 10.8.0.1 ' >> /etc/crontab
}
function updatenetwork(){
	debug "updatenetwork"
	if grep -q wpa-ssid /etc/network/interfaces; then	
		sed /etc/network/interfaces -i -e "s/wpa-ssid.*/wpa-ssid $WIFISSID/" -e "s/wpa-psk.*/wpa-psk $WIFIPASSWORD/"
	else
		debug "add wlan0 section to /etc/network/interfaces"
	cat >> /etc/network/interfaces << EOF	
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-ap-scan 1
wpa-scan-ssid 1
wpa-ssid $WIFISSID
wpa-psk $WIFIPASSWORD
EOF

	fi

	
}
function update(){
	echo "run owlscript update now"
	
	$UPDATERCLOCAL && updaterclocal
	$UPDATEINITTAB && updateinittab
	$UPDATECRONTAB && updatecrontab
	$UPDATENETWORK && updatenetwork
}

function backup(){
	[ -d $BACKUPDIRECTORY ] || mkdir $BACKUPDIRECTORY
	STORE="/etc/rc.local /etc/network/interfaces /etc/inittab /etc/crontab "
	for FILE in $STORE; do
		cp -b $FILE $BACKUPDIRECTORY
	done
}

case $1 in
	check)
		checkdependencies
	;;
	backup)
		backup
	;;
	update)
		update
	;;
	*)
		echo "$0 <COMMAND> <PARAMETER>"
		echo "    Commands are:"
		echo "       check      - check dependencies"
		echo "       update     - update files"
		echo "       backup     - backup to $BACKUPDIRECTORY"
	;;
esac


