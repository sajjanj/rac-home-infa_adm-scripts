#!/bin/bash

# NAME   :show_conn_perms.sh 
# USAGE  :./show_conn_perms.sh <connection_name>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Powercenter Connection Permissions LookUp Utility
# AUTHOR :Sajjan Janardhanan 09/07/2018

. ~/.bash_profile
func_header "Powercenter Connection Permissions LookUp Utility"

pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
rpad_txt="                              "

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
select 
  object_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(object_name)) ||
  ug_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug_name)) ||
  ug || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug)-15) || perms
from  (
  select os.object_name, oug.name as ug_name, 
    decode (ooa.user_type, 1, 'USER', 2, 'GROUP') as ug,  
    case 
      when ((ooa.permissions - (ooa.user_id+ 1)) in(8,16)) then 'R--' 
      when ((ooa.permissions - (ooa.user_id+ 1)) in (10,20)) then 'R-X' 
      when ((ooa.permissions - (ooa.user_id+ 1)) in (12,24)) then 'RW-'  
      when ((ooa.permissions - (ooa.user_id+ 1)) in (14,28))then 'RWX' 
      else 'n/a'
    end as perms
  from ${PCMX_SCHEMA}.opb_object_access ooa 
    inner join ${PCMX_SCHEMA}.opb_cnx os 
      on ooa.object_id = os.object_id and ooa.object_type = os.object_type
    inner join ${PCMX_SCHEMA}.opb_user_group oug 
      on ooa.user_id = oug.id and ooa.user_type = oug.type 
  where upper(os.object_name) = upper('${string_pattern}') )
order by upper(ug_name) ;
exit ;
SQLMX
echo -e $COLOR_NONE" "