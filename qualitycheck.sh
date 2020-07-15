#!/bin/bash

# NAME   :qualitycheck.sh 
# USAGE  :./qualitycheck.sh <folder_name> <object_type> <object_name>
# YODA?  :N
# CRON?  :N
# PMREP  :Y 
# DESC   :INFA code review utility for WF, WL and ST objects
# AUTHOR :Sajjan Janardhanan 01/06/2017

# Update Date	Updated By			Update Description
# --------------------------------------------------------
# 01/06/2017	Sajjan Janardhanan	Created new
# 09/22/2017	Bill Ritchie		Added check for tracing level (option 10)
# 09/22/2017	Bill Ritchie		Delete lock file if invalid option
# 10/02/2017	Sajjan Janardhanan	Removed lock file and prompts for XML export
# 11/20/2017	Sajjan Janardhanan	Added option 10 for last run & saved time SQL
# 12/21/2017	Bill Ritchie		Added Option 11 to check for hard-coded values
# 01/31/2018	Sajjan Janardhanan	Altered option 10 to list last run time for WF & ST
# 05/18/2018	Sajjan Janardhanan	Display previous QC items

. ~/.bash_profile
func_header "INFA Powercenter Code Review Utility for WF, WT and ST objects"

func_print()
{ 
	in_lnnum=$1
	in_ln=$2
	str_length=`echo ${in_ln}|wc -c`
	if [ $str_length -gt 1 ]; then
		echo ${in_lnnum}${in_ln}
	fi
}

if [ $# -lt 3 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient parameters\n"$COLOR_NONE
	exit 10
else
	folder=$1 ; objtype=$2 ; objnm=$3 ; clear
	current_user=`whoami`
	machine_name=`who -m|grep $current_user|cut -d "(" -f2|cut -d ")" -f1`
	logfile="/infa_shared/Temp/qc_"$machine_name".log"
	objfile="/infa_shared/Temp/qc_"$machine_name".obj"
	objfilestr=${folder}":"${objnm}":"${objtype}
	xmlfile="/infa_shared/Temp/qc_"$machine_name".xml"
	echo -e "\n\nINFO: Please review previous deployments listed below before performing QC \n"
	cat /infa_shared/Temp/qc*.obj
	echo -e "\n\n > Press any key to proceed or Ctrl-C to quit ..... \n"; read -n 1 -s
	rm -f $logfile $objfile $xmlfile 
	echo -e $objfilestr "\n"`who -m` > $objfile
	$INFA_HOME/server/bin/pmrep objectexport -f $folder -o $objtype -n $objnm -u $xmlfile -l $logfile -m -s -b -r 
	yn_continue="y"
	
	if [ $? -ne 0 ]; then
		echo -e "\nERR: Object XML export ended in failure"; exit 1
	else
		while [[ $yn_continue == "y" ]] || [[ $yn_continue == "Y" ]] ; do
			clear
			echo -e "\n------------------------------------------------"
			echo -e "DATA SERVICES Informatica Powercenter QC utility \n"
			echo -e "  Folder = "$folder
			echo -e "  Object = "$objnm
			echo -e "  Type   = "$objtype
			echo -e "------------------------------------------------\n"
			echo "  1. Full folder scan"
			echo "  2. Full DTM Buffer Size and Scheduler"
			echo "  3. Quick folder scan (faster equivalent of 1)"
			echo "  4. Quick DTM Buffer Size and Scheduler (faster equivalent of 2)"
			echo "  5. Connections"
			echo "  6. Tracing Level"
			echo "  7. Descriptions and Comments"
			echo "  8. List Mapping & Session Task dependencies"
			echo "  9. List Sources & Target dependencies"
			echo " 10. Last workflow and session run check"
			echo " 11. Check for hard-coded values"
			echo " 12. New option"
			echo "  0. Quit"
			echo -e "\nQST: Pick one option from above ? \c"; read ioption
			
			if [ $ioption -eq 0 ] ; then
				exit 0
			elif [ $ioption -lt 1 ] || [ $ioption -gt 12 ] ; then
				echo -e "\nERR: Invalid option\n"; exit 2
			else
				echo -e "\nINF: QC option ["$ioption"] - "$objfilestr
				echo -e "INF: Start Time = "`date`" \n"
				if [ $ioption -eq 1 ] || [ $ioption -eq 2 ] || [ $ioption -eq 7 ]; then
					lnnum=0
					while read ln; do
						let lnnum=lnnum+1
						if [ $ioption -eq 1 ]; then
							echo $lnnum " ~ WORKFLOW NAME = \"" $ln|grep "WORKFLOW DESCRIPTION"|awk -F "\"" '{print $1$13" ; VERSION = "$27}'
							echo $lnnum " ~ TASK NAME = \"" $ln|grep "TASK DESCRIPTION"|awk -F "\"" '{print $1$5" ; REUSABLE = "$7}'
							echo $lnnum " ~ SESSION NAME = \"" $ln|grep "SESSION DESCRIPTION"|awk -F "\"" '{print $1$9" ; REUSABLE = "$11}'
							echo $lnnum " ~ MAPPING NAME = \"" $ln|grep "MAPPING DESCRIPTION" #|awk -F "\"" '{print $1$7" ; "$8$9" ; "$10$11}'
							echo $lnnum " ~  TRANSFORMATION NAME = \"" $ln|grep "TRANSFORMATION DESCRIPTION"|awk -F "\"" '{print $1$5" - "$11}'
							echo $lnnum " ~   " $ln|grep -i "PMBadFileDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMCacheDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMTempDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMSessionLogDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMWorkflowLogDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMSourceFileDir"|sed -e 's/\&\#x5c\;/\//g'
							echo $lnnum " ~   " $ln|grep -i "PMTargetFileDir"|sed -e 's/\&\#x5c\;/\//g'
						elif [ $ioption -eq 7 ]; then
							echo -e "\n"$lnnum " ~   " $ln|grep "DESCRIPTION"|awk -F "\"" '{print $1$2" ; "$11$12}'
						elif [ $ioption -eq 2 ]; then
							opt5str=`echo $ln|grep "WORKFLOW DESCRIPTION"|awk -F "\"" '{print " ~ WORKFLOW NAME = "$12}'` ; func_print $lnnum "${opt5str}"
							opt5str=`echo $ln|grep "SESSION DESCRIPTION"|awk -F "\"" '{print " ~ SESSION NAME = "$8}'` ; func_print $lnnum "${opt5str}"
							opt5str=`echo $ln|grep "DTM buffer size"|awk -F "\"" '{print " ~ DTM Buffer Size = "$4}'` ; func_print $lnnum "${opt5str}"
							echo -e "\n"$lnnum " ~   " $ln|grep "SCHEDULER DESCRIPTION|SCHEDULEINFO"
						fi
					done <$xmlfile
				elif [ $ioption -eq 3 ]; then
					cat $xmlfile|grep -i "directory"|sed -e 's/\&\#x5c\;/\//g'|grep -v $folder
				elif [ $ioption -eq 4 ]; then
					cat $xmlfile|grep -i "dtm buffer size"|sed -e 's/\&\#x5c\;/\//g'|grep -v $folder
					# cat $xmlfile|grep -E "SCHEDULER DESCRIPTION|SCHEDULEINFO"|sed -e 's/\&\#x5c\;/\//g'|grep -v $folder
				elif [ $ioption -eq 5 ]; then
					cat $xmlfile|grep -i "connection value"|awk -F "\"" '{print $2 " = " $4}'|sort|uniq
					cat $xmlfile|grep -i "connection information"|awk -F "\"" '{print $2 " = " $4}'|sort|uniq
					cat $xmlfile|grep -i "connectionreference"|awk -F "\"" '{print $3" " $4" "$12" "$8}'|sort|uniq
				elif [ $ioption -eq 6 ]; then
					cat $xmlfile|grep -i "tracing level"|awk -F "\"" '{print $2 " = " $4}'|sort|uniq
				elif [ $ioption -eq 8 ]; then
					$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d mapping -n $objnm -o $objtype -f $folder|grep 'RAC'|sort|grep -v shortcut; echo ' '
					$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d session -n $objnm -o $objtype -f $folder|grep 'RAC'|sort|grep -v shortcut; echo ' '
					$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d task -n $objnm -o $objtype -f $folder|grep 'RAC'|sort|grep -vE "shortcut|non-reusable"
				elif [ $ioption -eq 9 ]; then
					$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d source -n $objnm -o $objtype -f $folder|grep 'RAC'|sort |grep -v shortcut; echo ' '
					$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d target -n $objnm -o $objtype -f $folder|grep 'RAC'|sort |grep -v shortcut
				elif [ $ioption -eq 10 ]; then
					$INFA_HOME/server/bin/pmcmd getworkflowdetails -sv $INFASVC_INT -d $INFASVC_DOM -u $INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD -f $folder $objnm | grep -iE "time|workflow:|user|status"| grep -v "Integration" ; echo ' '
					for sessiontask in `$INFA_HOME/server/bin/pmrep listobjectdependencies -c "|" -b -p children -y -d session -n $objnm -o workflow -f $folder|grep 'RAC'|sort|grep -v shortcut|cut -d"." -f2|cut -d"|" -f1` ; do
						$INFA_HOME/server/bin/pmcmd gettaskdetails -sv $INFASVC_INT -d $INFASVC_DOM -uv INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD -f $folder -w $objnm $sessiontask|grep -iE "time|user|session|status"| grep -v "Integration" ; echo ' '
					done
					
					# echo "alter session set nls_date_format = 'yyyy-mm-dd HH24:MI:SS';"
					# echo "select subject_area || '.' || workflow_name || ' - LastSaved @ ' || max(lsdt) as text"
					# echo "  from sj_wf_versions where 1=1"
					# echo "  and subject_area = '"$folder"'"
					# echo "  and workflow_name = '"$objnm"'"
					# echo "  group by subject_area, workflow_name union "
					# echo "select subject_area || '.' || task_name || ' - LastSaved @ ' || max(lsdt) as text"
					# echo "  from sj_st_versions where 1=1"
					# echo "  and subject_area = '"$folder"'"
					# echo "  and task_name = '"$objnm"'"
					# echo "  group by subject_area, task_name union "
					# echo "select subject_area || '.' || workflow_name || ' - LastRun @ ' || max(start_time) as text"
					# echo "  from SJ_REP_SESS_LOG where 1=1"
					# echo "  and sj_rep_sess_log.run_status_code = 1"
					# echo "  and subject_area = '"$folder"'"
					# echo "  and workflow_name = '"$objnm"'"
					# echo "  group by subject_area, workflow_name union "
					# echo "select subject_area || '.' || session_name || ' - LastRun @ ' || max(start_time) as text"
					# echo "  from SJ_REP_SESS_LOG where 1=1"
					# echo "  and sj_rep_sess_log.run_status_code = 1"
					# echo "  and subject_area = '"$folder"'"
					# echo "  and session_name = '"$objnm"'"
					# echo "  group by subject_area, session_name ;"
				elif [ $ioption -eq 11 ]; then	
                    echo -e "\n*** CHECKING FOR HARDCODED VALUES - PARAMETER FILE PATHS *** \n"
				    cat $xmlfile|grep -i "parameter filename"|sed -e "s/^ *//g"|sed -e 's/\&\#x5c\;/\//g'
					echo -e "\nPRESS ANY KEY TO CONTINUE ... \c"; read anykey
					
					echo -e "\n*** CHECKING FOR HARDCODED VALUES - COMMANDS *** \n"
					cat $xmlfile|grep -i "valuepair execorder"|sed -e "s/^ *//g"|awk -F "\"" '{print $3" " $4"  ** Command = "$8}'
					echo -e "\nPRESS ANY KEY TO CONTINUE ... \c"; read anykey
					
					echo -e "\n*** CHECKING FOR HARDCODED VALUES - MAPPING VARIBLES *** \n"
					cat $xmlfile|grep -i "mappingvariable"|sed -e "s/^ *//g"|awk -F "\"" '{print $13 " " $14 " " $5 " " $6}'
					echo -e "\nPRESS ANY KEY TO CONTINUE ... \c"; read anykey
					
					echo -e "\n*** CHECKING FOR HARDCODED VALUES - WORKFLOW VARIBLES *** \n"
					cat $xmlfile|grep -i "workflowvariable"|sed -e "s/^ *//g"|awk -F "\"" '{print $11 " " $12 " " $3 " " $4}'
					echo -e "\nPRESS ANY KEY TO CONTINUE ... \c"; read anykey
					
					echo -e "\n*** CHECKING FOR HARDCODED VALUES - SCRIPT PATHS *** \n"
					cat $xmlfile|grep -i "scripts"|sed -e "s/^ *//g"
				elif [ $ioption -eq 12 ]; then
					echo "INF: work in progress"
					# ./pmrep listobjectdependencies -c "|" -b -p children -y -d session -n wf_VAN_CUSTOMER_APPROVAL_AUDIT -o Workflow -f VAN|grep session|cut -d"|" -f5
					# ./pmcmd getworkflowdetails -sv $INFASVC_INT -d $INFASVC_DOM -u $INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD -f $folder $objnm
					# ./pmcmd gettaskdetails -sv $INFASVC_INT -d $INFASVC_DOM -uv INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD -f VAN -w wf_VAN_CUSTOMER_APPROVAL_AUDIT s_m_VAN_CUSTOMER_APPROVAL_AUDIT
					# ./pmcmd getservicedetails -sv $INFASVC_INT -d $INFASVC_DOM -uv INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD|grep -E "Folder|Workflow:|user"|sort|uniq
					# ./pmcmd getrunningsessionsdetails -sv $INFASVC_INT -d $INFASVC_DOM -uv INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD|grep -E "Folder|Workflow:|user|Session Instance:"|sort|uniq
				fi
			fi
			echo -e "\nINF: End Time = "`date`
			echo -e "\nQST: Try again (y/n) ? \c"; read yn_continue
		done
	fi 
fi
exit 0

# echo $lnnum " ~   " $ln|grep "Save workflow log for these runs"
# echo $lnnum " ~   " $ln|grep "Save session log for these runs"
# echo $lnnum " ~   " $ln|grep "Parameter Filename"|sed -e 's/\&\#x5c\;/\//g'
# echo $lnnum " ~   " $ln|grep "Stop on errors"

# echo $lnnum " ~ " $ln|grep "FOLDER NAME"
# echo $lnnum " ~   " $ln|grep "Workflow Log File Directory"|sed -e 's/\&\#x5c\;/\//g'
# echo $lnnum " ~   " $ln|grep "Session Log File directory"|sed -e 's/\&\#x5c\;/\//g'
# echo $lnnum " ~   " $ln|grep "PM"|sed -e 's/\&\#x5c\;/\//g'    \

# function func_leftpad()
# {
    # itext=$1; lpad=$2
    # itextlen=${#itextlen}
    # if [ $itextlen -gt $lpad ]; then
        # echo "WNG: Length of string exceeded padding length"
        # return $itext
    # else
        # let padnum=$lpad-$itextlen
        # retval=`printf %*d $padnum`
        # return retval
        # echo $retval
    # fi
# } 
