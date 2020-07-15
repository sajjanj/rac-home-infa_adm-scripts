#!/bin/bash
# Script Name = infaprocesstracker.sh
# Description = This script can be used to monitor the processes as you startup or shutdown INFA
# Parameters  = This script uses 1 parameter - 1 for startup and 0 for shutdown

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG

func_svccnt()
{
	# param_func=$1 ; param_display=$2
	# [ $param_display -eq 1 ] && echo -e "  --> $param_func = \c"; ps -ef|grep -iE "java|informatica"|grep -i $param_func|grep -v grep|wc -l
	svccnt=`ps -ef|grep -iE "java|informatica"|grep -i $param_func|grep -v grep|wc -l`
	touch touch ${param_func}.prc
	if [ $svccnt -gt 0 ]; then
		touch ${param_func}.prcr
	fi
}

{
	rm -f /infa_shared/Temp/*.prc
	rm -f /infa_shared/Temp/*.prcr

	infasvccnt=`ps -ef|grep -iE "java|informatica"|grep -v grep|wc -l`
	if [ $# -ne 1 ]; then
	  echo -e "\nERR: Too many or Insufficient Parameters\n"; exit 1
	fi

	param=$1

	echo -e "\nINF: Input Parameter = ${param} \n"
	if [ $param -eq 0 ]; then
		func_svccnt ISPTomcatBootstrap 1 ; [ $v_svccnt -eq 1 ] && svc_tomcat=1 || svc_tomcat=0
		func_svccnt AdministratorConsole 1 ; [ $v_svccnt -eq 1 ] && svc_ac=1 || svc_ac=0
		func_svccnt AnalystService 1 ; [ $v_svccnt -eq 1 ] && svc_as=1 || svc_as=0
		func_svccnt ContentManagementService 1 ; [ $v_svccnt -eq 1 ] && svc_cms=1 || svc_cms=0
		func_svccnt DataIntegrationService 1 ; [ $v_svccnt -eq 1 ] && svc_dis=1 || svc_dis=0
		func_svccnt MetadataManagerService 1 ; [ $v_svccnt -eq 1 ] && svc_mms=1 || svc_mms=0
		func_svccnt ModelRepositoryService 1 ; [ $v_svccnt -eq 1 ] && svc_mrs=1 || svc_mrs=0
		func_svccnt OutProcessCacheServiceStarter 1 ; [ $v_svccnt -eq 1 ] && svc_cache=1 || svc_cache=0
		func_svccnt PMserver 1 ; [ $v_svccnt -eq 1 ] && svc_pmserver=1 || svc_pmserver=0
		func_svccnt ReportingandDashboardsService 1 ; [ $v_svccnt -eq 1 ] && svc_rd=1 || svc_rd=0
		func_svccnt RepAgent 1 ; [ $v_svccnt -eq 1 ] && svc_repagent=1 || svc_repagent=0
		func_svccnt ResourceManager 1 ; [ $v_svccnt -eq 1 ] && svc_resmgr=1 || svc_resmgr=0
		func_svccnt SchedulerService 1 ; [ $v_svccnt -eq 1 ] && svc_sch=1 || svc_sch=0
		func_svccnt WebServiceHub 1 ; [ $v_svccnt -eq 1 ] && svc_wsh=1 || svc_wsh=0
		while [ 1 -eq 1 ]; do
			[ $svc_tomcat -eq 1 ] && func_svccnt ISPTomcatBootstrap 0 ; [ $svc_tomcat -eq 0 ] && echo -e "INF: ISPTomcatBootstrap is now unavailable"
			[ $svc_ac -eq 1 ] && func_svccnt AdministratorConsole 0 ; [ $svc_ac -eq 0 ] && echo -e "INF: AdministratorConsole is now unavailable"
			[ $svc_ac -eq 1 ] && func_svccnt AdministratorConsole 0 ; [ $svc_ac -eq 0 ] && echo -e "INF: AdministratorConsole is now unavailable"
			[ $svc_as=1 func_svccnt AnalystService 0 ; |grep -v grep|wc -l ; 
			[ $svc_cms=1 func_svccnt ContentManagementService 0 ; |grep -v grep|wc -l ; 
			[ $svc_dis=1 func_svccnt DataIntegrationService 0 ; |grep -v grep|wc -l ;
			[ $svc_mms=1 func_svccnt MetadataManagerService 0 ; |grep -v grep|wc -l ; 
			[ $svc_mrs=1 func_svccnt ModelRepositoryService 0 ; |grep -v grep|wc -l ; 
			[ $svc_cache=1 func_svccnt OutProcessCacheServiceStarter 0 ; |grep -v grep|wc -l ; 
			[ svc_pmserver=1 func_svccnt pmserver 0 ; |grep -v grep|wc -l ; 
			[ svc_rd=1 func_svccnt ReportingandDashboardsService 0 ; |grep -v grep|wc -l ; 
			[ svc_repagent=1 func_svccnt RepAgent 0 ; |grep -v grep|wc -l ; 
			[ svc_resmgr=1 func_svccnt ResourceManager 0 ; |grep -v grep|wc -l ; 
			[ svc_sch=1 func_svccnt SchedulerService 0 ; |grep -v grep|wc -l ; 
			[ svc_wsh=1 func_svccnt WebServiceHub 0 ; |grep -v grep|wc -l ;
		done
		
	elif [ $param -eq 1 ]; then
		echo "UC"
	else
		echo -e "\nERR: Invalid Parameter\n"; exit 2
	fi
}
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG