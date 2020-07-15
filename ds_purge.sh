#!/bin/bash
# Script Name        : ds_purge.sh
# Description        : Purges files from a folder based on named input parameters. 
# Required Paramters : (-d) Directory name (required)
#                      (-r) Retention period in days (required)
# Optional Paramter  : (-f) Search for files-only in selected directory; Values = Y|N (optional)
# Examples           : ./ds_purge.sh -d /dsftp/archive/inbound/soh -r 90 
#                      ./ds_purge.sh -d /dsftp/archive/outbound/absolute -r 60 
#                      ./ds_purge.sh -d /dsftp/archive/inbound/crm_lead/complete/purgetest/ -r 405 
#                      ./ds_purge.sh -d /dsftp/archive/inbound/crm_lead/complete/purgetest/ -r 30 -f Y
# REVISION HISTORY ----------------------------------------------------------------------------------------------------------
# DATE         NAME                 COMMENTS
# 2016-04-28   Sajjan Janardhanan   created new
# 2016-05-05   Sajjan Janardhanan   testing & refinements
# 2017-02-03   Bill Ritchie         created provision for named parameters & multi-threaded
# 2017-12-21   Bill Ritchie         Added Master Log File, removed report log, pointed script log to infa_adm/Scripts/logs
# 2018-03-08   Bill Ritchie         Removed "-type f (so we can delete folders and files) from find ....-delete purge command
# 2018-05-04   Bill Ritchie         Added environment variable $MASTER_LOG and new format for master log records
# 2018-05-08   Bill Ritchie         Because of possible data issues, removing the file pattern and extention options
# 2018-05-16   Bill Ritchie         Added optional -f paramter

func_error()
{
	return_cd=$1
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|FAIL-"$retcd"|"$0 >>$MASTER_LOG  
	exit $return_cd
}

# initialization
directory_name_flg=0; retention_days_flg=0; file_only_flg=0;
file_lkp="/infa_shared/LkpFiles/ds_purge_exclude.lst"
file_only="N"
now=`date +%Y%m%d%H%M%S`
start_time=`date +%m/%d/%Y_%H:%M:%S`
file_name="ds_purge_"${now}".log"
file_log="/home/infa_adm/scripts/log/"${file_name}

# Help logic
if [ "$1" == "help" ] ; then
	echo -e "\n\nUSAGE: "
	echo "  ./ds_purge.sh -d <directory> -r <retention> [-f Y|N] "
	echo "  dsp -d <directory> -r <retention> [-f Y|N] (dsp is alias for script ds_purge.sh)"
	echo -e "\nPARAMETERS: \n  Required:"
	echo "    (-d) Directory name"
	echo "    (-r) Retention period in days"
	echo -e "  Optional: \n    (-f) Search for files-only in selected directory; Values = Y|N"
	echo -e "\nEXAMPLES: \n  dsp -d /dsftp/archive/test_dir -r 60"
	echo "  dsp -d /dsftp/archive/test_dir -r 60 -f Y"
	echo -e "\nNOTE: \n  Setting the optional parameter to Y will delete just the files in the selected directory."
	echo -e "  Sub-directories will not be affected.\n"
	exit 0
fi
 
{
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0 >>$MASTER_LOG
	echo "INF: Script runtime = "`date +%Y-%m-%d_%T`
	echo "INF: Run by user    = "`whoami`
	echo "INF: Run at host    = "${INFA_HOST}
	echo "INF: Initiated @ IP = "`who -m|cut -d"(" -f2|sed "s/)//"`

	while getopts d:r:f: opt; do
		case "$opt" in
			d)  directory_name_flg=1
				directory_name="$OPTARG";;
			r)  retention_days_flg=1
				retention_days="$OPTARG";;
			f)  file_only_flg=1
				file_only="$OPTARG";;
			\?) echo "[ "`date +%Y-%m-%d_%T`" ] ERR: Invalid Parameter" 
				func_error 5
		esac
	done

	directory_name=`echo $directory_name"/"|sed -e 's/\/\/*/\//g'` # removes consecutive front slashes
	input_parm_string="["$directory_name","$retention_days","$file_only_flg"]"
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|PARMS|"$0"|"$input_parm_string >>$MASTER_LOG
	
	if [[ $directory_name == "" ]] || [[ $retention_days == "" ]]; then
		echo "ERR: Required parameter values missing" 
		func_error 10
	elif [[ ! -d "$directory_name" ]] || [[ $retention_days == "0" ]]; then
		echo "ERR: Invalid directory or retention parameter value"
		func_error 20
	elif [[ $file_only_flg -eq 1 ]] && [[ $file_only != 'Y' ]] && [[ $file_only != 'N' ]]; then
		echo "ERR: Invalid optional parameter value"
		func_error 30
	else
		echo "INF: Exclude List = "$file_lkp
		echo "INF: Parameter List ==>"
		echo "     > Folder       = "$directory_name
		echo "     > Retention    = "$retention_days" days"
		echo "     > Files only?  = "$file_only
	fi	

	echo -e "\n *** PRESS ANY KEY TO CONTINUE ..."; read c	

	dir_in_exclude_list=`grep -x $directory_name $file_lkp | wc -l`
	if [ $dir_in_exclude_list -gt 0 ]; then
		echo "ERR: Directory found in exclude list; cannot proceed with the purge"
		func_error 40
	else
		echo "INF: Directory not in the exclude list" 
	fi
	cd $directory_name
	file_cnt=0

	echo -e "\n *** PRESS ANY KEY TO CONTINUE ..."; read c	
	
	if [ $file_only == "Y" ]; then    
		echo "TS : "`date +%Y-%m-%d_%T`
		file_cnt=`find . -maxdepth 1 -type f -mtime +${retention_days} | wc -l` 
		echo "INF: Count for files only = "$file_cnt
		echo "TS : "`date +%Y-%m-%d_%T`
		find . -maxdepth 1 -type f -mtime +${retention_days}
		echo -e "\n *** PRESS ANY KEY TO CONTINUE ..."; read c	
		if [ $file_cnt -gt 0 ]; then
			echo "TS : "`date +%Y-%m-%d_%T`
			find . -maxdepth 1 -type f -mtime +${retention_days} -delete
			if [ $? -eq 0 ]; then
				echo -e "\nINF: Purge succeeded"
			else
				echo -e "\nERR: Purge finished with errors"
				func_error 50
			fi
		else
			echo "INF: Nothing to purge"
		fi
	else
		echo "TS : "`date +%Y-%m-%d_%T`
		file_cnt=`find . -mtime +${retention_days} | wc -l` 
		echo -e "\nINF: Recursive count for files and folders only = "$file_cnt"\n"
		echo "TS : "`date +%Y-%m-%d_%T`
		find . -mtime +${retention_days}
		echo -e "\n\n *** PRESS ANY KEY TO CONTINUE ..."; read c	
		if [ $file_cnt -gt 0 ]; then
			echo "TS : "`date +%Y-%m-%d_%T`
			find . -mtime +${retention_days} -delete
			if [ $? -eq 0 ]; then
				echo -e "\nINF: Purge succeeded"
			else
				echo -e "\nERR: Purge finished with errors"
				func_error 60
			fi
		else
			echo "INF: Nothing to purge"
		fi
	fi
	echo "TS : "`date +%Y-%m-%d_%T`
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$directory_name"|"$retention_days"|"$file_only"|"$file_cnt >>$MASTER_LOG
	echo "INF: Script completed successfully" 
} #> $file_log 2>&1

# cd /dsftp/archive/outbound/sj_temp
# /infa_shared/Scripts/sjf.sh
# /infa_shared/Scripts/sjd.sh
# dsp -d "/dsftp/archive/outbound/sj_temp" -r 550 -f Y

# find . -maxdepth 1 -ype f |wc -l --584
# find . -type f |wc -l --2996
# find . -type d |wc -l --1207
# find . -maxdepth 1 -type d |wc -l --604
# find . -maxdepth 2 -type d |wc -l --1207


