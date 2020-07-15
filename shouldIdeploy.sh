#!/bin/bash

# NAME   :shouldIdeploy.sh
# USAGE  :./shouldIdeploy.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :Check if a script should be deployed to higher environments
# AUTHOR :Sajjan Janardhanan 

. ~/.bash_profile
func_header "Should I Deploy the script"
IFS=$'\n'
file_deploy=~/scripts/log/shouldIdeploy.lst
echo -e $COLOR_PURPLE"\nQST: Clear screen for every file (Y/n) ? \c"; read clear_yn

if [ -f $file_deploy ]; then
	rm -f $file_deploy
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"ERR: Deploy file not found"$COLOR_NONE               ; exit 10
	fi
else
	echo -e "\n\nLIST OF FILES DEPLOYED ON ["`date +%Y%m%d_%H:%M:%S`"] USING "$0 > $file_deploy
fi

cd ~/scripts
for file_nm in `ls -1 *.sh|grep -vE "^x_|$0"|sort`; do
	
	func_subheader "Processing file "$file_nm
	~/scripts/ssh_broadcast.sh 'ls -l ~/scripts/'$file_nm 0
	echo -e $COLOR_PURPLE"\nQST: DEPLOY (Y/n) ? \c"$COLOR_NONE ; read yn
	
	if [ $yn == "Y" ]; then
		
		echo -e $COLOR_CYAN"INF: Copying to QA "$COLOR_NONE
		scp -q ./$file_nm QHVIFOAPP05:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to Q05 ended in failure"$COLOR_NONE     ; exit 20
		fi
		scp -q ./$file_nm QHVIFOAPP06:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to Q06 ended in failure"$COLOR_NONE     ; exit 30
		fi
		
		echo -e $COLOR_CYAN"INF: Copying to UAT"$COLOR_NONE
		scp -q ./$file_nm UHVIFOAPP03:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to U03 ended in failure"$COLOR_NONE     ; exit 40
		fi
		scp -q ./$file_nm UHVIFOAPP04:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to U04 ended in failure"$COLOR_NONE     ; exit 50
		fi
		
		echo -e $COLOR_CYAN"INF: Copying to PROD"$COLOR_NONE
		scp -q ./$file_nm PHVIFOAPP04:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to P04 ended in failure"$COLOR_NONE     ; exit 60
		fi
		scp -q ./$file_nm PHVIFOAPP05:~/scripts
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: SCP to P05 ended in failure"$COLOR_NONE     ; exit 70
		fi
		
		echo ; echo $file_nm >> $file_deploy
	fi
	
	if [ $clear_yn == "Y" ]; then
		clear
	fi
done

cat $file_deploy

