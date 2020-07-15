#!/bin/bash

# NAME   :ad_deploy2all.sh
# USAGE  :./ad_deploy2all.sh 
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Copies the AD ZIP files from $ADZIP to all active INFA hosts
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
script_nm=`basename $0`
func_subheader "Copying AV ZIP files to other active INFA hosts"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG
echo -e $COLOR_CYAN"\nINF: $0 started at "`date`"\n"$COLOR_NONE

for hostnm in `cat $HOSTLST`; do
	localhostnm=`hostname|tr a-z A-Z`
	if [ $localhostnm == $hostnm ]; then
		echo -e $COLOR_CYAN" > Skipping "$hostnm" "$COLOR_NONE
	else
		echo -e $COLOR_CYAN" > Copying files to ["$hostnm"]"$COLOR_NONE
		scp -q $ADZIP/*.zip ${hostnm}:${ADZIP}
		if [ $? -ne 0 ]; then 
			echo -e $COLOR_RED"ERR: Could not copy files to "$hostnm"\n"$COLOR_NONE; exit 100
		fi
	fi
done
echo -e $COLOR_NONE" "

# cd /apps/informatica/sj_ad_files
# echo -e $COLOR_CYAN"INF: Copying files to D4 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip dhvifoapp06:/apps/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"D06"$COLOR_NONE; exit 200
# fi

# echo -e $COLOR_CYAN"INF: Copying files to Q5 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip qhvifoapp05:/apps/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"Q05"$COLOR_NONE; exit 210
# fi

# echo -e $COLOR_CYAN"INF: Copying files to Q6 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip qhvifoapp06:/apps/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"Q06"$COLOR_NONE; exit 220
# fi

# echo -e $COLOR_CYAN"INF: Copying files to U3 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip uhvifoapp03:/u01/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"U03"$COLOR_NONE; exit 230
# fi

# echo -e $COLOR_CYAN"INF: Copying files to U4 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip uhvifoapp04:/u01/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"U04"$COLOR_NONE; exit 240
# fi

# echo -e $COLOR_CYAN"INF: Copying files to P4 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip phvifoapp04:/u01/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"P04"$COLOR_NONE; exit 250
# fi

# echo -e $COLOR_CYAN"INF: Copying files to P5 at "`date +%Y%m%d_%H%M%S` $COLOR_NONE
# scp -q ./*.zip phvifoapp05:/u01/informatica/sj_ad_files
# if [ $? -ne 0 ]; then 
	# echo -e $COLOR_RED $errmsg"P05"$COLOR_NONE; exit 260
# fi

echo -e $COLOR_CYAN"INF: $0 completed at "`date` $COLOR_NONE
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG
