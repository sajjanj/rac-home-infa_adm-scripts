#!/bin/bash

# NAME   :ad_cleanup.sh
# USAGE  :./ad_cleanup.sh (or) ~/scripts/ad_cleanup.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script cleans up the files at $ADZIP in all active INFA hosts
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Cleaning up ZIP files in all INFA hosts from folder "$ADZIP
echo -e $COLOR_CYAN" "
for hostnm in `cat $HOSTLST`; do
	localhostnm=`hostname|tr a-z A-Z`
	echo " > Cleaning AD ZIP files in "$hostnm
	if [ $localhostnm == $hostnm ]; then
		cd $ADZIP; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst
	else
		ssh -q infa_adm@${hostnm} 'source ~/.ev_path; cd $ADZIP; filecnt=`ls|grep zip|wc -l`; [ $filecnt -gt 0 ] && rm -f ./*.zip ./*.txt ./*.lst || echo " >> no files"'
	fi
done
echo -e $COLOR_NONE" "

exit 0

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at D5 "$COLOR_NONE
# cd /apps/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at D6 "$COLOR_NONE
# ssh -q infa_adm@dhvifoapp06 'cd /apps/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at Q5 "$COLOR_NONE
# ssh -q infa_adm@qhvifoapp05 'cd /apps/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at Q6 "$COLOR_NONE
# ssh -q infa_adm@qhvifoapp06 'cd /apps/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at U3 "$COLOR_NONE
# ssh -q infa_adm@uhvifoapp03 'cd /u01/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at U4 "$COLOR_NONE
# ssh -q infa_adm@uhvifoapp04 'cd /u01/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at P4 "$COLOR_NONE
# ssh -q infa_adm@phvifoapp04 'cd /u01/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? 

# echo -e $COLOR_CYAN"\nINF: Cleaning AV files at P5 "$COLOR_NONE
# ssh -q infa_adm@phvifoapp05 'cd /u01/informatica/sj_ad_files; rm -f ./*.zip; rm -f ./*.txt; rm -f ./*.lst'
# echo -e $COLOR_GREEN" > Status ="$COLOR_NONE $? "\n"
