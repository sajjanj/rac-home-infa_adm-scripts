#!/bin/bash

# NAME   :disk_space_monitor.sh
# USAGE  :./disk_space_monitor.sh
# YODA?  :Y
# CRON?  :Y
# PMREP  :N
# DESC   :Script to monitor disk usage & send alerts 
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Disk Space Usage Monitor"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG

func_email()
{
  echo "To: ${email_dl}"          > ${status_file}
  echo "Subject: ${email_subject}" >> ${status_file}
  echo "X-Priority: 1 (Highest)"   >> ${status_file}
  echo "X-MSMail-Priority: High"   >> ${status_file}
  echo "${email_body}"          >> ${status_file}
  sendmail -F "$INFA_ENV" -t < ${status_file}
}
func_chkdskusg()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Checking disk usage for mount ["${mount_nm_pattern}"]"
	mount_nm=`df -h|grep $mount_nm_pattern|grep %|sed 's/ \{2,\}/ /g'|cut -d " " -f6` 
	echo "[`date +%Y-%m-%d_%T`] INF: Checking if ["${mount_nm_pattern}"] exists"
	mount_nm_cnt=`echo $mount_nm|grep -i $mount_nm_pattern|wc -l`; mount_nm_cnt=$((mount_nm_cnt))
	if [ $mount_nm_cnt -eq 1 ]; then
		echo "[`date +%Y-%m-%d_%T`] INF: Calculating TOTAL SPACE"
		total_space=`df -h|grep $mount_nm|grep %|sed 's/ \{2,\}/ /g'|cut -d " " -f2`
		echo "[`date +%Y-%m-%d_%T`] INF: Calculating USED SPACE"
		used_space=`df -h|grep $mount_nm|grep %|sed 's/ \{2,\}/ /g'|cut -d " " -f3`
		echo "[`date +%Y-%m-%d_%T`] INF: Calculating FREE SPACE"
		free_space=`df -h|grep $mount_nm|grep %|sed 's/ \{2,\}/ /g'|cut -d " " -f4`
		echo "[`date +%Y-%m-%d_%T`] INF: Calculating PERCENTAGE OF USED SPACE"
		used_space_pct=`df -h|grep $mount_nm|grep %|sed 's/ \{2,\}/ /g'|cut -d " " -f5`
		used_space_pct_val=`echo $used_space_pct|sed "s/%//g"`
		used_space_pct_val=$((used_space_pct_val))
	elif [ $mount_nm_cnt -eq 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Mount [${mount_nm_pattern}] not found"; return 10
	else 
		echo "[`date +%Y-%m-%d_%T`] ERR: Unknown"; return 20
	fi
	echo "[`date +%Y-%m-%d_%T`] INF: "$mount_nm_pattern" TOT="$total_space" USED="$used_space" FREE="$free_space" USEDpct="$used_space_pct_val"%"
	email_body="Total=["$total_space"]  Used=["$used_space"]  Available=["$free_space"]"
	if [ $used_space_pct_val -gt $red ]; then
		email_subject="RED ALERT @ ["$INFA_HOST"] - Mount ["$mount_nm"] at "$used_space_pct" usage"
	elif [ $used_space_pct_val -gt $amber ]; then
		email_subject="AMBER ALERT @ ["$INFA_HOST"] - Mount ["$mount_nm"] at "$used_space_pct" usage"
	elif [ $used_space_pct_val -gt $warning ]; then
		email_subject="WARNING @ ["$INFA_HOST"] - Mount ["$mount_nm"] at "$used_space_pct" usage"
	fi
	if [ $used_space_pct_val -gt $red ] || [ $used_space_pct_val -gt $amber ] || [ $used_space_pct_val -gt $warning ]; then
		func_email
		if [ $? -ne 0 ]; then
			echo "[`date +%Y-%m-%d_%T`] ERR: Could not send email for mount [${mount_nm_pattern}]"; return 30
		else
			echo "[`date +%Y-%m-%d_%T`] INF: "$email_subject; return 0
		fi
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Usage of ["$mount_nm"] is in SAFE limits"; return 0
	fi
}

dttm=`date +%Y%m%d_%H%M%S` 
script_nm="disk_space_monitor"
email_dl=$INFA_NOTIFY
errors=0
log_dir="/home/infa_adm/scripts/log"
log_file=$log_dir"/"$script_nm"_"$dttm".log"
status_file=$log_dir"/"$script_nm".tmp"
warning=75; amber=85; red=95 # notification preferences

{
	echo "Script runtime = [`date +%Y-%m-%d_%T`]"
	echo "Run by user    = [`whoami`]"
	echo "Run at host    = ["$INFA_HOST"]"
	echo "Thresholds     = "$warning"(warning) "$amber"(amber) "$red"(red)"
	
	mount_nm_pattern="dsftp"; func_chkdskusg
	if [ $? -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Failure @ func_chkdskusg()"; errors=1
	fi
	mount_nm_pattern="infa_shared"; func_chkdskusg
	if [ $? -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Failure @ func_chkdskusg()"; errors=1
	fi
	mount_nm_pattern="oracle"; func_chkdskusg
	if [ $? -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Failure @ func_chkdskusg()"; errors=1
	fi
	mount_nm_pattern="u01"; func_chkdskusg
	if [ $? -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] ERR: Failure @ func_chkdskusg()"; errors=1
	fi
	echo
	if [ $errors -ne 0 ]; then
		echo "[`date +%Y-%m-%d_%T`] INF: Process completed with errors"
	else
		echo "[`date +%Y-%m-%d_%T`] INF: Process completed successfully"
	fi
	echo
} > $log_file 2>&1 

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG