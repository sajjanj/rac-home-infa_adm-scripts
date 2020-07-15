#!/bin/bash

# NAME   :show_version_history.sh 
# USAGE  :./show_version_history.sh <Folder_Name> <Object_Name>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Display recent version history of an object or object dependencies
# AUTHOR :Sajjan Janardhanan 11/08/2018

. ~/.bash_profile
func_header "Displaying Recent Version History"
pswd_file_nm=$FILE_PASSWD
pswd_file_key="INFAMXSVCACCT"

if [ -f $pswd_file_nm ]; then
	svc_acct=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f4)
	svc_pswd=$(grep -iw $pswd_file_key $pswd_file_nm|cut -d"|" -f5)
else
	echo -e $COLOR_RED"\nERR: DBPASS file not found; cannot proceed\n"$COLOR_NONE ; exit 10
fi

if [ $# -ne 2 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or Too many arguments\n"$COLOR_NONE ; exit 20
else
	sub_nm=$1 ; obj_nm=$2
fi

echo -e $COLOR_GREEN"\nQST: Show version history for dependencies Y/N ? (default=N) = \c"$COLOR_NONE; read alldep
[[ $alldep = 'Y' || $alldep = 'y' ]] && alldep='Y' || alldep='N'

echo -e $COLOR_GREEN"QST: Please enter the number of characters to display in version comments (default=50) = \c"$COLOR_NONE; read comments_limit
[[ $comments_limit = "" ]] && comments_limit=50

if [[ $alldep == "N" ]]; then
	
	echo -e $COLOR_GREEN"QST: Please enter the number of records to display (default=5) = \c"$COLOR_NONE; read numrecs
	[[ $numrecs = "" ]] && numrecs=5
	echo -e $COLOR_CYAN" "
	echo '* ObjectType | ObjectName | UserID | Version# | SavedDate | SavedFrom | VersionComments *' 
	echo '-----------------------------------------------------------------------------------------' 
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select * from (
  select 
    object_type || ' | ' ||
    object_name || ' | ' || 
    user_name || ' | ' ||
    version_number || ' | ' ||
    version_status || ' | ' ||
    saved_dt || ' | ' ||
    saved_from || ' | ' || 
	comments
  from (  
    select subject_area, object_type, object_name, version_number, version_status, user_name, saved_from, 
    to_char(last_saved_dt, 'yyyy-mm-dd hh24:mi:ss') as saved_dt, substr(version_comments,1,${comments_limit}) as comments
    from ${PCMX_SCHEMA}.sj_all_version_props where 1=1
    and upper(subject_area) = upper('${sub_nm}')
    and upper(object_name)  = upper('${obj_nm}') )
  order by subject_area, object_name, version_number desc ) 
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
	
	[[ `echo $obj_nm|grep -i "^wf"|wc -l` -gt 0 ]] && obj_type="Workflow" || obj_type="Session"
	echo -e $COLOR_CYAN" "
	echo '* ObjectType | ObjectName | UserID | Version# | SavedDate | SavedFrom | VersionComments *' 
	echo '-----------------------------------------------------------------------------------------' 
	for s_lod in `pmrep listobjectdependencies -c "|" -b -p children -y -n $obj_nm -o $obj_type -f $sub_nm|grep RAC|sort|grep -iEv "shortcut|config"|grep -iE "mapplet|mapping|session|worklet|workflow"` ; do
		dep_sub_name=`echo $s_lod | cut -d"|" -f2`
		dep_obj_type=`echo $s_lod | cut -d"|" -f3`
		[ $dep_obj_type == "mapplet" ] && dep_obj_name=`echo $s_lod | cut -d"|" -f4`
		[ $dep_obj_type == "mapping" ] && dep_obj_name=`echo $s_lod | cut -d"|" -f4`
		[ $dep_obj_type == "session" ] && dep_obj_name=`echo $s_lod | cut -d"|" -f5|cut -d "." -f2`
		[ $dep_obj_type == "workflow" ] && dep_obj_name=`echo $s_lod | cut -d"|" -f4`
		
sqlplus -s ${svc_acct}/${svc_pswd}@${DB_TNSKEY} <<SQLMX
whenever sqlerror exit -1
set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
set feedback off heading off echo off term off ;
set timing off trimspool off trimout on verify off ;
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
select * from (
  select 
    object_type || ' | ' ||
    object_name || ' | ' ||
    user_name || ' | ' ||
    version_number || ' | ' ||
    saved_dt || ' | ' ||
    saved_from || ' | ' || 
	comments 
  from (  
    select subject_area, object_type, object_name, version_number,user_name, saved_from, 
    to_char(last_saved_dt, 'yyyy-mm-dd hh24:mi:ss') as saved_dt, substr(version_comments,1,${comments_limit}) as comments
    from ${PCMX_SCHEMA}.sj_all_version_props where 1=1
	and lower(object_type) = '${dep_obj_type}'
    and upper(subject_area) = upper('${dep_sub_name}')
    and upper(object_name)  = upper('${dep_obj_name}') )
  order by subject_area, object_name, version_number desc ) 
where rownum <= 1
order by 1;
exit ;
SQLMX
		
	done
	echo -e $COLOR_GREEN" "
	$INFA_HOME/server/bin/pmrep cleanup|grep -i "cleanup"
	
else
	echo -e $COLOR_RED"\nERR: Unexpected error encountered \n"$COLOR_NONE ; exit 40
fi
echo -e $COLOR_NONE" "
