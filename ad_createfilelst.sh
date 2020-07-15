#!/bin/bash

# NAME   :ad_createfilelst.sh
# USAGE  :./ad_createfilelst.sh (or) ~/scripts/ad_createfilelst.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script creates a list file for ZIP files under $ADZIP (NOT used in ad_deploy2all.sh anymore)
# TAGS   :ad,av,address doctor,address verification
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
script_nm=`basename $0`
func_header "Creating Address Doctor list file "$ADZIPLST

echo -e $COLOR_CYAN" "
rm -f $ADZIPLST
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Could not cleanup LST file $ADZIPLST \n"$COLOR_NONE ; exit 100
else
	echo "*** 1 ***"
fi

cd $ADZIP
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Invalid directory $ADZIP \n"$COLOR_NONE ; exit 110
else
	echo "*** 2 ***"
	zip_file_cnt=`ls|grep zip|wc -l`
	echo "*** 3 ***"
	if [ $zip_file_cnt -eq 0 ]; then
		echo -e $COLOR_RED"ERR: ZIP files not found in $ADZIP \n"$COLOR_NONE ; exit 120
	else
		echo "*** 4 ***"
		for zip_file_nm in `ls -1 *.zip`; do
		  echo $zip_file_nm"|${ADZIP}|${ADZIP}" >> $ADZIPLST
		  if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: Could not create the LST file $ADZIPLST \n"$COLOR_NONE ; exit 130
		  else
		    echo "*** 5 ***"
		  fi
		done
		echo -e $COLOR_CYAN"INF: ZIP file count in the LST file [$ADZIPLST] = "`wc -l $file_lst|cut -d " " -f1` $COLOR_NONE
		echo -e $COLOR_GREEN" " 
		cat $ADZIPLST  
	fi
fi
echo -e $COLOR_NONE" "

