#!/bin/bash

# NAME   :infa_backup.sh
# USAGE  :./infa_backup.sh 
# YODA?  :Y
# CRON?  :N
# PMREP  :N (required, but self contained)
# DESC   :This script provides relational connection & TNS details for connection names that match a string pattern
# AUTHOR :Sajjan Janardhanan 12/10/2014

. ~/.bash_profile
func_header "INFA Backup Utility for Domain and Services"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG

dttm=`date +%Y%m%d_%H%M%S`
dir_bkp="/infa_shared/Backup"
dir_log="/home/infa_adm/scripts/log"
cnt_err=0
file_log=$dir_log"/infa_backup_"$dttm".log"
file_tmp=$dir_log"/infa_backup.tmp"
indent="                "
indent=" -------------> "

file_bkp_ans="infa_backup-${INFASVC_ANS}-${dttm}-"
file_bkp_dis="infa_backup-${INFASVC_DIS}-${dttm}-"
file_bkp_dom="infa_backup-${INFASVC_DOM}-${dttm}.rep"
file_bkp_mms="infa_backup-${INFASVC_MMS}-${dttm}.rep"
file_bkp_mrs="infa_backup-${INFASVC_MRS}-${dttm}"
file_bkp_rep="infa_backup-${INFASVC_REP}-${dttm}.rep"

