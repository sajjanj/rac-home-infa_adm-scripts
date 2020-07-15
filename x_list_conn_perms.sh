#!/bin/bash
# created 09/07/2018 by Sajjan Janardhanan
# List PC connection permissions
# This feature does not exist in PMREP
# Usage: ./list_conn.sh <string> (or) lc <string>

echo -e "\n************************************************************"
echo -e "* Data-Services utility to list PC connections permissions *"
echo -e "************************************************************"
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
rpad_txt="                              "

if [ $# -ne 1 ]; then
	echo -e "\nERR: Insufficient or too many arguments\n"
	exit 10
else
	string_pattern=$1
fi
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select 
  ug_name || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug_name)) ||
  ug || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug)) || perms
from  (
  select oug.name as ug_name, 
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
  where os.object_name = '${string_pattern}'
  order by 1,3 );
exit ;
SQLMX

echo 