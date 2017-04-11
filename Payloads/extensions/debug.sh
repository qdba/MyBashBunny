#!/bin/bash
#
# qdba_lib.sh v1 by @qdba
# provides some usefull tools for debugging a payload.txt
#
# QDBA_lib # Some usefull functions


#########################################################
#####             Debug Functions                   ##### 
#########################################################
#														#
# START_DEBUG   										#
# 		- Starts the debugging							#
# 														#
# LOG <Information>  									#
# 		- writes some Information to /var/log/syslog	#
#														#
# Stop_DEBUG 											#
# 		- stops debugging and copy the log file 		#
#		  from /tmp to /loot at the bunny flash disk	#
#########################################################

# START_DEBUG
function START_DEBUG() {
	trap STOP_DEBUG EXIT
	export LOGFILE="/tmp/$$.log"
	
	tail -n 1 -f /var/log/syslog > $LOGFILE &
	export PID_TAIL=$!
	sleep 1
	logger -t "[PAYLOAD]" "################ Start Debug ###################"
}
export -f START_DEBUG

# Stop_DEBUG
function STOP_DEBUG() {
	logger -t "[PAYLOAD]" "################ Stop Debug ###################"
	kill -HUP $PID_TAIL
	if [ "$(mount | grep /dev/nandf | awk '{printf $3}')" == "/root/udisk" ];then	
		cp $LOGFILE /root/udisk/loot/log.txt
		logger -t "[PAYLOAD]" "copied $LOGFILE file to /root/udisk/loot/log.txt"
		sync; sleep 1; sync
	else
		mount -o sync /dev/nandf /root/udisk		
		sleep 1
		cp $LOGFILE /root/udisk/loot/log.txt
		logger -t "[PAYLOAD]" "mount /dev/nandf to /root/udisk and copied $LOGFILE file to /root/udisk/loot/log.txt"
		sync; sleep 1; sync
		umount /dev/nandf
	fi
	
}
export -f STOP_DEBUG

# LOG
function LOG() {
	logger -t "[PAYLOAD]" "$1"
}
export -f LOG 