func_yoda_error()
{
	errcd=$?
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|ERROR-"$errcd"|"$0>>$MASTER_LOG
}
func_backup_ans() 
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of repository ["$INFASVC_ANS"]"
	echo -e "\n Under construction"
}
func_backup_dis()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of repository ["$INFASVC_DIS"]"
	for appln_nm in `$INFA_HOME/server/bin/infacmd.sh DIS ListApplications -dn $INFASVC_DOM -un $INFA_DEFAULT_DOMAIN_USER -sdn $INFA_DEFAULT_SECURITY_DOMAIN -sn $INFASVC_DIS` ; do
		$INFA_HOME/server/bin/infacmd.sh DIS BackupApplication -dn $INFASVC_DOM -sn $INFASVC_DIS -un $INFA_DEFAULT_DOMAIN_USER -sdn $INFA_DEFAULT_SECURITY_DOMAIN -a $appln_nm -f ${dir_bkp}/${dttm}/${file_bkp_dis}_$appln_nm
		# $INFA_HOME/server/bin/infacmd.sh DIS BackupApplication -dn $INFASVC_DOM -sn $INFASVC_DIS -un $INFA_DEFAULT_DOMAIN_USER -sdn $INFA_DEFAULT_SECURITY_DOMAIN -a $appln_nm -f ${dir_bkp}/${dttm}/${file_bkp_dis}_$appln_nm
		errcd=$?
		if [ $errcd -eq 0 ]; then
			echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup successfully taken in file ["${file_bkp_dis}_${appln_nm}"]"
			gzip -qv ${dir_bkp}/${dttm}/${file_bkp_dis}_${appln_nm}
			errcd=$?
			if [ $errcd -eq 0 ]; then
				echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup file compression successful"
			else
				echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
				let cnt_err=${cnt_err}+1
			fi
		else
			echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
			let cnt_err=${cnt_err}+1
		fi
	done
	return $cnt_err
}
func_backup_dom()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of domain ["$INFASVC_DOM"]"
	$INFA_HOME/isp/bin/infasetup.sh BackupDomain -da ${DB_HOST}:${DB_PORT} -du $INFA_DEFAULT_DATABASE_USER -dt $DB_TYPE -ds $DB_SVCNM -bf ${dir_bkp}/${file_bkp_dom} -dn $INFASVC_DOM
	errcd=$?
	if [ $errcd -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup successfully taken in file ["$file_bkp_dom"]"
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
		let cnt_err=${cnt_err}+1
	fi
	return $cnt_err
}
func_backup_mms()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of repository ["$INFASVC_MMS"]"
	echo -e "\n Under construction"
}
func_backup_mrs()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of repository ["$INFASVC_MRS"] in folder ["${dir_bkp}/${INFASVC_MRS}"]"
	$INFA_HOME/server/bin/infacmd.sh mrs backupcontents -dn $INFASVC_DOM -un $INFA_DEFAULT_DOMAIN_USER -sn $INFASVC_MRS -of $file_bkp_mrs -sdn Native
	errcd=$?
	if [ $errcd -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup successfully taken in file ["$file_bkp_mrs".mrep]"
		# gzip -qv ${dir_bkp}/${INFASVC_MRS}/${file_bkp_mrs}".mrep"
		# errcd=$?
		# if [ $errcd -eq 0 ]; then
			# echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup file compression successful"
		# else
			# echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
			# let cnt_err=${cnt_err}+1
		# fi
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
		let cnt_err=${cnt_err}+1
	fi
	return $cnt_err
}
func_backup_rep() 
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Starting backup of repository ["$INFASVC_REP"]"
	$INFA_HOME/server/bin/pmrep connect -r $INFASVC_REP -d $INFASVC_DOM -n $INFA_DEFAULT_DOMAIN_USER -X INFA_DEFAULT_DOMAIN_PASSWORD
	errcd=$?
	if [ $? -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Connection established with repository"
		$INFA_HOME/server/bin/pmrep backup -o ${dir_bkp}/${file_bkp_rep} #>> ${file_tmp} 2>&1
		errcd=$?
		if [ $errcd -eq 0 ]; then
			echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup successfully taken in file ["$file_bkp_rep"]"
			# gzip -qv ${dir_bkp}/${1}/${file_bkp_rep}
			# errcd=$?
			# if [ $errcd -eq 0 ]; then
				# echo -e "\n[`date +%Y-%m-%d_%T`] INF: Backup file compression successful"
			# else
				# echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
				# let cnt_err=${cnt_err}+1
			# fi
		else
			echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
			let cnt_err=${cnt_err}+1
		fi
		$INFA_HOME/server/bin/pmrep cleanup
		errcd=$?
		if [ $errcd -eq 0 ]; then
			echo -e "\n[`date +%Y-%m-%d_%T`] INF: Cleanup successfull"
		else
			echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
			let cnt_err=${cnt_err}+1
		fi
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Failure Code = "$errcd
		let cnt_err=${cnt_err}+1
	fi
	return $cnt_err
}
func_purge_bkp()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Purging the BACKUP files listed below"
	cd $dir_bkp
	find ./infa_backup* -mtime +7
	find ./infa_backup* -mtime +7 -delete
	if [ $? -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Purge successful"
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Purge failed"
	fi
}
func_purge_log()
{
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Purging the LOG files listed below"
	cd $dir_log
	find ./infa_backup* -mtime +7
	find ./infa_backup* -mtime +7 -delete
	if [ $? -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Purge successful"
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Purge failed"
	fi
}
# { # main
	echo "Script runtime = [`date +%Y-%m-%d_%T`]"
	echo "Run by user    = [`whoami`]"
	echo "Run at host    = ["$INFA_HOST"]"
	echo "Backup folder  = "${dir_bkp} #/${dttm}
	
	# --- preparing subfolder by date before backup is taken --- #
	cd $dir_bkp
	if [ $? -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: Current directory = "`pwd`
		# mkdir $dttm
		# if [ $? -eq 0 ]; then
			# echo -e "\n[`date +%Y-%m-%d_%T`] INF: Created folder "$dttm
			# cd $dttm
			# if [ $? -eq 0 ]; then
				# echo -e "\n[`date +%Y-%m-%d_%T`] INF: Current directory "`pwd`
			# else
				# echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Could not change to "$dttm
				# func_yoda_error 3 ; exit 3
			# fi
		# else
			# echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Cannot create folder "$dttm" in "$dir_bkp
			# func_yoda_error 2 ; exit 2
		# fi
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Could not change to "$dir_bkp
		func_yoda_error 1 ; exit 1
	fi
	# --- calling backup routines --- #
	retcd_ans=0; retcd_dis=0; retcd_dom=0; retcd_mms=0; retcd_mrs=0; retcd_rep=0
	# func_backup_ans       ; retcd_ans=$? *
	# func_backup_dis       ; retcd_dis=$? 
	func_backup_dom         ; retcd_dom=$? # tested successfully on 06/04/2018 by Sajjan 
	# func_backup_mms       ; retcd_mms=$? *
	func_backup_mrs         ; retcd_mrs=$? 
	func_backup_rep         ; retcd_rep=$? # tested successfully on 06/04/2018 by Sajjan
	# func_purge_bkp        ; retcd_bkp=$? 
	# func_purge_log        ; retcd_log=$? 
	let bkp_retcd=$retcd_ans+$retcd_dis+$retcd_dom+$retcd_mms+$retcd_mrs+$retcd_rep
	email_body_retcd="ANS="$retcd_ans"|DIS="$retcd_dis"|DOM="$retcd_dom"|MMS="$retcd_mms"|MRS="$retcd_mrs"|REP="$retcd_rep
	echo -e "\n[`date +%Y-%m-%d_%T`] INF: Number of errors occurred = ["$bkp_retcd"]"
	if [ $bkp_retcd -eq 0 ]; then
		echo -e "\n[`date +%Y-%m-%d_%T`] INF: All backup routines completed successfully\n"
	else
		echo -e "\n[`date +%Y-%m-%d_%T`] ERR: Some backup routines completed in failure"
		echo $indent $INFASVC_ANS $retcd_ans
		echo $indent $INFASVC_DIS $retcd_dis
		echo $indent $INFASVC_DOM $retcd_dom
		echo $indent $INFASVC_MMS $retcd_mms
		echo $indent $INFASVC_MRS $retcd_mrs
		echo $indent $INFASVC_REP $retcd_rep
		# ${HOME}/scripts/infa_email.sh "Errors in INFA Backup" $email_body_retcd
		echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|ERROR-4|"$0>>$MASTER_LOG
		exit 4
		
	fi
# } > $file_log 2>&1
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG