#!/bin/bash

# NAME   :show_infa_user.sh
# USAGE  :./show_infa_user.sh.sh <dtl|lst> <userid>
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script fetches the profile of an INFA user
# AUTHOR :Sajjan Janardhanan 01/30/2019

. ~/.bash_profile
func_header "Displaying INFA User Profile"
IFS=$'\n'
now=`date +%Y%m%d%H%M%S`
file_spool=~/scripts/log/show_infa_user.log
file_spool_fixed=~/scripts/log/show_infa_user.txt
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
rec_complete_flg=0

if [ -f $pswd_file_nm ]; then
	svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
	svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
else
	echo -e $COLOR_RED"\nERR: DBPASS file not found; cannot proceed\n"$COLOR_NONE ; exit 10
fi

if [ $# -lt 2 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE ; exit 20
else
	i_output_type=$1
	i_userid=$2
	if [[ $i_output_type != "dtl" ]] && [[ $i_output_type != "lst" ]]; then
		echo -e $COLOR_RED"\nERR: Invalid output type. Valid values are "$COLOR_NONE"dtl"$COLOR_RED" & "$COLOR_NONE"lst\n" ; exit 30
	fi
fi

if [ $i_output_type == "dtl" ]; then

	rm -f $file_spool
retval=`sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
spool ${file_spool} ;
set newpage 0 
set space 0
set serveroutput on 
--set recsep off
set linesize 3000
set long 3000
set pagesize 0 
set termout on
--set heading off 
set echo off 
set feedback off
set trimspool on
set trim on
set term on
--set timing off 
set verify off 
set pause off
--set wrap off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select 
    user_id || '|' ||
	full_name || '|' ||
	email_addr || '|' ||
	phone_num || '|' || 
	trim(description) || '|' ||
	user_created_dt || '|' ||
	user_updated_dt || '|' ||
	pswd_updated_dt || '|' ||
	trunc(sysdate-pswd_updated_dt) || '|' ||
	num_failed_login_attempts || '|' ||
	account_locked || '|' ||
	disabled_user
from (
    select 
        mc.object_name as user_id, 
        pui.pou_fullname as full_name,
        pui.pou_email as email_addr,
        pui.pou_phone as phone_num,
        pui.pou_descriptio1 as description,
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(creation_time/1000,'SECOND'), 'GMT', 'GMT') as user_created_dt, 
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(LAST_UPDATED_TIME/1000,'SECOND'), 'GMT', 'GMT') as user_updated_dt,
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(pui.pou_passwordlastmodifiedt/1000,'SECOND'), 'GMT', 'GMT') as pswd_updated_dt,
        pui.pou_invalidloginattempts as num_failed_login_attempts,
        case pui.pou_accountlocked when 1 then 'Y' when 0 then 'N' else '-' end as account_locked,
        case pi.poi_disable when 1 then 'Y' when 0 then 'N' else '-' end as disabled_user
    from 
		${INFA_DEFAULT_DATABASE_USER}.po_userinfo pui, 
		${INFA_DEFAULT_DATABASE_USER}.po_idobj pi, 
		${INFA_DEFAULT_DATABASE_USER}.mri_container mc
    where 1=1
        and pi.poi_userinfo = pui.psu_opid
        and pi.poi_name = mc.object_name 
        and pi.psi_opid = mc.ro_oid
        and pi.psi_discriminator = 'USER'
        and upper(mc.object_name) like upper('%${i_userid}%') ) ;
spool off ;
exit ;
SQLMX`

	# ------ fixing broken records ------>>>>>>>>>>|
	# the spool file was wrapping printing a single record in multiple lines even though the linesize was set to a high value
	# the code below is a temporary solution to bring the record in a single line, until we find the SET command in SQLPLUS
	rec_delim_cnt_const=11
	while read raw_row; do
		raw_delim_cnt=`echo $raw_row|grep -o "|"|wc -l`
		if [ $raw_delim_cnt -eq $rec_delim_cnt_const ]; then
			rec_row=$raw_row
			rec_complete_flg=1
		else	
			rec_row=${rec_row}$raw_row
			rec_delim_cnt=`echo $rec_row|grep -o "|"|wc -l`
			if [ $rec_delim_cnt -eq $rec_delim_cnt_const ]; then
				rec_complete_flg=1
			elif [ $rec_delim_cnt -gt $rec_delim_cnt_const ]; then
				echo -e $COLOR_RED"ERR: Record appears to have too many fields"$COLOR_NONE
			fi
		fi
		if [ $rec_complete_flg -eq 1 ]; then
			# echo $rec_row
			echo -e $COLOR_CYAN" "
			echo "        UserID = "`echo $rec_row|cut -d"|" -f1`
			echo "     Full Name = "`echo $rec_row|cut -d"|" -f2`
			echo " Email Address = "`echo $rec_row|cut -d"|" -f3`
			echo "  Phone Number = "`echo $rec_row|cut -d"|" -f4`
			echo "   Description = "`echo $rec_row|cut -d"|" -f5`
			echo "  Created Date = "`echo $rec_row|cut -d"|" -f6`
			echo "  Updated Date = "`echo $rec_row|cut -d"|" -f7`
			echo "Pswd Update Dt = "`echo $rec_row|cut -d"|" -f8`
			echo "      Pswd Age = "`echo $rec_row|cut -d"|" -f9`
			echo "#Failed Logins = "`echo $rec_row|cut -d"|" -f10`
			echo "Account Locked = "`echo $rec_row|cut -d"|" -f11`
			echo " Disabled User = "`echo $rec_row|cut -d"|" -f12`
			rec_complete_flg=0
			echo -e $COLOR_NONE" "
			rec_row=""
		fi
	done < ${file_spool}
	# |<<<<<<<<<<------ fixing broken records ------

elif [ $i_output_type == "lst" ]; then

	echo -e $COLOR_CYAN
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
--set newpage 0 
--set space 0
set serveroutput on size 10000
--set recsep off
set linesize 30000
set pagesize 0 
--set long 3000
--set termout on
--set heading off 
--set echo off 
set feedback off
--set trimspool on
--set trim on
set term on
--set timing off 
set verify off 
--set pause off
--set wrap off
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select '*DISABLED | FULL_NAME | USER_ID | LOCKED | ATTEMPTS | PSWD_DT | PSWD_AGE*' from dual union
select '-------------------------------------------------------------------------' from dual ;
select 
	disabled_user || ' | ' ||
	full_name || ' | ' ||
    user_id || ' | ' ||
	account_locked || ' | ' ||
	num_failed_login_attempts || ' | ' ||
	pswd_updated_dt || ' | ' ||
	trunc(sysdate-pswd_updated_dt) 
from (
    select 
        mc.object_name as user_id, 
        pui.pou_fullname as full_name,
        pui.pou_email as email_addr,
        pui.pou_phone as phone_num,
        pui.pou_descriptio1 as description,
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(creation_time/1000,'SECOND'), 'GMT', 'GMT') as user_created_dt, 
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(LAST_UPDATED_TIME/1000,'SECOND'), 'GMT', 'GMT') as user_updated_dt,
        NEW_TIME(to_date('1970/01/01','yyyy/mm/dd') + numtodsinterval(pui.pou_passwordlastmodifiedt/1000,'SECOND'), 'GMT', 'GMT') as pswd_updated_dt,
        pui.pou_invalidloginattempts as num_failed_login_attempts,
        case pui.pou_accountlocked when 1 then 'Y' when 0 then 'N' else '-' end as account_locked,
        case pi.poi_disable when 1 then 'Y' when 0 then 'N' else '-' end as disabled_user
    from 
		${INFA_DEFAULT_DATABASE_USER}.po_userinfo pui, 
		${INFA_DEFAULT_DATABASE_USER}.po_idobj pi, 
		${INFA_DEFAULT_DATABASE_USER}.mri_container mc
    where 1=1
        and pi.poi_userinfo = pui.psu_opid
        and pi.poi_name = mc.object_name 
        and pi.psi_opid = mc.ro_oid
        and pi.psi_discriminator = 'USER'
        and upper(mc.object_name) like upper('%${i_userid}%') ) order by disabled_user, full_name ;
exit ;
SQLMX
	echo -e $COLOR_NONE
fi
exit 0
