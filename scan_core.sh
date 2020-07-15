#!/bin/bash

# NAME   :scan_core.sh 
# USAGE  :./scan_core.sh
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :Scans for CORE files created by INFA and alert INFA-Admins
# AUTHOR :Sajjan Janardhanan 

. ~/.bash_profile
logfile=~/scripts/log/scan_core.log
{
	func_header "INFA Core files Scan utility"
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG
	echo -e $COLOR_CYAN
	echo "Script runtime = [`date +%Y-%m-%d_%T`]"
	echo "Run by user    = [`whoami`]"
	echo "Run at host    = ["$INFA_HOST"]"
	echo -e $COLOR_NONE
	cd ${INFA_HOME}/server/bin
	core_count=`ls $INFA_HOME/server/bin | grep "^core" | wc -l`
	echo -e $COLOR_CYAN"INF: Core files count = "$core_count
	if [ $core_count -gt 0 ]; then
		email_subject="ALERT - "$core_count" Core files found in "$INFA_HOST
		core_files=`pwd ; echo ; ls -1 core*`
		echo -e $COLOR_CYAN ; 	ls -l core* ; echo -e $COLOR_NONE
		~/scripts/infa_email.sh "$email_subject" "$core_files"
	else
		email_subject="INFO - "$core_count" Core files found in "$INFA_HOST
		core_files="CORE files not found"
		echo -e $COLOR_CYAN"INF: "$core_files 
		echo -e $COLOR_NONE
	fi
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|"$core_count" core files found|END|"$0>>$MASTER_LOG
} > $logfile 2>&1

# ssh_broadcast 'source ~/.bash_profile ; echo -e "# of core files = \c"; ls $INFA_HOME/server/bin|grep "^core"|wc -l ' 0
