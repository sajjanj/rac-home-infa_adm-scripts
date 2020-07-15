#!/bin/bash

# NAME   :kbfind.sh 
# USAGE  :./kbfind.sh <search_string>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Searches the scripts and aliases for the given search string
# AUTHOR :Sajjan Janardhanan 12/31/2018

. ~/.bash_profile

IFS=$'\n'
search_text=$1
func_header "Knowledge Base Find for ["$search_text"]"

for fn in `find . -maxdepth 1 -type f -exec grep -l 'USAGE  :' {} \; |sort|grep -vE 'swp|kbfind'`; do
	sh_name=`grep 'NAME   :' $fn | cut -d":" -f2` 
	let grep_cnt_1=0  ; grep_cnt_1=`grep 'NAME   :' $fn | cut -d ":" -f2 | grep -i $search_text | wc -c`
	let grep_cnt_2=0  ; grep_cnt_2=`grep 'DESC   :' $fn | cut -d ":" -f2 | grep -i $search_text | wc -c`
	let alias_cnt_1=0 ; alias_cnt_1=`grep -i $sh_name ~/.ev_alias|cut -d" " -f2|cut -d"=" -f1|wc -l`
	let alias_cnt_2=0 ; alias_cnt_2=`grep -i $search_text ~/.ev_alias|cut -d" " -f2|cut -d"=" -f1|wc -l`

	if [[ $grep_cnt_1 -gt 0 ]] || [[ $grep_cnt_2 -gt 0 ]]; then
		echo -e $COLOR_CYAN
		grep 'NAME   :' $fn
		grep 'USAGE  :' $fn
		grep 'YODA?  :' $fn
		grep 'CRON?  :' $fn
		grep 'PMREP  :' $fn
		grep 'DESC   :' $fn
		if [ $alias_cnt_1 -gt 0 ]; then
			echo '# ALIAS  :'`grep -i $sh_name ~/.ev_alias|cut -d" " -f2|cut -d"=" -f1`
		fi
		echo -e $COLOR_NONE
	fi
done	
echo -e $COLOR_CYAN
echo "AliasCnt2 = "$alias_cnt_2
if [ $alias_cnt_2 -gt 0 ]; then
	echo 'ALIASES=' 
	for al in `grep -i $search_text ~/.ev_alias|cut -d" " -f2|cut -d"=" -f1|tr ' ' ','` ; do
		echo "  > "$al
	done
fi
echo -e $COLOR_NONE
