#!/bin/bash

# NAME   :ipl.sh 
# USAGE  :./ipl.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :INFA Process List with PIDs
# AUTHOR :Sajjan Janardhanan 11/15/2018

. ~/.bash_profile
func_header "INFA Process List"

func_print()
{
  svc_alias=$1 ; svc_nm=$2
  proc_cnt=0; proc_cnt=$(ps -ef|grep -iE "java|informatica"|grep -iE "${svc_nm}"|grep -v grep|wc -l)
  if [ $proc_cnt -ne 0 ]; then
	for proc_id in `ps -ef|grep -iE "java|informatica"|grep -iE "$svc_nm"|grep -v grep|awk -F" " '{ print $2 }'`; do
		echo -e $COLOR_CYAN"  "$proc_id" | "$svc_alias" ( "$svc_nm" ) "$COLOR_NONE
	done
    # printf '%10s | ' `ps -ef|grep -iE "java|informatica"|grep -iE "$svc_nm"|grep -v grep|awk -F" " '{ print $2 }'`	; echo "$svc_alias ( $svc_nm ) "
  else 
    # printf '%10s | ' "****" ; echo "$svc_alias ( $svc_nm ) "
	echo -e $COLOR_CYAN"  **** | $svc_alias ( $svc_nm ) "$COLOR_NONE
  fi
}

func_print 'Admin Console' 'AdministratorConsole'
func_print 'Analyst' 'AnalystService'
func_print 'Content Management' 'ContentManagementService'
func_print 'Data Integration' 'DataIntegrationService'
func_print 'Email Service' 'Email'
func_print 'Metadata Manager' 'MetadataManagerService'
func_print 'Model Service' 'ModelRepositoryService'
func_print 'Out Process Cache ServiceStarter' 'OutProcessCacheServiceStarter'
func_print 'PM Server' 'pmserver'
func_print 'Reporting and Dashboard' 'ReportingandDashboardsService'
func_print 'Repository Agent' 'repagent'
func_print 'Resource Manager' 'resourcemanager'
func_print 'Scheduler Service' 'SchedulerService'
func_print 'Tomcat' 'ISPTomcatBootstrap|masterUpdateTimeInterval'
func_print 'Web Service Hub' 'WebServiceHub'
echo
