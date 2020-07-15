#!/bin/bash

# NAME   :cpst.sh
# USAGE  :./cpst.sh <(S)ource|(T)arget> <Source_Folder> <Target_Folder> <Object_Name>
# EXAMPLE:./cpst.sh T z_halgee ENTERPRISE_DB PARTY_ACCOUNT
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Copy source and target objects between folders in the same repository
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Data-Services INFA Source/Target copy utility"

ctl_file_nm=/infa_shared/Temp/cpst.ctl
spl_file_nm=/infa_shared/Temp/cpst.spl
log_file_nm=/infa_shared/Temp/cpst.log
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"
svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
clientip=$(echo $SSH_CLIENT|cut -d" " -f1)
clientnm=$(host ${clientip}|cut -d" " -f5|cut -d"." -f1)
rpad_subj="                    "
rpad_dbnm="                    "

# echo "svc_acct = "$svc_acct
# echo "svc_pswd = "$svc_pswd
echo "clientip = "$clientip
echo "clientnm = "$clientnm
# echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 

if [ $# -lt 4 ] || [ $# -gt 5 ]; then
	echo -e "\nERR: Insufficient or too many arguments\n"
	exit 10
else
	i_obj_type=$1
	i_src_subj=$2
	i_tgt_subj=$3
	i_obj_nm=$4
	[ $# -eq 5 ] && i_db_nm=$5 || i_db_nm='n/a'
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3"|"$4"|"$i_db_nm>>$MASTER_LOG
	echo -e "\nINF: Input parameters listed below\n"
	echo "   > Object Type         = "$i_obj_type
	echo "   > Subject Area (FROM) = "$i_src_subj
	echo "   > Subject Area (TO)   = "$i_tgt_subj
	echo "   > Object Name         = "$i_obj_nm
	echo "   > Database/Group Name = "$i_db_nm
fi

# echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 
# if [ $clientnm == 'rac-l-c6c5v32' ]; then
# elif [ $clientnm == 'rac-l-cg3xf72' ]; then
# else
# fi

echo -e $COLOR_CYAN"\nINF: Creating control file ["$ctl_file_nm"]\n"$COLOR_NONE
echo '<?xml version="1.0" encoding="UTF-8"?>' > $ctl_file_nm
echo '<!DOCTYPE IMPORTPARAMS SYSTEM "impcntl.dtd">' >> $ctl_file_nm
echo '<IMPORTPARAMS CHECKIN_AFTER_IMPORT="NO">' >> $ctl_file_nm
echo '<FOLDERMAP' >> $ctl_file_nm
echo '  SOURCEFOLDERNAME="'$i_src_subj'"' >> $ctl_file_nm
echo '  SOURCEREPOSITORYNAME="'$INFASVC_REP'"' >> $ctl_file_nm
echo '  TARGETFOLDERNAME="'$i_tgt_subj'"' >> $ctl_file_nm
echo '  TARGETREPOSITORYNAME="'$INFASVC_REP'"/>' >> $ctl_file_nm
echo '<RESOLVECONFLICT>' >> $ctl_file_nm
echo '<TYPEOBJECT OBJECTTYPENAME = "SOURCE DEFINITION" RESOLUTION="REPLACE"/>' >> $ctl_file_nm
echo '<TYPEOBJECT OBJECTTYPENAME = "TARGET DEFINITION" RESOLUTION="REPLACE"/>' >> $ctl_file_nm
echo '</RESOLVECONFLICT>' >> $ctl_file_nm
echo '</IMPORTPARAMS>' >> $ctl_file_nm

cat $ctl_file_nm
echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 

echo -e $COLOR_CYAN"\nINF: Creating SQL to query MX views"$COLOR_NONE
if [ $i_obj_type == 'S' ]; then
	obj_type="Source"
	obj_nm=${i_db_nm}"."${i_obj_nm}
	mx_tbl_nm="sj_rass"
	select_stmt=" psub, pobjnm, pdbnm, pls, last_saved_by_user "
elif [ $i_obj_type == 'T' ]; then
	obj_type="Target"
	obj_nm=${i_obj_nm}
	mx_tbl_nm="sj_rats"
	select_stmt=" psub, pobjnm, 'n/a' as pdbnm, pls, last_saved_by_user "
else
	echo -e $COLOR_RED"ERR: Invalid object type ["$i_obj_type"]"$COLOR_NONE
	exit 20
fi
xml_file_nm="/infa_shared/Temp/cpst_"${obj_nm}".xml"

# echo "obj_type    = "$obj_type
# echo "obj_nm      = "$obj_nm
# echo "mx_tbl_nm   = "$mx_tbl_nm
# echo "select_stmt = "$select_stmt
# echo "xml_file_nm = "$xml_file_nm
# echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 

echo -e $COLOR_CYAN"\nINF: Running SQL to query MX views \n "$COLOR_NONE
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 200 trimspool on heading off echo off term off pagesize 0 ;
set feedback off timing off verify off serveroutput on size 1000000;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select '> ${obj_type} ${i_obj_nm} found in ${INFASVC_REP} at non Z/X folders below ==>' from dual;
select psub || substr('${rpad_subj}',1,length('${rpad_subj}')-length(psub)) ||' | '||
pobjnm||' | '||
pdbnm || substr('${rpad_dbnm}',1,length('${rpad_dbnm}')-length(pdbnm)) ||' | '||
pls||' | '||last_saved_by_user from (
	select $select_stmt 
	from dev_pc_rep.${mx_tbl_nm} where psub=sub 
	and psub not like 'z%'
	and psub not like 'x%'
	and pobjnm=upper('${i_obj_nm}')
	order by 1,3 );
select ' ' from dual;
select '> ${obj_type} ${i_obj_nm} found as shortcut in the folders listed below ==>' from dual;
select distinct sub from dev_pc_rep.${mx_tbl_nm} where 1=1
and psub<>sub 
and pobjnm=upper('${i_obj_nm}')
order by 1;
select ' ' from dual;
select '> The folder ${i_tgt_subj} has the following distinct groups for sources ==>' from dual;
select distinct pdbnm from dev_pc_rep.sj_rass where 1=1
and psub=sub 
and psub='${i_tgt_subj}'
order by upper(pdbnm);
exit;
SQLMX

echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 
echo -e $COLOR_CYAN"\nINF: Attempting to connect to the repository "$COLOR_NONE
$INFA_HOME/server/bin/pmrep connect -r $INFASVC_REP -d $INFASVC_DOM \
-n $INFA_DEFAULT_USER -X INFA_DEFAULT_DOMAIN_PASSWORD
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"\nERR: errors encountered\n"$COLOR_NONE
	exit 30
fi
# echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 
echo -e $COLOR_CYAN"\nINF: Attempting to export the "$obj_type" object ["$obj_nm"] "$COLOR_NONE
$INFA_HOME/server/bin/pmrep objectexport -n $obj_nm -o $obj_type -f $i_src_subj -u $xml_file_nm
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"\nERR: errors encountered\n"$COLOR_NONE
	exit 40
fi
# echo -e "\n> Press any key to continue and Ctrl+C to quit ... \c";read abc 
echo -e $COLOR_CYAN"\nINF: Attempting to import the "$obj_type" object ["$obj_nm"] into folder ["$i_tgt_subj"] "$COLOR_NONE
$INFA_HOME/server/bin/pmrep objectimport -i $xml_file_nm -c $ctl_file_nm -l $log_file_nm
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"\nERR: errors encountered\n"$COLOR_NONE
	exit 50
fi
echo -e $COLOR_CYAN"\nINF: Listing the objects checked-out in folder ["$i_tgt_subj"] \n"$COLOR_NONE
$INFA_HOME/server/bin/pmrep findcheckout -f $i_tgt_subj -c "|" -b | grep $obj_nm
echo -e $COLOR_CYAN"\nQST: Proceed with checkin/undocheckout/skip (C/U/S) ?"$COLOR_NONE" \c"; read cul
if [[ $cul == "C" ]]; then
	echo -e $COLOR_CYAN"\nINF: Attempting to checkin the object ["$obj_nm"] "$COLOR_NONE
	checkin_comments="Copied from "$i_src_subj" in client "$clientnm" using CPST"
	$INFA_HOME/server/bin/pmrep checkin -o $obj_type -n $obj_nm -f $i_tgt_subj \
	-c "$checkin_comments"
	echo -e $COLOR_CYAN"\nINF: Check-in Comments = "${COLOR_NONE}$checkin_comments
elif [[ $cul == "U" ]]; then
	echo -e $COLOR_CYAN"\nINF: Attempting to undocheckout of object ["$obj_nm"] \n"$COLOR_NONE
	$INFA_HOME/server/bin/pmrep undocheckout -o $obj_type -n $obj_nm -f $i_tgt_subj 
else
	echo -e $COLOR_CYAN"\nINF: No action was performed on the object ["$obj_nm"] in folder ["$i_tgt_subj"] \n"$COLOR_NONE
fi
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"\nERR: errors encountered\n"$COLOR_NONE
	exit 60
else
	echo -e $COLOR_CYAN"\nINF: Process completed successfully; Please validate the changes\n"$COLOR_NONE
fi
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3"|"$4"|"$i_db_nm>>$MASTER_LOG
