#!/bin/bash

# NAME   :db_find.sh
# USAGE  :./db_find.sh <DB object name>
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :Looks for the DB object passed as parameter in all DBs included in the [db_pass.txt] file 
# AUTHOR :Sajjan Janardhanan 10/22/2018

. ~/.bash_profile
func_header "Database Object Find Utility"

if [ $# -ne 1 ]; then
	echo -e "\nERR: Insufficient or too many arguments\n"
	exit 10
fi
db_obj_nm=$1
delimiter="|" ; db_nm_col=2 ; db_usr_col=4 ; db_pass_col=5
echo_db_yn="n"
# func_header "Database Object Find Utility"
echo -e "QST: Display every DB name (y/n) ? \c"; read  echo_db_yn 
echo -e $COLOR_CYAN" "
for ln in `cat $FILE_PASSWD | grep -v "^#"` ; do
	db_nm=`echo $ln|cut -d $delimiter -f $db_nm_col`
	db_usr=`echo $ln|cut -d $delimiter -f $db_usr_col`
	db_pass=`echo $ln|cut -d $delimiter -f $db_pass_col`
	[ $echo_db_yn == "y" ] && echo "----- user @ database = "$db_usr" @ "$db_nm
	db_nm_tns_cnt=`cat $ORACLE_HOME/network/admin/tnsnames.ora|cut -d"=" -f1|grep $db_nm|wc -l`
	if [ $db_nm_tns_cnt -gt 0 ]; then
sqlplus -s ${db_usr}/${db_pass}@${db_nm} <<SQLMX
whenever sqlerror exit -1
set echo off ;
set feed off ;
--set feedback off ;
--set heading off ;
--set term off ;
--set verify off ;
--set timing off 
--set trimspool on ;
--set trimout on 
--set pagesize 0 ;
select object_type || ' = ' || owner || '.' ||  object_name as ${db_nm}
from sys.all_objects
where object_name = upper('${db_obj_nm}') order by 1 ;
exit ;
SQLMX
		if [ $? -ne 0 ]; then
			
			echo -e $COLOR_RED"\nERR: ["$db_nm"] could not connect \n"$COLOR_NONE ; exit 10
		fi 
	else
		echo -e $COLOR_RED"\nERR: ["$db_nm"] not found in TNS file \n"$COLOR_NONE ; exit 20
	fi
done
echo -e $COLOR_NONE" "

# set linesize 32000 pagesize 40000 long 32000 serveroutput on size 32000 ;
# set echo off feed off feedback off heading off term off verify off ;
# set timing off trimspool off trimout on ;
