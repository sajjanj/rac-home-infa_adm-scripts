#!/bin/bash
# Search for entries in the System Keystore by alias & fingerprint
# Authors = Sajjan Janardhanan
# Example = ./search_system_keystore.sh

clear 
file_sysks=$JRE_HOME/lib/security/cacerts
ks_pass=changeit
search_option=temp
echo "INF: System Keystore location = "$file_sysks
echo "INF: KEYTOOL utility location = "$JRE_HOME/bin
while [ $search_option != "q" ]; do
	echo -e "\nQST: Find by ------------> \n\t Alias(a) or \n\t Fingerprint(f) or \n\t Algorithm(s) or \n\t Any Text(t) or \n\t List All(L) \n\t ? \c"
	read search_option
	if [ $search_option == "L" ]; then # -------------------------------
		$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass | grep 'Alias name'
	elif [ $search_option == "a" ]; then # -------------------------------
		echo -e "\nQST: Enter certificate alias (does not have to be the exact string) = \c"; read search_alias
		for cert_alias_list in `$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass | grep 'Alias name' | grep -i $search_alias` ; do
			if [ $cert_alias_list != "Alias" ] && [ $cert_alias_list != "name:" ]; then
				alias_name=$(echo $cert_alias_list|cut -d" " -f3)
				echo -e "\n"
				$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
					grep -iE "alias name|owner|issuer|valid|serial|version|md5|sha1|sha2|sha3|algorithm" | \
					grep -vE "access|http" 
			fi
		done
	elif [ $search_option == "f" ]; then # -------------------------------
		echo -e "\nQST: Enter fingerprint (does not have to be the exact string) = \c"; read search_fingerprint
		for cert_alias_list in `$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass | grep 'Alias name'` ; do
			if [ $cert_alias_list != "Alias" ] && [ $cert_alias_list != "name:" ]; then
				alias_name=$(echo $cert_alias_list|cut -d" " -f3)
				let wc_fingerprint=`$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
					grep -iE "md5|sha1|sha2|sha3" | grep -i $search_fingerprint | wc -l`
				
				if [ $wc_fingerprint -gt 0 ]; then # -------------------------------
					echo " "
					$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
						grep -iE "alias name|owner|issuer|valid|serial|version|md5|sha1|sha2|sha3|algorithm" | \
						grep -vE "access|http" 
				fi
			fi
		done
	elif [ $search_option == "s" ]; then
		echo -e "\nQST: Enter algorithm (does not have to be the exact string) = \c"; read search_algorithm
		for cert_alias_list in `$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass | grep 'Alias name'` ; do
			if [ $cert_alias_list != "Alias" ] && [ $cert_alias_list != "name:" ]; then
				alias_name=$(echo $cert_alias_list|cut -d" " -f3)
				let wc_algorithm=`$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
					grep -iE "algorithm" | grep -i $search_algorithm | wc -l`
				
				if [ $wc_algorithm -gt 0 ]; then # -------------------------------
					echo " "
					$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
						grep -iE "alias name|owner|issuer|valid|serial|version|md5|sha1|sha2|sha3|algorithm" | \
						grep -vE "access|http" 
				fi
			fi
		done
	elif [ $search_option == "t" ]; then
		
		echo -e "\nQST: Enter any text = \c"; read search_text
		for cert_alias_list in `$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass | grep 'Alias name'` ; do
			if [ $cert_alias_list != "Alias" ] && [ $cert_alias_list != "name:" ]; then
				alias_name=$(echo $cert_alias_list|cut -d" " -f3)
				let wc_algorithm=`$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | grep -i $search_text | wc -l`
				
				if [ $wc_algorithm -gt 0 ]; then # -------------------------------
					echo " "
					$JRE_HOME/bin/keytool -list -v -keystore $file_sysks -storepass $ks_pass -alias $alias_name | \
						grep -iE "alias name|owner|issuer|valid|serial|version|md5|sha1|sha2|sha3|algorithm" | \
						grep -vE "access|http" 
				fi
			fi
		done
	else
		echo -e "\nERR: Invalid option \n"
	fi
	echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|NA|"$0"|"$search_option>>$MASTER_LOG
	
done
