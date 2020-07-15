#!/bin/bash

# NAME   :ad_unzip_all.sh
# USAGE  :./ad_unzip_all.sh (or) ~/scripts/ad_unzip_all.sh
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Calls the ad_unzip.sh script in all active INFA hosts
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
clear
func_header "ADUNZIP wrapper"
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>> $MASTER_LOG
echo -e $COLOR_CYAN"\nINF: $0 started at "`date`"\n"$COLOR_NONE

qst=""
echo -e $COLOR_GREEN"QST: Proceed/Skip to copy ZIP files to other active INFA hosts ? (p/s) "$COLOR_NONE"\c"; read qst
if [ $qst == "p" ]; then
    ~/scripts/ad_deploy2all.sh
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"ERR @ ad_deploy2all.sh"$COLOR_NONE; exit 20
	fi
elif [ $qst == "s" ]; then
    echo -e $COLOR_CYAN" > Skipped step"$COLOR_NONE
else 
	echo -e $COLOR_RED" > Invalid entry"$COLOR_NONE; exit 25
fi

~/scripts/ad_checkfilecount.sh
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR @ ad_checkfilecount.sh"$COLOR_NONE; exit 30
fi

qst=""
echo -e $COLOR_GREEN"QST: Proceed with ZIP extraction ? (p/s) "$COLOR_NONE"\c"; read qst
if [ $qst == "p" ]; then
    ~/scripts/ad_unzip.sh
	ssh -q infa_adm@dhvifoapp06 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@qhvifoapp05 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@qhvifoapp06 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@uhvifoapp03 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@uhvifoapp04 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@phvifoapp04 '~/scripts/ad_unzip.sh'
    ssh -q infa_adm@phvifoapp05 '~/scripts/ad_unzip.sh'
else
    echo -e $COLOR_CYAN" > Skipped step"$COLOR_NONE
fi 

echo -e $COLOR_CYAN"\nINF: $0 completed at "`date`"\n"$COLOR_NONE
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG

# qst=""
# echo -e $COLOR_GREEN"\nQST: Proceed/Skip with file list creation ? (p/s) "$COLOR_NONE"\c"; read qst
# if [ $qst == "p" ]; then
	# ~/scripts/ad_createfilelst.sh
	# if [ $? -ne 0 ]; then
		# echo -e $COLOR_RED"ERR @ ad_createfilelst.sh"$COLOR_NONE; exit 10
	# fi
# elif [ $qst == "s" ]; then
    # echo -e $COLOR_CYAN" > Skipped step"$COLOR_NONE
# else 
	# echo -e $COLOR_RED" > Invalid entry"$COLOR_NONE; exit 15
# fi
