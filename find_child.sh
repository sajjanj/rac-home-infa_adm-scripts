#!/bin/bash

# NAME   :find_child.sh 
# USAGE  :./find_child.sh <ObjectType> <FolderName> <ObjectName>
# YODA?  :N
# CRON?  :N
# PMREP  :Y 
# DESC   :Find child object dependencies
# AUTHOR :Sajjan Janardhanan 02/15/2018

. ~/.bash_profile
func_header "Displaying Child Object Dependencies"

if [ $# -ne 3 ]; then
	echo -e $COLOR_RED"\nERR: Insufficient or too many arguments\n"$COLOR_NONE ; exit 10
else
	obj_type=$1
	sub_nm=$2
	obj_nm=$3 
fi

echo -e $COLOR_CYAN" "
cd $INFA_HOME/server/bin
./pmrep listobjectdependencies -c "|" -b -p children -y -o $obj_type -f $sub_nm -n $obj_nm | grep RAC | sort -k 2,3 -t "|"
echo -e $COLOR_NONE" "


