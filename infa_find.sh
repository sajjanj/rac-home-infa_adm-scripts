#!/bin/bash

# NAME   :infa_find.sh
# USAGE  :./infa_find.sh <search pattern>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :INFA Repository Object Find Utility; Search string not case sensitive
# AUTHOR :Sajjan Janardhanan 10/10/2018

. ~/.bash_profile
IFS=$'\n'

func_header "INFA Repository Object Find Utility"

pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
object_nm_hdr="Searching for object NAMES that resemble the search text"
object_attr_hdr="Searching for object ATTRIBUTES that resemble the search text"
rpad_txt="                           "
dpad_txt="---------------------------"

if [ $# -eq 0 ]; then
  echo -e $COLOR_RED"\nERR: Insufficient arguments\n"$COLOR_NONE
  exit 10
elif [ $# -eq 1 ]; then
  string_pattern=$1
  comp_rule=0
else
  string_pattern=$1
  comp_rule=$2
fi

echo -e $COLOR_RED"\n > "$object_nm_hdr $COLOR_GREEN
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select * from (
select '*FolderName | ObjectType | ObjectID | ObjectName | Reusable? | LastUpdateDt*' from dual union
select '----------------------------------------------------------------------------' from dual union
select 
  subject_area || ' | ' || task_type_name || ' | ' || task_id || ' | ' || 
  task_name || ' | ' || is_reusable || ' | ' || last_saved
from ${PCMX_SCHEMA}.rep_all_tasks where upper(task_name) like upper('%${string_pattern}%') union
select 
  subject_area || ' | ' || 'Mapping' || ' | ' || mapping_id || ' | ' || 
  mapping_name || ' | ' ||  '0' || ' | ' || mapping_last_saved
from ${PCMX_SCHEMA}.rep_all_mappings where upper(mapping_name) like upper('%${string_pattern}%') union
select 
  subject_area || ' | ' || 'Mapplet' || ' | ' || mapplet_id || ' | ' || 
  mapplet_name || ' | ' ||  '0' || ' | ' || mapplet_last_saved
from ${PCMX_SCHEMA}.rep_all_mapplets where upper(mapplet_name) like upper('%${string_pattern}%') union
select 
  subject_area || ' | ' || 'Widget' || ' | ' || widget_id || ' | ' || 
  widget_name || ' | ' ||  '0' || ' | ' || widget_last_saved
from ${PCMX_SCHEMA}.rep_all_transforms where upper(widget_name) like upper('%${string_pattern}%')
) order by 1 ;
exit ;
SQLMX
echo -e $COLOR_CYAN" > Press any key to continue or CTRL+C to quit ...\c"$COLOR_NONE ; read c
echo -e $COLOR_RED"\n > "$object_attr_hdr $COLOR_GREEN
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select * from (
select '*FolderName | ObjectTypeName | ObjectName | AttributeName | AttributeValue*' from dual union
select '-----------------------------------------------------------------------' from dual union
select distinct rat.subject_area || ' | ' || rat.task_type_name || ' | ' || rat.task_name || ' | ' || rta.attr_name || ' | ' || rta.attr_value
from ${PCMX_SCHEMA}.rep_all_tasks rat, ${PCMX_SCHEMA}.rep_task_attr rta where 1=1 
and rta.task_id = rat.task_id
and upper(rta.attr_value) like upper('%${string_pattern}%') union
select distinct ram.subject_area || ' | ' || rw.widget_type_name || ' | ' || rw.widget_name || ' @ ' || ram.mapping_name || ' | ' || attr_name || ' | ' || rwa.attr_value 
from ${PCMX_SCHEMA}.rep_widget_attr rwa, ${PCMX_SCHEMA}.rep_all_transforms rw, ${PCMX_SCHEMA}.rep_all_mappings ram where 1=1
and rwa.widget_id = rw.widget_id
and rwa.mapping_id = ram.mapping_id
and upper(rwa.attr_value) like upper('%${string_pattern}%')
) order by 1 ;
exit ;
SQLMX
echo -e $COLOR_NONE

