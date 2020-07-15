#!/bin/bash

# NAME   :show_crontab.sh 
# USAGE  :./show_crontab.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Lists crontab settings in all active INFA hosts
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Listing CRONTAB settings in all active INFA hosts"
enabled_command='crontab -l|grep ".sh"|grep -v grep|grep -v "#"|sort|grep -v "\n\n"'
disabled_command='crontab -l|grep ".sh"|grep -v grep|grep "#"|sort|grep -v "\n\n"'

func_ssh()
{
	param_value=$1
	if [ $param_value != `hostname` ]; then 
		echo -e ${COLOR_YELLOW}"\n"$param_value" (enabled) "${COLOR_CYAN} ; ssh -q $param_value ${enabled_command}
		echo -e ${COLOR_YELLOW}$param_value" (disabled) "${COLOR_CYAN}    ; ssh -q $param_value ${disabled_command}
	else
		echo -e ${COLOR_YELLOW}"\n"$param_value" (enabled) "${COLOR_CYAN} ; ${enabled_command}
		echo -e ${COLOR_YELLOW}$param_value" (disabled) "${COLOR_CYAN}    ; ${disabled_command}
	fi 
}

func_ssh DHVIFOAPP05
func_ssh DHVIFOAPP06
func_ssh QHVIFOAPP05
func_ssh QHVIFOAPP06
func_ssh UHVIFOAPP03
func_ssh UHVIFOAPP04
func_ssh PHVIFOAPP04
func_ssh PHVIFOAPP05

echo -e $COLOR_NONE" "
