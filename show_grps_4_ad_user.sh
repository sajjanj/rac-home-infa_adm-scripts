#!/bin/bash

# NAME   :show_grps_4_ad_user.sh
# USAGE  :./show_grps_4_ad_user.sh <user id>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Lists the groups that a user belongs to 
# AUTHOR :Sajjan Janardhanan 01/14/2019

. ~/.bash_profile
IFS=","

if [ $# -ne 1 ]; then
    echo -e $COLOR_RED"\nERR: Too many or insufficient arguments\n"$COLOR_NONE
    exit 100
else
    usr=$1
fi

func_header "Listing groups for user [$usr]"
file_lst=~/scripts/log/adusrgrp.lst 
rm -f $file_lst ; touch $file_lst

for grpnm in `id $usr`; do 
    echo $grpnm|grep "("|cut -d"(" -f2|cut -d")" -f1 >> ~/scripts/log/adusrgrp.lst 
done

echo -e $COLOR_GREEN
cat ~/scripts/log/adusrgrp.lst|sort 
echo -e $COLOR_NONE 
