#!/bin/bash

# NAME   :chowninfaadm.sh
# USAGE  :./chowninfaadm.sh <file_name>
# EXAMPLE:./chowninfaadm.sh /infa_shared/Temp/sajjan.txt
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Attempts to change the ownership of a file to "infa_adm" without being a "root" user
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Attempting to change the ownership of file to infa_adm"

if [ $# -ne 1 ]; then
  echo "  ERR: Insufficient or too many arguments" ; exit 1
fi

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG

fn=$1
cp $fn ${fn}_CHOWNINFAADM
if [ $? -ne 0 ]; then
	echo "  ERR: Cloning step failed" ; exit 2
else
	echo "  INF: Cloning succeeded"
fi

rm -f $fn
if [ $? -ne 0 ]; then
	echo "  ERR: Deletion failed" ; exit 3
else
	echo "  INF: Deletion succeeded"
fi

mv ${fn}_CHOWNINFAADM $fn
if [ $? -ne 0 ]; then
	echo "  ERR: Rename failed" ; exit 4
else
	echo "  INF: Rename succeeded"
fi

echo
ls -l ${fn}*
echo
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG
