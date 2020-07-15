# test connections in a parameter file
# Sajjan Janardhanan
# Created on 05/08/2017

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|BEGIN|"$0"|"$1>>$MASTER_LOG

echo -e "\n*** Script to test connections defined in a parameter file ***"
if [ $# -ne 1 ]; then
    echo "ERR: Insufficient or Too many parameters"
fi

paramfilenm=$1
echo "INF: Parameter file name = "$paramfilenm
if [ -f $paramfilenm ]; then
    echo "INF: Parameter file found"
else
    echo "ERR: Parameter file not found"
fi

conncnt=`cat $paramfilenm|sort|uniq|wc -l`
echo "INF: Number of connections in the parameter file = "$conncnt
if [ $conncnt -lt 1 ]; then
    echo "INF: No connections available to test"
else
    echo "INF: Connection test results below; 1 for SUCCESS and 0 for FAILED"
    for connm in `cat $paramfilenm|sort|uniq`; do
        connteststatus=`$HOME/scripts/testconn.sh $connm|grep -i "SUCCEEDED"|wc -l`
        if [ $? -ne 0 ]; then
            echo "ERR: Connection test script failed"
            exit 1
        fi
        if [ $connteststatus -ge 1 ]; then
            echo " 1 - "$connm
        else
            echo " 0 - "$connm
        fi
    done
fi

echo `date +%Y%m%d_%H%M%S`"|"`who -m|cut -d"(" -f2|sed "s/)//"`"|"$$"|END|"$0"|"$1>>$MASTER_LOG