#!/bin/bash

# NAME   :gpg_decrypt.sh
# USAGE  :./gpg_decrypt.sh <Project_Name> <EncryptedFile_AbsPath> <DecryptedFile_AbsPath>
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Decrypts a file that's encrypted using the GPG utility
# AUTHOR :Sajjan Janardhanan 10/14/2015
# Revision History ------------------------------------------------------------>
# 2015-10-30   Sajjan Janardhanan	added "--no-tty" to the GPG command to suppress messages
# 2017-08-23   Sajjan Janardhanan	Altered GPG syntax to accomodate RHEL6 syntax requirement	


. ~/.bash_profile
func_header "GPG Decryption Utility"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG

now=`date +%Y%m%d-%H%M%S`
dir_log=$HOME"/scripts/log"
file_log=$dir_log"/gpg_decrypt_"$now".log"
file_gpg_pass=${HOME}"/scripts/gpg_pass.txt"

func_get_gpg_passphrase()
{ 
	if [ $# -ne 1 ]; then
		echo "ERR: func_get_gpg_passphrase() - Insufficient or too many parameters." ; return 100
	else
		f_proj_nm=$1
		f_pass_phrase=`grep -iw ${project_name} ${file_gpg_pass} | cut -d$'\t' -f2`
		f_length=`echo ${f_pass_phrase}|wc -c`
		if [ $f_length -eq 0 ]; then
			echo "ERR: func_get_gpg_passphrase() - project entry not found." ; return 200
		fi
		return 0
	fi
}

{
	if [ $# -ne 3 ]; then
		echo "ERR: Insufficient or too many parameters." ; exit 5
	else
		project_name=${1}
		input_file=${2}
		output_file=${3}
		if [ ! -f ${input_file} ]; then
			echo "ERR: File not found [ ${input_file} ]" ; exit 10
		else
			func_get_gpg_passphrase $project_name
			if [ -f $output_file ]; then
				rm -f $output_file
				if [ $? -ne 0 ]; then
					echo "ERR: Could not delete file - "$output_file; exit 15
				fi
			fi
			# gpg --no-tty --passphrase "${f_pass_phrase}" --decrypt $input_file > $output_file # this kept prompting for the passphrase
			gpg --no-tty --passphrase "${f_pass_phrase}" --batch --yes --decrypt $input_file > $output_file # adding the 2 options stopped the prompt
			if [ -s $output_file ]; then
				echo "INF: Decryption was successful"
			else
				echo "ERR: Decryption ended in failure"; exit 20
			fi
		fi
	fi

	echo "INF: Deleting older script log files"
	cd $dir_log; rm -f `find ./gpg_decrypt*.log -mtime 1`
	if [ $? -eq 0 ]; then
		echo "INF: Older script log files purged successfully"
	else
		echo "ERR: Older script log files could not be purged"
	fi
	
	echo "INF: Process completed successfully"
	exit 0

} > $file_log 2>&1 

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG