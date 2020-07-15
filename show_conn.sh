#!/bin/bash

# NAME   :show_conn.sh 
# USAGE  :./show_conn.sh <search_string>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Powercenter connection search utility
# AUTHOR :Sajjan Janardhanan 09/07/2018

. ~/.bash_profile
func_header "Powercenter Connection Search Utility"

pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"

if [ -f $pswd_file_nm ]; then
	svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
	svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
else
	echo -e $COLOR_RED"\nERR: DBPASS file not found; cannot proceed\n"$COLOR_NONE ; exit 10
fi

if [ $# -ne 1 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE ; exit 20
fi

string_pattern=$1
echo -e $COLOR_CYAN" "
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select * from (
  select '*ConnectionName | ConnectionType | UserID @ TNSkey | UpdateDt*' from dual union
  select '---------------------------------------------------------------------------' from dual union
  select conn_name || ' | ' || conn_type || ' | ' || lower(userid) || ' @ ' || upper(tnskey) || ' | ' || update_dt 
  from  (
    select nvl(connect_string,'n/a') as tnskey, user_name as userid, 
      object_name as conn_name, connection_type as conn_type, lmdttm as update_dt
    from ${PCMX_SCHEMA}.sj_cnx where 1=1
    and (lower(object_name) like lower('%${string_pattern}%')
      or lower(user_name) like lower('%${string_pattern}%')
      or lower(connect_string) like lower('%${string_pattern}%') 
	  )
    )
) order by 1 ;
exit ;
SQLMX
echo -e $COLOR_NONE" "
