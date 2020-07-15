#!/bin/bash

# NAME   :infa_email.sh
# USAGE  :./infa_email.sh <Email_Subject> <Email_Body>
# YODA?  :Y
# CRON?  :N
# PMREP  :N 
# DESC   :Email Utility
# AUTHOR :Sajjan Janardhanan 05/08/2018

. ~/.bash_profile
func_header "Email Utility"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG
email_subject=$1
email_body=$2
status_file=$HOME"/scripts/log/pid"$$".tmp"

echo "To: ${INFA_NOTIFY}"         > ${status_file}
echo "Subject: ${email_subject}" >> ${status_file}
echo "X-Priority: 1 (Highest)"   >> ${status_file}
echo "X-MSMail-Priority: High"   >> ${status_file}
echo "${email_body}"          >> ${status_file}
sendmail -F "$INFA_ENV" -t < ${status_file}

rm -f $status_file
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG
