#!/bin/bash
###############################################################
#File Name      :   setup.sh
#Arthor         :   kylin
#Created Time   :   Sat 19 Sep 2015 04:04:15 AM CST
#Email          :   kylinlingh@foxmail.com
#Github         :   https://github.com/Kylinlin
#Version        :   1.0
#Description    :   Prepare to initialize system
###############################################################

function Setup {
    yum install git dos2unix -y > /dev/null
    git clone https://github.com/Kylinlin/nagios.git
    cd nagios
    dos2unix nagios_for_client/scripts/*

    DIRECTORY=`pwd`
    echo "export GLOBAL_DIRECTORY=$DIRECTORY" > ~/global_variables.txt
}
 
Setup
