#!/bin/bash
# created 09/07/2018 by Sajjan Janardhanan
# list the permissions for an INFA PC folder
# this feature does not exist in PMREP
# Usage: ./list_folder_perms.sh <folder name> (or) lfp <folder name>

echo -e "\n*******************************************************"
echo -e "* Data-Services utility to list PC folder permissions *"
echo -e "*******************************************************"
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
rpad_txt="                         "

if [ $# -ne 1 ]; then
	echo -e "\nERR: Insufficient or too many arguments\n"
	exit 10
else
	folder_nm=$1
fi
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select 
  ug_nm || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug_nm)) ||
  ug || substr('${rpad_txt}',1,length('${rpad_txt}')-length(ug)) ||
  perms || substr('${rpad_txt}',1,length('${rpad_txt}')-length(perms)) 
from  (
  select rtrim(oug.name) as ug_nm, 
    decode(ooa.user_type, 1, 'USER', 2, 'GROUP') as ug,  
    case 
      when ((ooa.permissions - (ooa.user_id+ 1)) in(8,16)) then 'r--' 
      when ((ooa.permissions - (ooa.user_id+ 1)) in (10,20)) then 'r-x' 
      when ((ooa.permissions - (ooa.user_id+ 1)) in (12,24)) then 'rw-'  
      when ((ooa.permissions - (ooa.user_id+ 1)) in (14,28))then 'rwx' 
      else '---'
    end as perms
  from $PCMX_SCHEMA.opb_object_access ooa 
    inner join $PCMX_SCHEMA.opb_subject os 
	  on ooa.object_id = os.subj_id 
    inner join $PCMX_SCHEMA.opb_user_group oug 
	  on ooa.user_id = oug.id 
	  and  ooa.user_type = oug.type
  where ooa.object_type = 29 
  and oug.name not like  'Administrator%'
  and os.subj_name = '${folder_nm}'
  order by 1,2);

exit ;
SQLMX

echo 
