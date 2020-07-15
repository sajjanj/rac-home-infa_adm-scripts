#!/bin/bash

# NAME   :find_replace.sh
# USAGE  :./find_replace.sh <(all)|file_name> <find_text> <replace_text>
# YODA?  :Y
# CRON?  :N
# PMREP  :N
# DESC   :Find and Replace a text with another text in the current directory or file passed as parameter 
# AUTHOR :Sajjan Janardhanan 10/22/2018

. ~/.bash_profile
func_header "Find and Replace text in a file or files in a folder"

if [ $# -ne 3 ]; then
	if [[ $1 == "?" ]] || [[ $1 == "help" ]]; then
		~/scripts/glossary_knowledgebase.sh far; exit 0
	else
		echo -e "\nERR: Too many or insufficient arguments"; exit 10
	fi
else
	i_file_nm=$1
	i_find_txt=$2
	i_replace_txt=$3
	echo -e "\nQST: Enter the ticket number if applicable, else press the ENTER key = \c"; read tkt_num
fi

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG
tmp_ext=".fartmp"
bkp_ext=".farbkp_"$tkt_num

if [ $i_file_nm == "all" ]; then
	cnt=$(find . -maxdepth 1 -type f -exec grep -il "$i_find_txt" {} \; | grep -v ".far" | wc -l)
	if [ $cnt -eq 0 ]; then
		echo -e $COLOR_CYAN"\nINF: The find text ["$i_find_txt"] was not found in files under ["`pwd`"]\n"$COLOR_NONE
		exit 0
	else 
		echo -e $COLOR_CYAN"\nINF: Number of files containing the find text ["$i_find_txt"] = "$cnt$COLOR_NONE
	fi
	echo -e $COLOR_CYAN"INF: The following files containing text ["$i_find_txt"] will be replaced with ["$i_replace_txt"]\n"$COLOR_NONE
	find . -maxdepth 1 -type f -exec grep -il "$i_find_txt" {} \; | grep -v ".far" ; echo 

	for fn in `find . -maxdepth 1 -type f -exec grep -il "$i_find_txt" {} \; | grep -v ".far"` ; do
		echo "> Processing file [ "$fn" ]"
		sed "s/${i_find_txt}/${i_replace_txt}/g" ${fn} > ${fn}${tmp_ext}		# find and replace
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"\nERR: find & replace failed \n"$COLOR_NONE; exit 20
		fi

		cp ${fn} ${fn}${bkp_ext}												# backing up actual file
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"\nERR: backup failed \n"$COLOR_NONE; exit 30
		fi
		
		chmod 400 ${fn}${bkp_ext}
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"\nERR: change file mode bits failed \n"$COLOR_NONE; exit 35
		fi
		
		rm -f ${fn}																# deleting original file
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"\nERR: delete failed \n"$COLOR_NONE; exit 40
		fi

		mv ${fn}${tmp_ext} ${fn}												# renaming updated file
		if [ $? -ne 0 ]; then
			echo -e $COLOR_RED"\nERR: rename failed \n"$COLOR_NONE; exit 40
		fi
	done
else
	cnt=$(grep ${i_find_txt} ${i_file_nm}|wc -l)
	if [ $cnt -eq 0 ]; then
		echo -e $COLOR_CYAN"\nINF: The find text ["$i_find_txt"] was not found in the file ["$i_file_nm"]\n"$COLOR_NONE
		exit 0
	else
		echo -e $COLOR_CYAN"\nINF: Number of occurences of the find text ["$i_find_txt"] = "$cnt
	fi
	echo -e $COLOR_CYAN"INF: The following occurences of ["$i_find_txt"] will be replaced with ["$i_replace_txt"] in file ["${i_file_nm}"] \n"$COLOR_NONE
	grep ${i_find_txt} ${i_file_nm}
	
	sed "s/${i_find_txt}/${i_replace_txt}/g" ${i_file_nm} > ${i_file_nm}${tmp_ext}	# find and replace
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: find & replace failed \n"$COLOR_NONE; exit 50
	fi

	cp ${i_file_nm} ${i_file_nm}${bkp_ext}										# backing up actual file
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: backup failed \n"$COLOR_NONE; exit 60
	fi
	
	chmod 400 ${i_file_nm}${bkp_ext}
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: backup failed \n"$COLOR_NONE; exit 65
	fi
	
	rm -f ${i_file_nm}															# deleting original file
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: delete failed \n"$COLOR_NONE; exit 70
	fi

	mv ${i_file_nm}${tmp_ext} ${i_file_nm}										# renaming updated file
	if [ $? -ne 0 ]; then
		echo -e $COLOR_RED"\nERR: rename failed \n"$COLOR_NONE; exit 80
	fi	
	
	echo -e $COLOR_CYAN"\nINF: Side-by-side comparison [${i_file_nm}] after the changes; original v/s updated \n"$COLOR_NONE
	diff --side-by-side ${i_file_nm}${bkp_ext} ${i_file_nm} 
fi

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1"|"$2"|"$3>>$MASTER_LOG
echo -e $COLOR_CYAN"\n\nINF: Process completed successfully \n"$COLOR_NONE

