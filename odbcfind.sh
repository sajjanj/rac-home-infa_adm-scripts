#!/bin/bash

# NAME   :odbcfind.sh 
# USAGE  :./odbcfind.sh <string pattern>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Search and display an ODBC key entry from the INI file
# AUTHOR :Sajjan Janardhanan 

. ~/.bash_profile
func_header "ODBC Key Find Utility"

if [ $# -ne 1 ]; then
  echo -e $COLOR_RED"ERR: Insufficient Arguments"$COLOR_NONE; exit 1
else
  odbckeyname=$1
  odbcfind_flg=0
  odbcfind_exists_flg=0
fi

IFS=$'\n'
set -f
for line in $(cat ${ODBCHOME}/odbc.ini); do
  wcnt=0; wcnt=`echo ${line}|grep -i $odbckeyname|wc -c`
  kcnt=0; kcnt=`echo ${line}|grep -E "\["|wc -c`
  if [[ $wcnt -gt 0 ]] && [[ $kcnt -gt 0 ]]; then
    odbcfind_exists_flg=1
    odbcfind_flg=1
  elif [ $kcnt -gt 0 ]; then
    odbcfind_flg=0
  fi
  if [ $odbcfind_flg -eq 1 ]; then
    echo -e ${COLOR_CYAN}${line}${COLOR_NONE}
  fi
done
if [ $odbcfind_exists_flg -eq 0 ]; then
  echo -e $COLOR_RED"INF: ODBC key not found"$COLOR_NONE
else
  echo
fi
