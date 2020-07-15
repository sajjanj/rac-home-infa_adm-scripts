#!/bin/bash
# NAME   :rats.sh
# USAGE  :./rats.sh <search_text> <0(exact)|1(like)>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :List target objects that is an exact match or resembles the input search text 
# AUTHOR :Sajjan Janardhanan 10/03/2018

. ~/.bash_profile
func_header "Utility to search INFA Target objects"
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)

if [ $# -ne 2 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE
	exit 10
else
	string_pattern=$1
	comp_rule=$2
fi

echo -e $COLOR_CYAN" "
if [ $comp_rule -eq 0 ]; then
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select * from (
	SELECT '--POBJ | PSUB | PLS' FROM DUAL UNION
	select parent_target_name || ' | ' || parent_subject_area || ' | ' || parent_target_last_saved as LST
	from (
		select * from ${PCMX_SCHEMA}.rep_all_targets 
		where parent_subject_area = subject_area
		and upper(parent_target_name) = upper('${string_pattern}') 
		order by parent_target_name, parent_subject_area )
) order by 1 ;
exit ;
SQLMX
else
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set heading off linesize 16000 pagesize 40000 long 32000 serveroutput on size 32000 ;
select * from (
	SELECT '--POBJ | PSUB | PLS' FROM DUAL UNION
	select parent_target_name || ' | ' || parent_subject_area || ' | ' || parent_target_last_saved as LST
	from (
		select * from ${PCMX_SCHEMA}.rep_all_targets 
		where parent_subject_area = subject_area
		and upper(parent_target_name) like upper('%${string_pattern}%')
		order by parent_target_name, parent_subject_area )
) order by 1 ;
exit ;
SQLMX
fi
echo -e $COLOR_NONE" "

# set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
# set feedback off heading off echo off term off ;
# set timing off trimspool off trimout on verify off ;
# alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
#like upper('%${string_pattern}%'
