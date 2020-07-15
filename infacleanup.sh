#!/bin/bash

# NAME   :infacleanup.sh
# USAGE  :./infacleanup.sh
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :INFA tomcat & services cleanup utility
# AUTHOR :Sajjan Janardhanan 04/23/2018

. ~/.bash_profile
func_header "INFA Tomcat & Services Cleanup Utility"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG

lst_file_nm=$HOME"/scripts/infacleanup.lst"
infa_process_cnt=`ps -ef|grep -iE "informatica|java"|grep -v grep|wc -l`
if [ $infa_process_cnt -gt 0 ]; then
	echo -e "\nERR: Informatica services are still running; Aborting script. \n "
	exit 1
fi

for fn in `cat ${lst_file_nm}|grep -v "#"`; do
	echo -e "\n-*-*- < "$fn" > -*-*-"
	if [ -d $fn ]; then
		cd $fn 
		yn=""
		echo -e "PWD = [ "`pwd`" ] \n"
		ls -lrt
		[ `find . -maxdepth 1 -type f -name "*war"|wc -l` -gt 0 ] && war_file_cnt=$(ls *.war|wc -l) || war_file_cnt=0
		if [ $war_file_cnt -gt 0 ]; then
			echo -e "\n > "$war_file_cnt" WAR files; The corresponding folders will be deleted. Proceed (y/n)? \c";read yn
			if [ $yn == 'y' ] || [ $yn == 'Y' ]; then
				for warfn in *.war; do
					dnm=$(echo $warfn|cut -d "." -f1)
					if [ -d $dnm ]; then
						echo "  + Deleting folder - "$dnm
						rm -Rf ./$dnm
					else
						echo "  + Missing  folder - "$dnm
					fi
					sleep 1
				done
			else
				echo "  + Skipping folder "
			fi
		else
			echo -e "\n > This folder contains no WAR files; All files will be deleted. Proceed (y/n)? \c"; read yn
			if [ $yn == 'y' ] || [ $yn == 'Y' ]; then
				for filenm in ./* ; do
					echo "  + Deleting file/folder - "$filenm
					rm -Rf ./$filenm
					sleep 1
				done
			else
				echo "  + Skipping folder - "$dnm
			fi
		fi
	else
		echo "ERR: Invalid Directory - "$fn
	fi
done
echo -e "\nINF: Cleanup complete \n"
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG
