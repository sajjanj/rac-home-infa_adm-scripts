if [ $# -ne 2 ]; then
  echo "ERR: Insufficient or Too many arguments"
  exit -1
fi

dir=$1
ret=$2
dttm=`date +%Y%m%d_%H%M%S`
logfile=~/scripts/log/nohup_purge_${dttm}.log
emailaddr="sajjan.janardhanan@rentacenter.com"
emailsub="${ret} days retention purge in [${dir}] started at {$dttm} "

{
echo "Purge in folder ["$dir"] for retention of ["$ret"] days"
echo "Start time = "$dttm
cd $dir
if [ $? -ne 0 ]; then
  echo ${emailsub}|mail -s "FAILED 1 $dir" $emailaddr
  echo "Failed 1 @ "`date +%Y%m%d_%H%M%S`
  exit 1
else
  find ${dir} -type f -mtime +${ret} -delete
  if [ $? -ne 0 ]; then
    echo ${emailsub}|mail -s "FAILED 2 $dir" $emailaddr
    echo "Failed 2 @ "`date +%Y%m%d_%H%M%S`
    exit 2
  else
    echo ${emailsub}|mail -s "OK $dir" $emailaddr
    echo "Succeeded @ "`date +%Y%m%d_%H%M%S`
  fi
fi
exit 0
} > $logfile 2>&1

