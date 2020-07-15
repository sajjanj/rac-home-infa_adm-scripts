#!/bin/bash

# NAME   :formatcert.sh
# USAGE  :./formatcert.sh <PEM_File_Absolute_Path>
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :This script formats PEM certificate entries with header information
# AUTHOR :Sajjan Janardhanan 10/22/2018

. ~/.bash_profile
func_header "PEM Certificate Formatter for System Keystore file"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG
str_info_file_nm="./formatcert.info"

if [ $# -ne 1 ]; then
	echo -e $COLOR_RED"ERR: Insufficient or too many parameters"$COLOR_NONE
	exit 10
elif [ ! -f $1 ]; then
	echo -e $COLOR_RED"ERR: Could not locate input file"$COLOR_NONE
	exit 20
else
	str_cer_file=$1
fi

if [ -f $str_info_file_nm ]; then
	echo -e $COLOR_CYAN"INFO file contents:"$COLOR_NONE
	cat $str_info_file_nm
	echo -e $COLOR_CYAN"\nQ: Reuse the info file (Y/N) ? \c"$COLOR_NONE
	read yn_info
else
	yn_info="n"
fi

if [ $yn_info == "y" ] || [ $yn_info == "Y" ]; then
	echo -e $COLOR_CYAN"\nINF: Reusing INFO file"$COLOR_NONE
else
	echo -e $COLOR_CYAN"\nINF: Recreating INFO file"$COLOR_NONE
	echo -e $COLOR_CYAN" > Requestor Name? \c"$COLOR_NONE ; read str_req_nm
	echo -e $COLOR_CYAN" > Project Name? \c"$COLOR_NONE   ; read str_proj_nm
	echo -e $COLOR_CYAN" > Administrator Name? \c"$COLOR_NONE ; read str_adm_nm
	echo -e $COLOR_CYAN" > Added Date? \c "$COLOR_NONE ; read str_date
	echo "  Requested by     : "$str_req_nm > $str_info_file_nm
	echo "  Project          : "$str_proj_nm >> $str_info_file_nm
	echo "  Added by         : "$str_adm_nm >> $str_info_file_nm
	echo "  Added date       : "$str_date >> $str_info_file_nm
fi

echo -e $COLOR_WHITE"\nEntries for the CA Certs Bundle file is listed below ===>>>\n"$COLOR_CYAN
echo "================================================================"
openssl x509 -noout -subject -in $str_cer_file |cut -d"=" -f4-8
echo "================================================================"
echo -e "  Issuer           : \c"
openssl x509 -noout -issuer -in $str_cer_file|cut -d"=" -f4-8
echo -e "  Effective Date   : \c"
openssl x509 -noout -startdate -in $str_cer_file|cut -d"=" -f2
echo -e "  Expiration Date  : \c"
openssl x509 -noout -enddate -in $str_cer_file|cut -d"=" -f2
echo -e "  Signature Alg    :\c"
openssl x509 -in $str_cer_file -noout -text|grep "Signature Algorithm"|cut -d":" -f2|uniq
echo -e "  Serial Number    : \c"
openssl x509 -serial -noout -in $str_cer_file|cut -d"=" -f2
echo -e "  SHA1 fingerprint : \c"
openssl x509 -fingerprint -noout -in "$str_cer_file" -sha1|cut -d"=" -f2
echo -e "  MD5 fingerprint  : \c"
openssl x509 -fingerprint -noout -in "$str_cer_file" -md5|cut -d"=" -f2
cat $str_info_file_nm
echo "PEM Data:"
cat $str_cer_file
echo -e "\n"$COLOR_NONE

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG
