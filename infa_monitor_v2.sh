#!/bin/bash

# NAME   :infa_monitor_v2.sh
# USAGE  :./infa_monitor_v2.sh 
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :INFA domain and services monitoring
# AUTHOR :Sajjan Janardhanan 06/24/2015

. ~/.bash_profile
func_header "INFA Domain and Services Monitoring Utility"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG

dttm=`date +%Y%m%d_%T`
email_subject="!ALERT! Service(s) unresponsive in [$INFA_HOST]"
email_dl=$INFA_NOTIFY","$INFA_PAGER
log_dir="/home/infa_adm/scripts/log"
log_file=$log_dir"/infa_monitor_v2_"$dttm".log"
email_body_file=$log_dir"/infa_monitor_v2_email_body.tmp"
status_file=$log_dir"/infa_monitor_v2.tmp"

func_email()
{
  echo "To: ${email_dl}"          > ${status_file}
  echo "Subject: ${email_subject}" >> ${status_file}
  echo "X-Priority: 1 (Highest)"   >> ${status_file}
  echo "X-MSMail-Priority: High"   >> ${status_file}
  echo -e "\n\nMonitor timestamp = $dttm \n\n" >> ${status_file}
  cat $email_body_file >> ${status_file}
  echo -e "\nPlease contact the Informatica Administration team" >> ${status_file}
  sendmail -F "$INFA_ENV" -t < ${status_file}
}

func_ping_node()
{
	checkpoint=$1
	echo -e "\n> INF: Pinging node ["$checkpoint"] at "`date +%Y-%m-%d_%T`
	$INFA_HOME/server/bin/infacmd.sh ping -dn $INFASVC_DOM -nn $checkpoint -re 5
	ping_return_code=$?
	if [ $ping_return_code -ne 0 ]; then
		echo "> ERR: No response"
		email_body="-- Node ["$checkpoint"] is not responding"
		echo -e $email_body"\n" >> $email_body_file
	else
		echo "> INF: OK"
	fi
}

func_ping_svc()
{
	checkpoint=$1
	echo -e "\n> INF: Pinging service ["$checkpoint"] at "`date +%Y-%m-%d_%T`
	$INFA_HOME/server/bin/infacmd.sh isp ping -dn $INFASVC_DOM -sn $checkpoint 
	ping_return_code=$?
	if [ $ping_return_code -ne 0 ]; then
		echo "> ERR: No response"

		email_body="-- Service ["$checkpoint"] in ["$INFA_HOST"]"
		echo -e $email_body"\n" >> $email_body_file
	else
		echo "> INF: OK"
	fi
}

{
	echo "Script runtime = ["$dttm"]"
	echo "Run by user    = [`whoami`]"
	echo "Run at host    = ["$INFA_HOST"]"
	
	if [ -f $email_body_file ]; then
		rm $email_body_file
		if [ $? -eq 0 ]; then
			echo -e "\n> INF: successfully deleted file [ $email_body_file ]"
		else
			echo -e "\n> INF: could not delete file [ $email_body_file ]" 
		fi
	fi
	
	echo -e "\n> INF: Pinging domain [ "$INFASVC_DOM" ] at "`date +%Y-%m-%d_%T`
	$INFA_HOME/server/bin/infacmd.sh isp ping -dn $INFASVC_DOM
	ping_return_code=$?
	if [ $ping_return_code -ne 0 ]; then
		echo "> ERR: No response"
		email_subject="!ALERT! Domain [$INFASVC_DOM] not responding in [$INFA_HOST]"
		#email_body="Please contact the Informatica Administration team"
		#echo -e $email_body"\n" >> $email_body_file
		func_email
	else
		echo "> INF: OK"
		func_ping_node $INFA_NODE1
		func_ping_node $INFA_NODE2
		func_ping_svc $INFASVC_REP
		func_ping_svc $INFASVC_INT
		func_ping_svc $INFASVC_WEB
		func_ping_svc $INFASVC_MRS
		func_ping_svc $INFASVC_ANS
		func_ping_svc $INFASVC_DIS
		func_ping_svc $INFASVC_CMS
		# func_ping_svc $INFASVC_DDS # no longer in use in v10.1.0
		# func_ping_svc $INFASVC_RDS # no longer in use in v10.1.0
		func_ping_svc $INFASVC_MMS # no longer in use in v10.1.0
		# func_ping_svc $INFASVC_PLG # no longer in use in v10.1.0
		# func_ping_svc $INFASVC_PLI # no longer in use in v10.1.0
		# func_ping_svc $INFASVCNM_PLG  # no longer in use in v10.1.0
		# func_ping_svc $INFASVCNM_PLI  # no longer in use in v10.1.0
		if [ -s $email_body_file ]; then
			echo -e "\n> INF: Sending an alert notification"
			func_email
		else
			echo -e "\n INF: Alert notification not required"
		fi
	fi

	echo -e "\n> INF: Purging the log files at "`date +%Y-%m-%d_%T`
	cd $log_dir
	file_cnt=`find ./infa_monitor*.log -mtime +1|wc -l`
	if [ $file_cnt -gt 0 ]; then
		rm -f `find ./infa_monitor*.log -mtime +1`
		if [ $? -eq 0 ]; then
			echo "> INF: Log files purged successfully"
		else
			echo "> ERR: Log files could not be purged"
		fi
	else
		echo "> INF: No log files to purge"
	fi 
	
	echo -e "\n> INF: Process completed successfully"

} > $log_file 2>&1 

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG
