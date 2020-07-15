#!/bin/bash

# NAME   :nohup_purge.sh 
# USAGE  :./nohup_purge.sh /home/infa_adm/scripts/logs 90
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :NoHup Purge Utility with a retention period
# AUTHOR :Sajjan Janardhanan 03/16/2016

. ~/.bash_profile
func_header "NoHup Purge Utility"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2>>$MASTER_LOG

if [ $# -ne 2 ]; then
  echo "["`date +%Y%m%d_%H%M%S`"] ERR: Insufficient or Too many arguments"
  echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|ERR-1|"$0"|"$1"|"$2>>$MASTER_LOG
  exit 1
fi
dttm=`date +%Y%m%d_%H%M%S`
dir=$1
ret=$2
errors=0
logfile=~/scripts/log/nohup_purge_${dttm}.log
emailbody=`echo -e "Folder=${dir} \nRetentionPeriod=${ret} \nScript=$0 \nStartTime=$dttm \nPID="$$`

{
	echo "["`date +%Y%m%d_%H%M%S`"] INF: NoHup purge in ["$dir"] with retention of ["$ret"] days with PID["$$"]"
	echo "["`date +%Y%m%d_%H%M%S`"] INF: Recorded start time = "$dttm
	cd $dir
	if [ $? -ne 0 ]; then
		/home/infa_adm/scripts/infa_email.sh "INVALID FOLDER $dir" "${emailbody}"
		echo "["`date +%Y%m%d_%H%M%S`"] ERR: Change Directory failed (2)"
		echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|ERR-2|"$0"|"$1"|"$2>>$MASTER_LOG
		exit 2
	elif [ `find . -maxdepth 1 -type f |grep -E "sh$|parm$|par$"|wc -l` -gt 0 ]; then
		echo "["`date +%Y%m%d_%H%M%S`"] ERR: Current directory might contain files that should not be deleted"
		echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|ERR-3|"$0"|"$1"|"$2>>$MASTER_LOG
		exit 3
	else
		echo "["`date +%Y%m%d_%H%M%S`"] INF: Current Directory = "`pwd`
		for fn in `find . -maxdepth 1 -type f -mtime +${ret}`; do
			rm -f ./${fn}
			if [ $? -ne 0 ]; then
				echo "["`date +%Y%m%d_%H%M%S`"] ERR : Could not delete $fn"
				errors=1
			else
				echo "["`date +%Y%m%d_%H%M%S`"] INFO: Deleted $fn"
			fi
		done
		if [ $errors -eq 0 ]; then
			/home/infa_adm/scripts/infa_email.sh "OK - $dir [ $ret ]" "${emailbody}"
		else
			/home/infa_adm/scripts/infa_email.sh "ERR - $dir [ $ret ]" "${emailbody}"
		fi
		echo "Completed @ "`date +%Y%m%d_%H%M%S`
	fi
} > $logfile 2>&1

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2>>$MASTER_LOG
