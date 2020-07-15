#!/bin/bash

# NAME   :ais.sh
# USAGE  :./ais.sh (or) ~/scripts/ais.sh
# EXAMPLE:./ais.sh Miscellaneous wf_TestConnection Int01_dev
# YODA?  :Y
# CRON?  :N
# PMREP  :Y (but PMC not needed)
# DESC   :Assigns a PC integration service to an INFA PC workflow
# AUTHOR :Sajjan Janardhanan 03/26/2018

. ~/.bash_profile
func_header "Assigning a PC integration service to an INFA PC workflow"

folder=$1
workflow=$2
intsvc=$3

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG

if [ $# -ne 3 ]; then
  echo -e "\nERR: Insufficient or Too many arguments \n"
  exit 1
else
  cd $INFA_HOME/server/bin
  ./pmrep connect -r $INFASVC_REP -d $INFASVC_DOM -n $INFA_DEFAULT_DOMAIN_USER -X INFA_DEFAULT_DOMAIN_PASSWORD
  if [ $? -ne 0 ]; then
    echo -e "\nERR: Could not connect to repository "$INFASVC_REP" @ "$INFASVC_DOM" \n"
    exit 2
  else
    ./pmrep AssignIntegrationService -f $folder -n $workflow -i $intsvc
    if [ $? -ne 0 ]; then
      echo -e "\nERR: Could not assign IS "$intsvc" to workflow "$folder":"$workflow" \n"
      exit 3
    else
      ./pmrep cleanup
      if [ $? -ne 0 ]; then
        echo -e "\nERR: Cleanup on ["$INFASVC_REP"] failed\n"
        exit 4
      else
        echo -e "\nINF: IS "$intsvc" was assigned successfully to "$folder":"$workflow" \n"
      fi
    fi
  fi
fi
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG
exit 0  
