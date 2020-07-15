#
fn_d1_users="$HOME/scripts/d1users.lst"
fn_d3_users="$HOME/scripts/d3users.lst"
fn_d1_groups="$HOME/scripts/d1groups.lst"
fn_d3_groups="$HOME/scripts/d3groups.lst"

getent group rb-informatica-adm>$fn_d3_users
getent group rb-informatica-user>>$fn_d3_users

# nm_dir="/infa_shared/"
nm_dir="/dsftp/"
cd $nm_dir ; rm -f $nm_dir/genchown.txt ; touch $nm_dir/genchown.txt

# echo -e "\n * Checking if a common UID exists between D1 & D3 in folder "$nm_dir
# for d1usr in `cat $fn_d1_users` ; do
	# d1usrid=`echo "$d1usr"|cut -d":" -f2`
	# d1usrnm=`echo "$d1usr"|cut -d":" -f1`
	# d3usr=`cat /etc/passwd|grep -i $d1usrid`
	# if [[ $d3usr != "" ]]; then
		# d3usrid=`echo "$d3usr"|cut -d":" -f3`
		# d3usrnm=`echo "$d3usr"|cut -d":" -f1`
		# if [[ $d1usrnm == $d3usrnm ]] && [[ $d1usrid -ne $d3usrid ]]; then 
			# echo "   > The UID $d1usrid is being shared between users $d1usrnm @ D1 [${d1usrid}] and $d3usrnm @ D3 [${d3usrid}] "
		# fi
	# fi 
# done

echo -e "\n\n cd "$nm_dir >> $nm_dir/genchown.txt
echo -e "\n #* Changing ownership of files in folder "$nm_dir >> $nm_dir/genchown.txt
for fn in `find . -type f`; do
	d3usrnm=`stat -c %U $fn`
	if [[ $d3usrnm == "UNKNOWN" ]]; then
		d3usrid=`stat -c %u $fn`
		echo -e "\n   #> File $fn has current unidentified ownership $d3usrid" >> $nm_dir/genchown.txt
		d1usr=`cat $fn_d1_users|grep $d3usrid`
		if [[ $d1usr != "" ]]; then
			d1usrid=`echo "$d1usr"|cut -d":" -f2`
			d1usrnm=`echo "$d1usr"|cut -d":" -f1`
			d3usr=`cat $fn_d3_users|grep -i $d1usrnm`
			if [[ $d3usr != "" ]]; then
				echo "      chown "$d1usrnm" "$fn >> $nm_dir/genchown.txt
			else
				echo "   #  missing user in `hostname` = ${d1usrnm} [${d1usrid}] " >> $nm_dir/genchown.txt
				echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
			fi 
		else
			echo "   # unknown user in D1 server. changing owner to infa_adm" >> $nm_dir/genchown.txt
			echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
		fi 
	fi
done 
echo "Press any key ...";read tmp
echo -e "\n #* Changing ownership of folders under folder "$nm_dir >> $nm_dir/genchown.txt
for fn in `find . -type d`; do
	d3usrnm=`stat -c %U $fn`
	if [[ $d3usrnm == "UNKNOWN" ]]; then
		d3usrid=`stat -c %u $fn`
		echo -e "\n   #> Folder $fn has current unidentified ownership $d3usrid" >> $nm_dir/genchown.txt
		d1usr=`cat $fn_d1_users|grep $d3usrid`
		if [[ $d1usr != "" ]]; then
			d1usrid=`echo "$d1usr"|cut -d":" -f2`
			d1usrnm=`echo "$d1usr"|cut -d":" -f1`
			d3usr=`cat $fn_d3_users|grep -i $d1usrnm`
			if [[ $d3usr != "" ]]; then
				echo "      chown "$d1usrnm" "$fn >> $nm_dir/genchown.txt
			else
				echo "   #  missing user in `hostname` = ${d1usrnm} [${d1usrid}] " >> $nm_dir/genchown.txt
				echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
			fi 
		else
			echo "   # unknown user in D1 server. changing owner to infa_adm" >> $nm_dir/genchown.txt
			echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
		fi 
	fi
done 
echo "Press any key ...";read tmp
echo -e "\n #* Changing group of files in folder "$nm_dir >> $nm_dir/genchown.txt
for fn in `find . -type f`; do
	d3grpnm=`stat -c %G ${fn}`
	# echo "File name = $fn"
	if [[ $d3grpnm == "UNKNOWN" ]]; then
	# echo "File name = $fn"
		d3grpid=`stat -c %g ${fn}`
		echo -e "\n   #> File $fn has current unidentified group $d3usrid" >> $nm_dir/genchown.txt
		d1grp=`cat $fn_d1_groups|grep $d3grpid`
		if [[ $d1grp != "" ]]; then
			d1grpid=`echo "$d1grp"|cut -d":" -f3`
			d1grpnm=`echo "$d1grp"|cut -d":" -f1`
			d3grp=`cat /etc/group|grep -i $d1grpnm`
			if [[ $d3grp != "" ]]; then
				echo "      chgrp "$d1grpnm" "$fn >> $nm_dir/genchown.txt
			else
				if [[ $d1grpnm == "etl" ]]; then
					echo "      chgrp infa_adm "$fn >> $nm_dir/genchown.txt
				else
					echo "   #  missing group in `hostname` = ${d1grpnm} [${d1grpid}] " >> $nm_dir/genchown.txt
					echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
				fi
			fi 
		else
			echo "   # unknown group in D1 server. changing owner to infa_adm" >> $nm_dir/genchown.txt
			echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
		fi 
	fi
done 
echo "Press any key ...";read tmp
echo -e "\n #* Changing group of folders under folder "$nm_dir >> $nm_dir/genchown.txt
for fn in `find . -type d`; do
	d3grpnm=`stat -c %G $fn`
	if [[ $d3grpnm == "UNKNOWN" ]]; then
		d3grpid=`stat -c %g $fn`
		echo -e "\n   #> Folder $fn has current unidentified group $d3grpid" >> $nm_dir/genchown.txt
		d1grp=`cat $fn_d1_groups|grep $d3grpid`
		if [[ $d1grp != "" ]]; then
			d1grpid=`echo "$d1grp"|cut -d":" -f3`
			d1grpnm=`echo "$d1grp"|cut -d":" -f1`
			d3grp=`cat /etc/group|grep -i $d1grpnm`
			if [[ $d3grp != "" ]]; then
				echo "      chgrp "$d1grpnm" "$fn >> $nm_dir/genchown.txt
			else
				if [[ $d1grpnm == "etl" ]]; then
					echo "      chgrp infa_adm "$fn >> $nm_dir/genchown.txt
				else
					echo "   #  missing group in `hostname` = ${d1grpnm} [${d1grpid}] " >> $nm_dir/genchown.txt
					echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
				fi
			fi 
		else
			echo "   # unknown group in D1 server. change group to infa_adm for $fn" >> $nm_dir/genchown.txt
			echo "      chown infa_adm "$fn >> $nm_dir/genchown.txt
		fi 
	fi
done 
# checking if variable value is an integer
# var=sj; if [[ $var =~ ^-?[0-9]+$ ]]; then echo "int"; else echo "not int"; fi

# return owner name
# stat -c %U ./test.out
# UNKNOWN

# return owner id
# [infa_adm@dhvifoapp03 Scripts]$ stat -c %u ./test.out
# 6965

# getent group rb-informatica-user