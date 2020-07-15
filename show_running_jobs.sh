#!/bin/bash

# NAME   :show_running_jobs.sh 
# USAGE  :./show_running_jobs.sh 
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Displays active INFA jobs
# AUTHOR :Sajjan Janardhanan 10/30/2018

. ~/.bash_profile
func_header "Displaying Active INFA jobs"
echo -e $COLOR_CYAN" "
IFS=$'\n'
for psef in `ps -efl|grep pmdtm|grep -v grep`; do
  procid=$(echo $psef|awk -F" " '{ print $4 }')
  job_nm=$(echo $psef|awk 'BEGIN { RS = " -"} $1 ~ /^s$|^u$|^svn$/ { print $2,"|" }')
  dbg_wc=$(echo $psef|grep " -DBG "|wc -l)
  [ $dbg_wc -gt 0 ] && dbg_yn="DBG" || dbg_yn="***"
  echo -e $dbg_yn" | "$procid" | "$job_nm
done
echo -e $COLOR_NONE" "
