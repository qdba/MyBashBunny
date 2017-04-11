#!/bin/bash
#
# debug.sh v1 by @qdba
# provides some usefull tools for debugging a payload.txt
#
#

function START_DEBUG() {
	export LOGFILE="/tmp/$$.log"
	
	tail -n 1 -f /var/log/syslog > $LOGFILE &
	sleep 1
	logger -t PAYLOAD "################ Start Debug ###################"
}
export -f START_DEBUG


function STOP_DEBUG() {
	logger -t PAYLOAD "################ Stop Debug ###################"
	killall tail
	if [ "$(mount | grep /dev/nandf | awk '{printf $3}')" == "/root/udisk" ];then	
		cp $LOGFILE /root/udisk/loot/log.txt
		logger "copied $LOGFILE file to /root/udisk/loot/log.txt"
	else
		mount /dev/nandf /root/udisk		
		sleep 1
		cp $LOGFILE /root/udisk/loot/log.txt
		logger "mount /dev/nandf to /root/udisk and copied $LOGFILE file to /root/udisk/loot/log.txt"
		umount /dev/nandf
	fi
	sync; sleep 1; sync
}
export -f STOP_DEBUG

function LOG() {
	logger -t PAYLOAD "$1"
}
export -f LOG