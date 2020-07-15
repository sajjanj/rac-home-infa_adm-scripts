tplfiles="/home/infa_adm/qa_tplfiles.txt"
rm $tplfiles
touch $tplfiles

folder="/app/informatica/powercenter951/server/infa_shared/BWParam"
echo $folder
cd $folder
find `pwd` -print >> $tplfiles

folder="/app/informatica/powercenter951/server/infa_shared/LkpFiles"
echo $folder
cd $folder
find `pwd` -print >> $tplfiles

folder="/app/informatica/powercenter951/server/infa_shared/Scripts"
echo $folder
cd $folder
find `pwd` -print >> $tplfiles

folder="/u01/informatica/powercenter951/server/infa_shared/SrcFiles"
echo $folder
cd $folder
find `pwd` -print >> $tplfiles

folder="/u01/informatica/powercenter951/server/infa_shared/TgtFiles"
echo $folder
cd $folder
find `pwd` -print >> $tplfiles
