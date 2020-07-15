#!/bin/bash

# NAME   :deploy2all.sh
# USAGE  :./deploy2all.sh <File_Path> <File_Name>
# EXAMPLE:./deploy2all.sh /infa_shared/Scripts start_wf.sh
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Script to deploy files to other active INFA hosts 
# AUTHOR :Sajjan Janardhanan

. ~/.bash_profile
func_header "Deploying files to other active INFA hosts"

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2>>$MASTER_LOG

if [ $# -eq 2 ]; then # single file mode
	file_path=$1
	file_nm=$2

	host_nm="DHVIFOAPP06"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 2
	fi

	host_nm="QHVIFOAPP05"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 3
	fi

	host_nm="QHVIFOAPP06"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 4
	fi

	host_nm="UHVIFOAPP03"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 5
	fi

	host_nm="UHVIFOAPP04"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 6
	fi

	host_nm="PHVIFOAPP04"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 7
	fi

	host_nm="PHVIFOAPP05"
	echo -e "\nINF: Copying file to "$host_nm
	$HOME/scripts/deploy.sh $host_nm $file_path $file_nm
	if [ $? -ne 0 ]; then
		echo "ERR: deploy error"; exit 8
	fi

elif [ $# -eq 1 ]; then # multiple files mode

	file_lst_nm=$1
	if [ $file_lst_nm == "?" ] || [ $file_lst_nm == "help" ]; then
		echo -e "\n\tPurpose  : Script to copy one or more files to all INFA servers"
		echo -e "\t single  : ./deploy <file_path> <file_name> "
		echo -e "\t multiple: ./deploy <list file absolute path>\n"
	else

		host_nm="DHVIFOAPP06"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 9
		fi

		host_nm="QHVIFOAPP03"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 10
		fi

		host_nm="QHVIFOAPP04"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 11
		fi

		host_nm="UHVIFOAPP03"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 12
		fi

		host_nm="UHVIFOAPP04"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 13
		fi

		host_nm="PHVIFOAPP04"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 14
		fi

		host_nm="PHVIFOAPP05"
		echo -e "\nINF: Copying file to "$host_nm
		$HOME/scripts/deploy.sh $host_nm $file_lst_nm
		if [ $? -ne 0 ]; then
			echo "ERR: deploy error"; exit 15
		fi
	fi
else 
	echo "ERR: incorrect argument count"; exit 1
fi

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2>>$MASTER_LOG
echo
