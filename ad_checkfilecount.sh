#!/bin/bash

# NAME   :ad_checkfilecount.sh
# USAGE  :./ad_checkfilecount.sh (or) ~/scripts/ad_checkfilecount.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script lists the number of ZIP files at $ADZIP in all active INFA hosts
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_subheader "Number of ZIP files waiting to be processed in all active INFA hosts"
echo -e $COLOR_CYAN" "
for hostnm in `cat $HOSTLST`; do
	localhostnm=`hostname|tr a-z A-Z`
	if [ $localhostnm == $hostnm ]; then
		echo " > ZIP file count @ "$hostnm" = "`cd $ADZIP ; ls -1|grep -i zip | grep -v sh | grep -v log | wc -l`
	else
		echo -e " > ZIP file count @ "$hostnm" = \c"
		ssh -q infa_adm@${hostnm} 'source ~/.ev_path ; cd $ADZIP ; ls -1|grep -i zip | grep -v sh | grep -v log | wc -l'
	fi
done
echo -e $COLOR_NONE" "

# ssh -q infa_adm@dhvifoapp06 'source ~/.ev_path ; cd $ADZIP ; echo " > ZIP file count @ D6 = "`ls -1|grep -i zip | grep -v sh | grep -v log | wc -l`'
