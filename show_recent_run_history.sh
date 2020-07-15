#!/bin/bash

# NAME   :show_recent_run_history.sh 
# USAGE  :./show_recent_run_history.sh <Folder_Name> <Session_or_Workflow_Name>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :List recent run history of the workflow/session with or without dependencies
# AUTHOR :Sajjan Janardhanan 12/04/2018

. ~/.bash_profile
func_header "Displaying Recent Run History"
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"

if [ -f $pswd_file_nm ]; then
	svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
	svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
else
	echo -e $COLOR_RED"\nERR: DBPASS file not found; cannot proceed\n"$COLOR_NONE ; exit 10
fi

if [ $# -ne 2 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE ; exit 20
else
	sub_nm=$1 ; obj_nm=$2 ; numrecs=0
fi

echo -e $COLOR_GREEN"\nQST: Show recent-run history for dependencies Y/N ? (default=N) = \c"$COLOR_NONE; read alldep
[[ $alldep = 'Y' || $alldep = 'y' ]] && alldep='Y' || alldep='N'

echo -e $COLOR_GREEN"QST: Please enter the number of records to display (default=5) = \c"$COLOR_NONE; read numrecs
[[ $numrecs = "" ]] && numrecs=5

if [[ $alldep == "N" ]]; then

	echo -e $COLOR_CYAN" "
	echo '* WorkflowName:SessionName | RunStatus | StartTime --> EndTime | RunDuration | SourceRows | TargetRows *'
	echo '--------------------------------------------------------------------------------------------------------'
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select * from (
  select
    -- subject_area || '.' ||
    workflow_name || ':' || 
    session_instance_name || ' | ' || 
    run_status || ' | ' ||
    to_char(start_time,'yyyy-mm-dd_hh24:mi:ss') || ' --> ' || 
    to_char(end_time,'yyyy-mm-dd_hh24:mi:ss') || ' | ' || 
    elapsed_time || ' | ' || 
    successful_source_rows || ' | ' || 
    successful_target_rows
  from ${PCMX_SCHEMA}.sj_rep_sess_log where 1=1
    and subject_area = '${sub_nm}'
    and ( upper(workflow_name) = upper('${obj_nm}') 
	  or  upper(session_name)  = upper('${obj_nm}')  )
  order by start_time desc, session_instance_name )
where rownum <= ${numrecs} ;
exit ;
SQLMX

elif [[ $alldep == "Y" ]]; then

	echo -e $COLOR_GREEN" "
	cd $INFA_HOME/server/bin
	./pmrep connect -r $INFASVC_REP -d $INFASVC_DOM -n $INFA_DEFAULT_USER -X INFA_DEFAULT_DOMAIN_PASSWORD|grep -i "connect"
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: Connection errors encountered\n"$COLOR_NONE ; exit 30
	fi
	
	echo -e $COLOR_CYAN" "
	echo '* WorkflowName:SessionName | RunStatus | StartTime --> EndTime | RunDuration | SourceRows | TargetRows *'
	echo '--------------------------------------------------------------------------------------------------------'
	for s_lod in `pmrep listobjectdependencies -c "|" -b -p children -y -n $obj_nm -o Workflow -f $sub_nm|grep -iE "session|workflow"|grep -viE "command|config"|sort` ; do
		dep_obj_type=""; dep_obj_name=""; dep_obj_reusable="" 
		dep_obj_type=`echo $s_lod | cut -d"|" -f3`
		[ $dep_obj_type = "workflow" ] && dep_obj_name=`echo $s_lod | cut -d "|" -f4`
		[ $dep_obj_type = "session" ] && dep_obj_reusable=`echo $s_lod | cut -d "|" -f4` || dep_obj_reusable="not_applicable"
		[ $dep_obj_reusable = "reusable" ] && dep_obj_name=`echo $s_lod | cut -d "|" -f5` 
		[ $dep_obj_reusable = "non-reusable" ] && dep_obj_name=`echo $s_lod | cut -d"|" -f5|cut -d "." -f2` 
		# echo $dep_obj_type":"$dep_obj_name"("$dep_obj_reusable")"
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select * from (
  select
    -- subject_area || '.' ||
    workflow_name || ':' || 
    session_instance_name || ' | ' || 
    run_status || ' | ' ||
    to_char(start_time,'yyyy-mm-dd_hh24:mi:ss') || ' --> ' || 
    to_char(end_time,'yyyy-mm-dd_hh24:mi:ss') || ' | ' || 
    elapsed_time || ' | ' || 
    successful_source_rows || ' | ' || 
    successful_target_rows
  from ${PCMX_SCHEMA}.sj_rep_sess_log where 1=1
    and subject_area = '${sub_nm}'
    and ( upper(workflow_name) = upper('${dep_obj_name}') 
	  or  upper(session_name)  = upper('${dep_obj_name}')  )
  order by start_time desc, session_instance_name )
where rownum <= ${numrecs} ;
exit ;
SQLMX
		
	done
	echo -e $COLOR_GREEN" "
	$INFA_HOME/server/bin/pmrep cleanup|grep -i "cleanup"
else
	echo -e $COLOR_RED"\nERR: Unexpected error encountered \n"$COLOR_NONE ; exit 40
fi
echo -e $COLOR_NONE" "
