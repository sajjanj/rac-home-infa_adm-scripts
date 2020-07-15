#!/bin/bash
# Script Name : infa_monitor.sh
# Description : Pings various services within INFA
#
# REVISION HISTORY
# Date         Name                 Comments
# 2014-12-10   Sajjan Janardhanan   created new

. /home/infa_adm/.bash_profile

func_email()
{
  echo "To: ${email_dl}"          > ${status_file}
  echo "Subject: ${email_subject}" >> ${status_file}
  echo "X-Priority: 1 (Highest)"   >> ${status_file}
  echo "X-MSMail-Priority: High"   >> ${status_file}
  echo "${email_body}"          >> ${status_file}
  sendmail -F "$INFA_ENV" -t < ${status_file}
}

dttm=`date +%Y%m%d_%T`
# email_dl=$INFA_NOTIFY",4692368821@txt.att.net"
email_dl="4692368821@txt.att.net"
log_dir="/home/infa_adm/scripts/log"
log_file=$log_dir"/infa_monitor_"$dttm".log"
status_file=$log_dir"/infa_monitor.tmp"
chk_domain=1
chk_intsvc=1
chk_pwxlogsvc=0
chk_pwxlstsvc=0

{
	echo "Script runtime = [`date +%Y-%m-%d_%T`]"
	echo "Run by user    = [`whoami`]"
	echo "Run at host    = ["$INFA_HOST"]"
	
	checkpoint="Domain [ $INFA_DOMAIN ]"
	if [ $chk_domain -eq 1 ]; then
		echo "."; echo "."; echo "."
		echo "[`date +%Y-%m-%d_%T`] INF: Pinging the $checkpoint"
		$INFA_HOME/server/bin/infacmd.sh ping -dn $INFA_DOMAIN
		ping_return_code=$?
		if [ $ping_return_code -ne 0 ]; then
			echo "[`date +%Y-%m-%d_%T`] ERR: No response from $checkpoint"
			email_subject="ALERT: $checkpoint is down at [ $INFA_HOST ]"
			email_body="[`date +%Y-%m-%d_%T`] error at [ ${INFA_HOST} ]"
			func_email ; exit 1
		else
			echo "[`date +%Y-%m-%d_%T`] INF: $checkpoint - OK"
		fi
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Skipping $checkpoint"
	fi
	
	checkpoint="Integration Service [ ${INFA_INTSVC} ]"
	if [ $chk_intsvc -eq 1 ]; then
		echo "."; echo "."; echo "."
		echo "[`date +%Y-%m-%d_%T`] INF: Pinging the $checkpoint"
		$INFA_HOME/server/bin/pmcmd pingservice -d $INFA_DOMAIN -sv $INFA_INTSVC
		ping_return_code=$?
		if [ $ping_return_code -ne 0 ]; then
			echo "[`date +%Y-%m-%d_%T`] ERR: No response from $checkpoint"
			email_subject="ALERT: $checkpoint is down at [ $INFA_HOST ]"
			email_body="[`date +%Y-%m-%d_%T`] error at [ ${INFA_HOST} ]"
			func_email ; exit 1
		else
			echo "[`date +%Y-%m-%d_%T`] INF: $checkpoint - OK"
		fi
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Skipping $checkpoint"
	fi

	checkpoint="PWX Logger Service [ ${INFA_PWXLOGSVC} ]"
	if [ $chk_pwxlogsvc -eq 1 ]; then
		echo "."; echo "."; echo "."
		echo "[`date +%Y-%m-%d_%T`] INF: Pinging the $checkpoint"
		cnt_pwxlogsvc=`ps -ef|grep ${INFA_PWXLOGSVC}|grep -v ${$}|wc -l`; cnt_pwxlogsvc=$((cnt_pwxlogsvc))
		if [ $cnt_pwxlogsvc -lt 2 ]; then
			ping_return_code=1
		else
			ping_return_code=0
		fi
		if [ $ping_return_code -ne 0 ]; then
			echo "[`date +%Y-%m-%d_%T`] ERR: No response from $checkpoint"
			email_subject="ALERT: $checkpoint is down at [ $INFA_HOST ]"
			email_body="[`date +%Y-%m-%d_%T`] error at [ ${INFA_HOST} ]"
			func_email ; exit 1
		else
			echo "[`date +%Y-%m-%d_%T`] INF: $checkpoint - OK"
		fi
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Skipping $checkpoint"
	fi

	checkpoint="PWX Listener Service [ ${INFA_PWXLSTSVC} ]"
	if [ $chk_pwxlstsvc -eq 1 ]; then
		echo "."; echo "."; echo "."
		echo "[`date +%Y-%m-%d_%T`] INF: Pinging the $checkpoint"
		cnt_pwxlstsvc=`ps -ef|grep ${INFA_PWXLSTSVC}|grep -v ${$}|wc -l`; cnt_pwxlstsvc=$((cnt_pwxlstsvc))
		if [ $cnt_pwxlstsvc -lt 2 ]; then
			ping_return_code=1
		else
			ping_return_code=0
		fi
		if [ $ping_return_code -ne 0 ]; then
			echo "[`date +%Y-%m-%d_%T`] ERR: No response from $checkpoint"
			email_subject="ALERT: $checkpoint is down at [ $INFA_HOST ]"
			email_body="[`date +%Y-%m-%d_%T`] error at [ ${INFA_HOST} ]"
			func_email ; exit 1
		else
			echo "[`date +%Y-%m-%d_%T`] INF: $checkpoint - OK"
		fi
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Skipping $checkpoint"
	fi	

	echo "."; echo "."; echo "."
	echo "[`date +%Y-%m-%d_%T`] INF: Purging the log files listed below"
	cd $log_dir
	echo `find infa_monitor*.log -mtime +1`
	rm -f `find infa_monitor*.log -mtime +1`
	if [ $? -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Purge ended in failure"; exit 1
	fi
	
	echo "."; echo "."; echo "."
	echo "[`date +%Y-%m-%d_%T`] INF: Process completed successfully"
	exit 0

} > $log_file 2>&1 