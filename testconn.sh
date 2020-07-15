#!/bin/bash

# NAME   :testconn.sh 
# USAGE  :./testconn.sh <connection_name>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Powercenter Connection Test Utility
# AUTHOR :Sajjan Janardhanan 03/16/2016

. ~/.bash_profile
func_header "Powercenter Connection Test Utility"

if [ $# -ne 2 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE ; exit 10
fi

file_param="$INFA_SHARED/BWParam/wf_TestConnection.par"
db_mysql="mysql"
db_orcl="oracle"
db_sqlsrvr="sqlserver"
db_pgsql="pgsql"
app_http="http"
conn_name=$1 ; conn_type=$2

if [[ ! $conn_type == @($db_orcl|$db_sqlsrvr|$db_pgsql|$db_mysql) ]]; then
	echo -e $COLOR_RED"\nERR: Invalid connection type parameter; valid values = ("$db_orcl","$db_sqlsrvr","$db_pgsql","$db_mysql") \n"$COLOR_NONE ; exit 20
fi

echo -e $COLOR_CYAN"INF: Connection being tested = "$conn_name' @ '$conn_type" [pid="$$"]"
echo "[Global]" >$file_param
echo '$$APP_HTTP='${app_http} >>$file_param
echo '$$DB_MYSQL='${db_mysql} >>$file_param
echo '$$DB_ORCL='${db_orcl} >>$file_param
echo '$$DB_PGSQL='${db_pgsql} >>$file_param
echo '$$DB_SQLSRVR='${db_sqlsrvr} >>$file_param
echo '$DBConnectionSRC='${conn_name} >>$file_param
echo '$$TYPE='${conn_type} >>$file_param

cd $INFA_HOME/server/bin
./pmcmd startworkflow -d $INFASVC_DOM -sv $INFASVC_INT -u $INFA_PMUSER -pv INFA_PMPASS -f Miscellaneous -wait wf_TestConnection | grep -E "Informatica|Invoked" 
stts=`./pmcmd getworkflowdetails -d $INFASVC_DOM -u $INFA_DEFAULT_USER -pv INFA_DEFAULT_DOMAIN_PASSWORD -usd Native -sv $INFASVC_INT -f Miscellaneous wf_TestConnection |grep -i "WORKFLOW RUN STATUS"|grep -i SUCCEEDED|wc -l`
if [ $stts -eq 0 ]; then
	echo -e $COLOR_RED
	cat $INFA_SHARED/WorkflowLogs/wf_TestConnection.log|grep -i error; echo " "
	cat $INFA_SHARED/SessLogs/s_m_TestConnection.log|grep -iE "ora|error"; echo " "
	echo -e "ERR: Connection Failed "
else
	echo -e "INF: Connection Succeeded "
fi
echo -e $COLOR_NONE
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG

