#!/bin/bash

# NAME   :showcertinfo.sh 
# USAGE  :./showcertinfo.sh <PEM_file_absolute_path>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Display PEM certificate info. Similar to [formatcert.sh], but not the same.
# AUTHOR :Sajjan Janardhanan 

. ~/.bash_profile
func_header "Displaying PEM Certificate Information"

if [ $# -ne 1 ]; then
  echo -e $COLOR_RED"\nERR: Insufficient or too many parameters"$COLOR_NONE; exit 1
elif [ ! -f $1 ]; then
  echo -e $COLOR_RED"\nERR: Could not locate input file"$COLOR_NONE; exit 2
else
  str_cer_file=$1
fi

echo -e $COLOR_CYAN"  Certificate = "$str_cer_file

echo -e "  Subject     = \c"
openssl x509 -subject     -noout -in "$str_cer_file" |cut -d"=" -f4-8

echo -e "  Issuer      = \c"
openssl x509 -issuer      -noout -in "$str_cer_file"|cut -d"=" -f4-8

echo -e "  Valid From  = \c"
openssl x509 -startdate   -noout -in "$str_cer_file"|cut -d"=" -f2

echo -e "  Valid Until = \c"
openssl x509 -enddate     -noout -in "$str_cer_file"|cut -d"=" -f2

echo -e "  Sign Alg    =\c"
openssl x509 -text        -noout -in "$str_cer_file"|grep "Signature Algorithm"|cut -d":" -f2|uniq

echo -e "  Serial Num  = \c"
openssl x509 -serial      -noout -in "$str_cer_file"|cut -d"=" -f2

echo -e "  SHA1 FP     = \c"
openssl x509 -fingerprint -noout -in "$str_cer_file" -sha1|cut -d"=" -f2

echo -e "  MD5  FP     = \c"
openssl x509 -fingerprint -noout -in "$str_cer_file" -md5|cut -d"=" -f2

echo -e $COLOR_NONE" "

