#!/bin/bash
# created 10/10/2018 by Sajjan Janardhanan
# List tasks that is like the input value
# Usage: ./findinfatask.sh <string parameter> <0|1> 
#        The string parameter could be a part or the complete task name
#        The 2nd parameter determines the comparison operator 
#          "0" for EQUAL-TO and "1" for LIKE

. ~/bash_profile
func_header 'Data-Services utility to list tasks from the INFA repo-db'
pswd_file_nm=~/scripts/db_pass.txt
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
rpad_txt="                           "
dpad_txt="---------------------------"

if [ $# -ne 2 ]; then
	echo -e "\nERR: Insufficient or too many arguments\n"
	exit 10
else
	string_pattern=$1
	comp_rule=$2
fi

if [ $comp_rule -eq 0 ]; then

sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select * from (
select
  '-SUB' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('-SUB')) ||
  'TYPE' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('TYPE')) ||
  'TASK_NAME' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('TASK_NAME')) ||
  'REUSABLE' || '---' || 'LUDTTM' from dual union
select
  subject_area|| substr('${rpad_txt}',1,length('${rpad_txt}')-length(subject_area)) ||
  task_type_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(task_type_name)) ||
  task_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(task_name)) || 
  is_reusable || '          ' || last_saved
from ${PCMX_SCHEMA}.rep_all_tasks
where upper(subject_area) = upper('${string_pattern}')
or upper(task_name) = upper('${string_pattern}')) order by 1 ;
exit ;
SQLMX

else

sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select
  'SUB' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('SUB')) ||
  'TYPE' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('TYPE')) ||
  'TASK_NAME' || substr('${dpad_txt}',1,length('${dpad_txt}')-length('TASK_NAME')) ||
  'REUSABLE' || '---' || 'LUDTTM'
from dual union
select
  subject_area|| substr('${rpad_txt}',1,length('${rpad_txt}')-length(subject_area)) ||
  task_type_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(task_type_name)) ||
  task_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(task_name)) ||
  is_reusable || '          ' || last_saved
from ${PCMX_SCHEMA}.rep_all_tasks
where upper(subject_area) like upper('%${string_pattern}')
or upper(task_name) like upper('%${string_pattern}%') ;
exit ;
SQLMX

fi

echo 

