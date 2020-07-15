#!/bin/bash

# NAME   :findtext.sh
# USAGE  :./findtext.sh <Search_Text>
# YODA?  :N
# CRON?  :N
# PMREP  :N
# DESC   :Looks for a string recursively in the files in the current & subfolders using FIND 
# AUTHOR :Sajjan Janardhanan 10/22/2018

. ~/.bash_profile
func_header "Find Text Utility"

echo -e $COLOR_CYAN
if [ $# -ne 1 ]; then
  echo -e "\nERR: Insufficient or Too many arguments"
  exit 10
fi
input_txt=$1
echo -e "\nINF: Finding text ["$input_txt"] recursively in folder => \c"`pwd`
for fn in `find . -type f -exec grep -il $input_txt {} \;`; do 
  echo -e "\n\nFile $fn ------>"
  grep -i $input_txt $fn
done
echo -e $COLOR_NONE
