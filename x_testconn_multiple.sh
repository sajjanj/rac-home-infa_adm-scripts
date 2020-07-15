#!/bin/bash
# Created by SAJJAN JANARDHANAN on 03/16/2016
. ~/.bash_profile

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG
test_connection()
{
	echo -e "\n\nInformatica PowerCenter Relational Database Connection Test\n"
	echo -e "Connection Test for [ ${1} ]"
	$INFA_HOME/server/bin/pmcmd startworkflow -d $INFASVC_DOM -sv $INFASVC_INT -u $INFA_PMUSER -pv INFA_PMPASS -f Miscellaneous -wait wf_TestConnection
	rv_pmcmd=$?
	
	case $rv_pmcmd in
		1)
			rv_pmcmd_msg="Cannot connect to Power Center server" ;;
		2)
			rv_pmcmd_msg="Workflow or folder does not exist" ;;
		3)
			rv_pmcmd_msg="An error occurred in starting or running the workflow" ;;
		4)
			rv_pmcmd_msg="Usage error" ;;
		5)
			rv_pmcmd_msg="Internal pmcmd error" ;;
		7)
			rv_pmcmd_msg="Invalid Username Password" ;;
		8)
			rv_pmcmd_msg="You do not have permission to perform this task" ;;
		9)
			rv_pmcmd_msg="Connection timed out" ;;
		13)
			rv_pmcmd_msg="Username environment variable not defined" ;;
		14)
			rv_pmcmd_msg="Password environment variable not defined" ;;
		15)
			rv_pmcmd_msg="Username environment variable missing" ;;
		16)
			rv_pmcmd_msg="Password environment variable missing" ;;
		17)
			rv_pmcmd_msg="Parameter file doesnot exist" ;;
		18)
			rv_pmcmd_msg="Initial value missing from parameter file" ;;
		20)
			rv_pmcmd_msg="Repository error occurred. Pls check repository server and database are running" ;;
		21)
			rv_pmcmd_msg="PowerCenter server shutting down" ;;
		22)
			rv_pmcmd_msg="Workflow not unique. Please enter folder name" ;;
		23)
			rv_pmcmd_msg="No data available" ;;
		24)
			rv_pmcmd_msg="Out of memory" ;;
		25)
			rv_pmcmd_msg="Command cancelled" ;;
		*)
			rv_pmcmd_msg="** unknown error **" ;;
	esac
	
	if [ $rv_pmcmd -ne 0 ]; then
		echo -e "\n PMCMD Message: "$rv_pmcmd_msg"\n"
		cat $INFA_SHARED/WorkflowLogs/wf_TestConnection.log|grep -i error; echo " "
		cat $INFA_SHARED/SessLogs/s_m_TestConnection.log|grep -i ora; echo " "
		cat $INFA_SHARED/SessLogs/s_m_TestConnection.log|grep -i error
		echo -e "\n\n!!! CONNECTION FAILED - ${rv_pmcmd_msg} !!! \n\n"
	else
		echo -e "\n\n*** CONNECTION SUCCEEDED *** \n\n"
	fi
}

file_param="$INFA_SHARED/BWParam/wf_TestConnection.par"
file_zparam="$INFA_SHARED/Temp/wf_TestConnection.par.z"
# nm_connection=`cat $file_param|grep -i "dbconnection"|cut -d"=" -f2`



if [ $# -eq 0 ]; then
	test_connection
else
	str_param=$*
	$INFA_HOME/server/bin/pmrep connect -r $INFASVC_REP -d $INFASVC_DOM -n $INFA_DEFAULT_USER -X INFA_DEFAULT_DOMAIN_PASSWORD |grep $INFASVC_REP
	if [ $? -ne 0 ]; then 
		echo "ERR: Could not connect to the PowerCenter repository"
		exit 100
	else
		for str in $str_param; do
			nm_curr_val=`cat $file_param | grep -i "DBConnectionSRC" | cut -d '=' -f2`
			db_curr_val=`cat $file_param | grep -i "ORCL" | cut -d '=' -f2`
			txt_find=$nm_curr_val
			txt_replace=$str
			db_type=`$INFA_HOME/server/bin/pmrep getconnectiondetails -t Relational -n $str|grep -v Connection|grep Type|cut -d"=" -f2`
			[ $db_type == "Oracle" ] && db_replace=1 || db_replace=0 ; echo " "
			echo -e "\nINF: Connection "$str' @ '$db_type
			sed -e "s/${txt_find}/${txt_replace}/g" $file_param > $file_zparam
			if [ $? -ne 0 ]; then
				echo "ERR: FIND & REPLACE ended in FAILURE. Aborting script !!!"; exit 1
			else
				rm -f $file_param
				if [ $? -ne 0 ]; then
					echo "ERR: Could not delete param file. Aborting script !!!"; exit 2
				else
					mv -f $file_zparam $file_param
					if [ $? -ne 0 ]; then
						echo "ERR: Could not move updated param file. Aborting script !!!"; exit 3
					fi
				fi
			fi
			
			sed -e "s/${db_curr_val}/${db_replace}/g" $file_param > $file_zparam
			if [ $? -ne 0 ]; then
				echo "ERR: FIND & REPLACE ended in FAILURE. Aborting script !!!"; exit 4
			else
				rm -f $file_param
				if [ $? -ne 0 ]; then
					echo "ERR: Could not delete param file. Aborting script !!!"; exit 5
				else
					mv -f $file_zparam $file_param
					if [ $? -ne 0 ]; then
						echo "ERR: Could not move updated param file. Aborting script !!!"; exit 6
					fi
				fi
			fi
			
			test_connection $txt_replace
		done
		$INFA_HOME/server/bin/pmrep cleanup
	fi
fi
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG
