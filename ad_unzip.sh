#!/bin/bash

# NAME   :ad_unzip.sh
# USAGE  :./ad_unzip.sh (or) ~/scripts/ad_unzip.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :Extracts ZIP files under $ADZIP and moves them to the AD content folder
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
adunzip_log=~/scripts/log/ad_unzip.log
func_subheader "Processing ZIP files in host ["`hostname`"] at "`date +%Y%m%d_%H%M%S`
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG
{
	rm -f $adunzip_log
	echo "INF: $0 started at "`date`
	cd $ADZIP
	for filenm in `ls *.zip`; do
		echo " > extracting [ $fn ]"
		unzip -o $filenm
		if [ $? -ne 0 ]; then
			echo "ERR: Extraction error @ "$filenm; exit 100
		fi
	done
	touch *.MD
	touch *.zip
	mv *.MD $INFA_HOME/services/DQContent/INFA_Content/av/default
	if [ $? -ne 0 ]; then
		echo "ERR: Error occured while moving files to AV Content folder"; exit 200
	fi
	echo "INF: $0 completed at "`date`
} > $adunzip_log 2>&1

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG
