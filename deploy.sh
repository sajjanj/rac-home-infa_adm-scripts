#!/bin/bash

# NAME   :deploy.sh
# USAGE  :./deploy.sh <Target_Host> <File_Path> <File_Name>
# USAGE  :./deploy.sh <Target_Host> <Batch_File_Abs_Path>
# EXAMPLE:./deploy.sh QHVIFOAPP05 /infa_shared/Scripts start_wf.sh
# EXAMPLE:./deploy.sh QHVIFOAPP05 /infa_shared/Temp/deploy_qa.lst
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Script to deploy file(s) to other hosts in a single or batch mode
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
# func_header "Deploying file(s) to other hosts in a single or batch mode"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG
if [ $1 == "?" ] || [ $1 == "help" ]; then
	echo -e "\n\tPurpose  : Script to copy files from one server to the next. This helps during deployments."
	echo -e "\tUsage (1): ./deploy <remote_server> <file_path> <file_name> "
	echo -e "\tUsage (2): ./deploy <remote_server> <batch_file_path_name>\n"
	echo -e "\t\tThe batch-file in Usage-2 should have the following layout -"
	echo -e "\t\t FILE_NAME|LOCAL_ABSOLUTE_PATH|REMOTE_FILE_PATH"
elif [ $# -eq 3 ]; then
	rserver=$1 ; file_path=$2 ; file_name=$3 #
	echo -e $COLOR_CYAN"+ Running in SINGLE file mode"$COLOR_NONE
	scp -q ${file_path}/${file_name} ${rserver}:${file_path}/${file_name}
	if [ $? -ne 0 ]; then
		echo -e "\nERROR @ SCP"; exit 3
	fi
elif [ $# -eq 2 ]; then
	rserver=$1 ; batch_file=$2
	echo -e $COLOR_CYAN"\n+ Running in BATCH file mode\n"$COLOR_NONE
	for line in `cat $batch_file` ;do
		lfile_name=`echo $line | cut -d"|" -f1`
		lfile_path=`echo $line | cut -d"|" -f2`
		rfile_path=`echo $line | cut -d"|" -f3`
		echo -e "\t Copying file [ $lfile_name ]"
		echo -e "\t\t from [ $lfile_path ]" 
		echo -e "\t\t to   [ $rserver : $rfile_path ]\n"
		scp -q ${lfile_path}/${lfile_name} ${rserver}:${rfile_path}/${file_name}
		if [ $? -ne 0 ]; then
			echo -e "\nERROR @ SCP"; #exit 2
		fi
	done	
else
	echo -e "\nERR: Insufficient arguments. Type <deploy help> to see usage."; exit 10
fi
echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG
echo " > Process completed successfully"
