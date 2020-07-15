#!/bin/bash

# NAME   :ssh_broadcast.sh 
# USAGE  :./ssh_broadcast.sh <Command>
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :Executes OS level commands in all active INFA hosts; ***USE WITH CARE***
# AUTHOR :Sajjan Janardhanan 12/11/2017

. ~/.bash_profile
func_header "Performing a Shell Command broadcast on Active INFA hosts"

func_cmd()
{
	server=$1
	cmd=$2
	echo -e $server" --> "
	ssh -q infa_adm@$server $cmd 
	echo -e "\n---------------------------------------------------------------------"
}

if [ $# -ne 2 ]; then 
	echo -e $COLOR_RED"ERR: Insufficient or Too many arguments"$COLOR_NONE
else
	command=$1 ; node=$2
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG
	if [[ $node -eq 1 ]] || [[ $node -eq 0 ]]; then
		echo -e $COLOR_CYAN
		func_cmd DHVIFOAPP05 "$command"
		func_cmd QHVIFOAPP05 "$command"
		func_cmd UHVIFOAPP03 "$command"
		func_cmd PHVIFOAPP04 "$command"
	fi	
	if [[ $node -eq 2 ]] || [[ $node -eq 0 ]]; then
		echo -e $COLOR_GREEN
		func_cmd DHVIFOAPP06 "$command"
		func_cmd QHVIFOAPP06 "$command"
		func_cmd UHVIFOAPP04 "$command"
		func_cmd PHVIFOAPP05 "$command"
	fi
	if ! [[ $node =~ (1|2|0)$ ]]; then
		echo -e $COLOR_RED"\nERR: Invalid node parameter\n"$COLOR_NONE
	fi
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG
fi 
echo -e $COLOR_NONE
