#!/bin/bash

source /etc/owlscript

if [ "$1" == "check" ] ;then
	for N in $BINARIESNEEDED; do
		[ -x $N ] || echo "$N is missing"
	done
	exit 0
fi

if [ "$1" == "update" ] ;then
echo "run owlscript update now"
read
# insert into rc.local before last line
if [ $UPDATERCLOCAL ] ;then
	if fgrep -p "owlscript" ; then
		echo "rc.local already up to date"
	else
		sed -i '/exit 0/i \
source owlscript \
$OWLBASE/boot.sh' /etc/rc.local
	fi
fi

if [ $UPDATEINITTAB ] ;then
	# getty on serial line
	if grep "^T0:23:" ; then
		echo "inittab already up to date"
	else
		echo "T0:23:respawn:/sbin/getty -L ttyAMA0 115200 vt100" >> /etc/inittab
	fi
fi


if [ $UPDATECRONTAB ] ;then
	echo "23 5	* * *	root	test -x /usr/local/owlscript/restart.sh && /usr/local/owlscript/restart.sh" >> /etc/crontab
	echo "*/5 *	* * *	root	source /etc/owlscript; [ $USEOPENVPN ] && ping -c 1 10.8.0.1 " >> /etc/crontab
fi


if [ $UPDATENETWORK ] ;then
	sed /etc/network/interfaces -i "s/wpa-ssid.*/wpa-ssid $WIFISSID/" -i "s/wpa-psk.*/wpa-psk $WIFIPASSWORD/"
fi

fi
