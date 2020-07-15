#!/bin/bash

# NAME   :show_core_info.sh
# USAGE  :./show_core_info.sh <core file name>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Display the ETL object details from the core file 
# AUTHOR :Sajjan Janardhanan 01/15/2019

. ~/.bash_profile

core_file=$1
strings_file=~/scripts/log/show_core_info_strings.out
errors_file=~/scripts/log/show_core_info_errors.out
func_header "Core File Information for "$core_file

strings $core_file > $strings_file      #~ Stores the output of the strings output in show_core_info_strings.out
while read strings_file_line ; do                    #~ find the string that having 2ns, 3rd and 4th characters as follows
    if [ "${strings_file_line:0:4}" = "-rsn" ]; then
      read strings_file_line                           #~ if the above condition is true then next line will be Repository name
      repo_nm=$strings_file_line
    fi
    if [ "${strings_file_line:0:4}" = "-rst" ]; then
      read strings_file_line                           #~ if the above condition is true then next line will be folder workflow session name
      fws_nm=$strings_file_line
    fi
    if [ "${strings_file_line:0:4}" = "-svn" ]; then
      read strings_file_line                           #~ if the above condition is true then next line will be Integartion service name
      is_nm=$strings_file_line
    fi
    if [ "${strings_file_line:0:4}" = "-dmn" ]; then
      read strings_file_line                           #~ if the above condition is true then next line will be domain name
      dom_nm=$strings_file_line
    fi
    if [ "${strings_file_line:0:8}" = "HOSTNAME" ]; then
      host_nm=`echo $strings_file_line|cut -d"=" -f2`
    fi
    if [ "${strings_file_line:0:4}" = "-run" ]; then
      read strings_file_line; read strings_file_line
	  usr_nm=$strings_file_line
    fi
done <"$strings_file"> $errors_file

echo -e $COLOR_CYAN
echo "Host         = "$host_nm
echo "Domain       = "$dom_nm
echo "Repository   = "$repo_nm
echo "Folder       = "`echo $fws_nm|cut -d":" -f1`
echo "Workflow     = "`echo $fws_nm|cut -d":" -f2|cut -d"." -f1`
echo "Session      = "`echo $fws_nm|cut -d":" -f2|cut -d"." -f2`
echo "Int. Service = "$is_nm
echo "User         = "$usr_nm
func_subheader "List of errors in the core file"
cat $strings_file|grep "^FATAL"
cat $strings_file|grep "^ERROR:"
func_subheader "List of errors during core file analysis"
cat $errors_file
echo -e $COLOR_NONE
rm $strings_file
rm $errors_file
exit 0

