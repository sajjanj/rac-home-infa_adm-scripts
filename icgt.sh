#!/bin/bash

# NAME   :icgt.sh
# USAGE  :./icgt.sh <Search_Pattern>
# YODA?  :N
# CRON?  :N
# PMREP  :Y
# DESC   :This script provides relational connection & TNS details for connection names that match a string pattern
# AUTHOR :Sajjan Janardhanan 04/25/2018

. ~/.bash_profile
func_header "INFA Connection GREP Utility"

echo -e $COLOR_CYAN
if [ $# -ne 1 ]; then
	echo -e "ERR: Insufficient or Too many arguments"
else
	searpatt=$1
	cd $INFA_HOME/server/bin
	for connec in `./pmrep listconnections -t|grep relational|grep -i $searpatt`; do 
		./pmrep GetConnectionDetails -t Relational -n `echo $connec|cut -d"," -f1`|\
			grep -E 'Name|User|Connect String|Code page'>./icgt.tmp
		cat ./icgt.tmp; echo 
		tnsalias=`cat ./icgt.tmp|grep "Connect String"|cut -d"=" -f2`
		cat $TNS_ADMIN/tnsnames.ora|grep -i $tnsalias|grep -v '^-'
		echo -e "--------------------------------------------------------------------"
	done
fi
echo -e $COLOR_NONE