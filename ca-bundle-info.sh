#!/bin/bash

# NAME   :ca-bundle-info.sh
# USAGE  :./ca-bundle-info.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :Provides info on every PEM certificate extracted from the CA-BUNDLE.CRT file by ca-bundle-break.sh
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Getting info on PEM certificates extracted from the CA-BUNDLE.CRT file"

echo -e $COLOR_CYAN"\nINFO: Start Time = "`date` $COLOR_NONE
dir_cert_break=~/.ssh/ca-bundle-break/
file_cert_info_bundle=$dir_cert_break"/ca-bundle-info.txt"

cd $dir_cert_break
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Folder ["$dir_cert_break"] not found"
	exit 10
fi

rm -f $file_cert_info_bundle
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: File ["$file_cert_info_bundle"] could not be deleted"
	exit 20
fi

echo "CA-BUNDLE started at = "`date`"\n" > $file_cert_info_bundle

for fn in `ls -rt *.crt`; do
  echo -e $COLOR_CYAN" > processing file [ "$fn" ]"$COLOR_NONE
  $HOME/scripts/showcertinfo.sh ./$fn >> $file_cert_info_bundle
done

echo "CA-BUNDLE completed at = "`date` >> $file_cert_info_bundle
echo -e $COLOR_CYAN"INFO: Certificate info available in ["$file_cert_info_bundle"]\n"$COLOR_NONE
echo -e $COLOR_CYAN"INFO: Completion Time = "`date`"\n"$COLOR_NONE 
