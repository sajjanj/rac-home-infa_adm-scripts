#!/bin/bash

# NAME   :glossary_knowledgebase.sh 
# USAGE  :./glossary_knowledgebase.sh <search_string>
# YODA?  :N
# CRON?  :N
# PMREP  :N 
# DESC   :Script or Alias glossary search (decommissioned script)
# AUTHOR :Sajjan Janardhanan 10/09/2018

. ~/.bash_profile
func_header "Script or Alias glossary search"

file_gloss_alias=/home/infa_adm/scripts/glossary_alias.lst
file_gloss_script=/home/infa_adm/scripts/glossary_scripts.lst

IFS=$'\n'
search_text=$1

echo -e "\n${COLOR_RED}ALIAS matching the search pattern ---------------------------------->${COLOR_NONE}"
for lntxt in `grep -i $search_text $file_gloss_alias`; do
	alias_name=$(echo $lntxt|cut -d $'\t' -f1)
	alias_type=$(echo $lntxt|cut -d $'\t' -f2)
	alias_desc=$(echo $lntxt|cut -d $'\t' -f3)
	alias_aka=$(echo $lntxt|cut -d $'\t' -f4)
	alias_usage=$(echo $lntxt|cut -d $'\t' -f5)
	alias_infamxyn=$(echo $lntxt|cut -d $'\t' -f6)
	alias_pmrepyn=$(echo $lntxt|cut -d $'\t' -f7)
	echo -e "\n${FONT_HIGHLIGHT}ALIAS NAME        :${COLOR_NONE} \c" ; echo $alias_name
	echo -e "${FONT_HIGHLIGHT}ALIAS TYPE        :${COLOR_NONE} \c" ; echo $alias_type
	echo -e "${FONT_HIGHLIGHT}ALIAS DESCRIPTION :$COLOR_NONE \c" ; echo $alias_desc
	echo -e "${FONT_HIGHLIGHT}ALIAS AKA         :$COLOR_NONE \c" ; echo $alias_aka
	echo -e "${FONT_HIGHLIGHT}ALIAS USAGE       :$COLOR_NONE \c" ; echo $alias_usage
	echo -e "${FONT_HIGHLIGHT}ALIAS USES INFAMX?:$COLOR_NONE \c" ; echo $alias_infamxyn
	echo -e "${FONT_HIGHLIGHT}ALIAS USES PMREP? :$COLOR_NONE \c" ; echo $alias_pmrepyn
	
done

echo -e "\n${COLOR_RED}SCRIPT matching the search pattern --------------------------------->${COLOR_NONE}"
for lntxt in `grep -i $search_text $file_gloss_script`; do
	sh_name=$(echo $lntxt|cut -d $'\t' -f1)
	sh_alias=$(echo $lntxt|cut -d $'\t' -f2)
	sh_location=$(echo $lntxt|cut -d $'\t' -f3)
	sh_usage=$(echo $lntxt|cut -d $'\t' -f4)
	sh_desc=$(echo $lntxt|cut -d $'\t' -f5)
	sh_yoda=$(echo $lntxt|cut -d $'\t' -f6)
	sh_crontab=$(echo $lntxt|cut -d $'\t' -f7)
	sh_pmrep=$(echo $lntxt|cut -d $'\t' -f8)
	
	echo -e "\n${FONT_HIGHLIGHT}SCRIPT NAME             :${COLOR_NONE} \c" ; echo $sh_location"/"$sh_name
	echo -e "${FONT_HIGHLIGHT}SCRIPT ALIAS            :${COLOR_NONE} \c" ; echo $sh_alias
	echo -e "${FONT_HIGHLIGHT}SCRIPT USAGE            :${COLOR_NONE} \c" ; echo $sh_usage
	echo -e "${FONT_HIGHLIGHT}Used in master log?     :${COLOR_NONE} \c" ; echo $sh_yoda
	echo -e "${FONT_HIGHLIGHT}CronTab schedule?       :${COLOR_NONE} \c" ; echo $sh_crontab
	echo -e "${FONT_HIGHLIGHT}PMREP connect required? :${COLOR_NONE} \c" ; echo $sh_pmrep
	echo -e "${FONT_HIGHLIGHT}SCRIPT DESCRIPTION      :${COLOR_NONE} ${COLOR_CYAN} (see below)" ; echo -e $sh_desc ${COLOR_NONE}
done

echo " "
