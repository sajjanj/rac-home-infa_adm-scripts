#!/bin/bash

# NAME   :ca-bundle-break.sh
# USAGE  :./ca-bundle-break.sh (or) ~/scripts/ca-bundle-break.sh
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script breaks down the CA-BUNDLE.CRT file into seperate CRT files at $DIR_CA_BUNDLE_BREAK
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Splitting certificte file CA-BUNDLE.CRT"
IFS=$'\n'
dir_cert_break=~/.ssh/ca-bundle-break/
begin_cert='BEGIN CERTIFICATE'
end_cert='END CERTIFICATE'
skip_line='CERTIFICATE'
dash="-----"
cert_ctr=0
line_num=0

echo -e $COLOR_CYAN"\nINFO: Start Time = "`date`$COLOR_NONE
cd $INFA_HOME/server/bin
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Folder ["$INFA_HOME/server/bin" not found"$COLOR_NONE
	exit 10
fi

echo -e $COLOR_CYAN"INFO: Number of CA-BUNDLE entries = "`cat ./ca-bundle.crt|grep BEGIN|wc -l`"\n"
for ln in `cat ./ca-bundle.crt`; do
	bcc=`echo $ln|grep $begin_cert|wc -l`
	slc=`echo $ln|grep $skip_line|wc -l`
	ecc=`echo $ln|grep $end_cert|wc -l`
	if [ $bcc -eq 1 ]; then
		flag=1
		let cert_ctr=cert_ctr+1
		touch ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"ERR: Could not create file "${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt $COLOR_NONE
			exit 20
		fi
		echo "  > CREATING "${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
		# echo "-----BEGIN CERTIFICATE-----" >> ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
		echo ${dash}${begin_cert}${dash} >> ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
	fi
	if [[ $flag -eq 1 ]] && [[ $slc -eq 0 ]] && [[ $bcc -eq 0 ]] && [[ $ecc -eq 0 ]] ; then
		echo $ln >> ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
	fi
	if [ $ecc -eq 1 ]; then
		flag=0
		# echo "-----END CERTIFICATE-----" >> ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
		echo ${dash}${end_cert}${dash} >> ${dir_cert_break}/ca-bundle-break-${cert_ctr}.crt
	fi
done
echo -e "\nINFO: Completion Time = "`date`"\n"$COLOR_NONE
