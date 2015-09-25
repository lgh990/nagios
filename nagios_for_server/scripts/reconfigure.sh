#!/bin/bash
###############################################################
#File Name      :   reconfigure.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 03:16:19 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

. /etc/rc.d/init.d/functions

DIRECTORY=`pwd`
echo "export GLOBAL_DIRECTORY=$DIRECTORY" > ~/global_variables.txt
echo "export RECONFIGURE=1" >> ~/global_variables.txt
source ~/global_variables.txt

SCRIPTS_DIR=$GLOBAL_DIRECTORY
NAGIOS_INSTALL_DIR=/usr/local

function Reconfigure {
    echo -e "\e[1;33mReconfiguring nagios.\e[0m"
    
    systemctl stop nagios
    #Recompile nagios_configure.c
    cd $SCRIPTS_DIR
    gcc -g nagios_configure.c -o nagios_configure -I /usr/local/include/libxml2/ -lxml2
    ./nagios_configure

    sh $SCRIPTS_DIR/configure_templates.sh
    sh $SCRIPTS_DIR/configure_host_and_services.sh
    sh $SCRIPTS_DIR/configure_pnp4nagios.sh

    NAGIOS_CONFIG_STATUS=`/etc/init.d/nagios checkconfig | awk ' NR==2 {print $1}'`
    if [[ $NAGIOS_CONFIG_STATUS == "OK." ]]
    then
        action "Nagios configuration: " /bin/true
    else
        action "Nagios configuration: " /bin/false
    fi
    
    /etc/init.d/nagios reload
    systemctl start nagios.service
    rm -f ~/global_variables.txt
}

Reconfigure
