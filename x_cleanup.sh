now=`date +%Y%m%d%H%M%S`
whom=`who -m|cut -d"(" -f2|sed "s/)//"`
echo $now"|"$whom"|"$0>>$MASTER_LOG

subdir="adminconsole"
echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/webapps/$subdir \n"
cd $INFA_HOME/tomcat/webapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="coreservices"
echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/webapps/$subdir \n"
cd $INFA_HOME/tomcat/webapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="csm"
echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/webapps/$subdir \n"
cd $INFA_HOME/tomcat/webapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="ROOT"
echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/webapps/$subdir \n"
cd $INFA_HOME/tomcat/webapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

#-----------------------

echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/work \n"
cd $INFA_HOME/tomcat/work
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the files & folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder $INFA_HOME/tomcat/work"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

#-----------------------

echo -e "\nINF: TOMCAT cleanup @ \$INFA_HOME/tomcat/temp \n"
cd $INFA_HOME/tomcat/temp
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the files & folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder $INFA_HOME/tomcat/temp"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

#-----------------------

subdir="glossary"
echo -e "\nINF: MM cleanup @ \$INFA_HOME/services/MetadataManagerService/mmapps/$subdir \n"
cd $INFA_HOME/services/MetadataManagerService/mmapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="mmhelp_en"
echo -e "\nINF: MM cleanup @ \$INFA_HOME/services/MetadataManagerService/mmapps/$subdir \n"
cd $INFA_HOME/services/MetadataManagerService/mmapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="mmhelp_ja"
echo -e "\nINF: MM cleanup @ \$INFA_HOME/services/MetadataManagerService/mmapps/$subdir \n"
cd $INFA_HOME/services/MetadataManagerService/mmapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

subdir="mm"
echo -e "\nINF: MM cleanup @ \$INFA_HOME/services/MetadataManagerService/mmapps/$subdir \n"
cd $INFA_HOME/services/MetadataManagerService/mmapps/$subdir
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with purging the folders? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        echo "INF: Emptying folder ["$subdir"]"
        rm -R *
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
        echo "INF: Deleting folder ["$subdir"]"
        cd ..
        rmdir ./$subdir
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
            exit -1
        fi
    fi
fi

#-----------------------

echo -e "\nINF: Backing up log files"
cd $INFA_HOME/tomcat/logs
if [ $? -ne 0 ]; then
    echo "ERR: Last issued command ended in failure; Press ENTER to continue or CTRL+C to abort"
else
    echo "Current Dir: "`pwd`; echo
    ls -l
    echo -en "\nQYN: Proceed with renaming log files? (Y/N) = "; read yn_proceed
    if [[ $yn_proceed != "Y" && $yn_proceed != "y" ]]; then
        echo "INF: Skipped"
    else
        logfilename="catalina.out"
        echo "INF: Renaming "$logfilename
        mv ./$logfilename ./${logfilename}_${now}
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
        fi
        
        logfilename="exceptions.log"
        echo "INF: Renaming "$logfilename
        mv ./$logfilename ./${logfilename}_${now}
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
        fi
        
        logfilename="node.log"
        echo "INF: Renaming "$logfilename
        mv ./$logfilename ./${logfilename}_${now}
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
        fi
        
        logfilename="node_jsf.log"
        echo "INF: Renaming "$logfilename
        mv ./$logfilename ./${logfilename}_${now}
        if [ $? -ne 0 ]; then
            echo "ERR: Last issued command ended in failure"
        fi
    fi
fi    

echo -e "\nINF: Process completed"
