#!/bin/bash

# NAME   :intruder_alert.sh
# USAGE  :./intruder_alert.sh
# YODA?  :Y
# CRON?  :Y
# PMREP  :N
# DESC   :Checks for unauthorised use of infa_adm username
# AUTHOR :Sajjan Janardhanan

. /home/infa_adm/.bash_profile
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0>>$MASTER_LOG

file_intruder="/home/infa_adm/scripts/log/intruder_alert.lst"
file_emailbody="/home/infa_adm/scripts/log/intruder_alert.email"

rm -f $file_intruder
rm -f $file_emailbody

who -aH|tr " " "-">$file_intruder
wai=`whoami`
echo "Possible unauthorized usage of "$wai" @ "`hostname` > $file_emailbody

for wholist in `cat $file_intruder|grep $wai`; do
echo "wholist = "$wholist
  ip_addr=`echo $wholist|cut -d"(" -f2|cut -d")" -f1` ; echo "ip_addr = "$ip_addr
  # machine_name=`nslookup $ip_addr|grep -i name|cut -d" " -f3|sed 's/.$//'|uniq` ; echo "machine_name = "$machine_name
  machine_name=`nslookup $ip_addr|grep -i name|cut -d":" -f2|uniq` ; echo "machine_name = "$machine_name
  authorization=`cat $FILE_MACHINES|grep $machine_name|cut -d"|" -f4|uniq`  ; echo "authorization = "$authorization
  username=`cat $FILE_MACHINES|grep $machine_name|cut -d"|" -f2|uniq` ; echo "username = "$username
  if [ $authorization != "Y" ]; then
	  echo -e "\nIP Address    = "$ip_addr >> $file_emailbody
	  echo      "Machine Name  = "$machine_name >> $file_emailbody
	  echo      "Authorization = "$authorization >> $file_emailbody
	  echo      "User ID       = "$username >> $file_emailbody
  fi
done

cnt_emailbody=`cat $file_emailbody|wc -l`
if [ $cnt_emailbody -gt 2 ]; then
	cat $file_emailbody|mail -s "Intruder Alert @ `hostname`" -a $file_intruder sajjan.janardhanan@rentacenter.com
fi 

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0>>$MASTER_LOG


#SQL to load the file machine_names.lst
#select 
#  distinct user_id, user_name, saved_from, 
#  case user_name
#    when 'jansaj' then 'Y'
#    when 'ritbil' then 'Y'
#    else 'N'
#  end as authorized
#from sj_all_version_props
#where 1=1 
#  and upper(saved_from) not like '%HVIFOAPP%'
#  and saved_from != '*UNKNOWN*'
#  and user_name != 'Administrator'
#order by 2, 3
