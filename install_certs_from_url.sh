#!/bin/bash

# NAME   :install_certs_from_url.sh
# USAGE  :./install_certs_from_url.sh <URL without http or https>
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :This script fetches the SSL certificates from a URL in PEM format
# AUTHOR :Sajjan Janardhanan 01/25/2019

. ~/.bash_profile
func_header "SSL certificate download utility"
IFS=$'\n'
now=`date +%Y%m%d%H%M%S`
begin_cert='BEGIN CERTIFICATE'
end_cert='END CERTIFICATE'
skip_line='CERTIFICATE'
dash="-----"
cert_ctr=0
line_num=0
dir_work=~/.ssh/fetch_certs_url/
file_raw_certs=$dir_work"raw_pem_certs.txt"

if [ $# -ne 1 ]; then
	echo -e $COLOR_RED"ERR: Insufficient or too many parameters"$COLOR_NONE
	exit 10
else
	i_url=$1
fi
echo -e $COLOR_GREEN
echo "dummy"|openssl s_client -showcerts -connect "${i_url}:443" > $file_raw_certs
echo -e $COLOR_NONE
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Could not fetch the SSL certificates from the givel URL"$COLOR_NONE
	exit 20
fi
cnt_certs=`cat $file_raw_certs|grep "BEGIN"|wc -l`
if [ $? -ne 0 ]; then
	echo -e $COLOR_RED"ERR: Could not fetch certificate count from file [ "$file_raw_certs"]"$COLOR_NONE
	exit 30
elif [ ! $cnt_certs -gt 0 ]; then 
	echo -e $COLOR_RED"ERR: Certificate count is ZERO in the file [ "$file_raw_certs"]"$COLOR_NONE
	exit 40
else
	echo -e $COLOR_CYAN"INF: Number of entries in the certificate chain ["$cnt_certs"]"$COLOR_NONE
	for ln in `cat $file_raw_certs`; do
		bcc=`echo $ln|grep $begin_cert|wc -l`
		slc=`echo $ln|grep $skip_line|wc -l`
		ecc=`echo $ln|grep $end_cert|wc -l`
		if [ $bcc -eq 1 ]; then
			flag=1
			let cert_ctr=cert_ctr+1
			file_cert=${dir_work}"/fcu_"${now}_${cert_ctr}".crt"
			touch $file_cert
			if [ $? -ne 0 ]; then
				echo -e $COLOR_RED"ERR: Could not create file ["$file_cert"]"$COLOR_NONE
				exit 50
			fi
			echo -e $COLOR_CYAN"INF: Creating ["$file_cert"]"$COLOR_NONE
			echo ${dash}${begin_cert}${dash} >> $file_cert
		elif [[ $flag -eq 1 ]] && [[ $slc -eq 0 ]] && [[ $bcc -eq 0 ]] && [[ $ecc -eq 0 ]] ; then
			echo $ln >> $file_cert
		elif [ $ecc -eq 1 ]; then
			flag=0
			echo ${dash}${end_cert}${dash} >> $file_cert
		fi
	done
fi
cd $dir_work
for fn in `ls -1 fcu_${now}*.crt`; do
	~/scripts/formatcert.sh $fn
done
