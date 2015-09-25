#!/bin/bash
###############################################################
#File Name      :   install_plugins.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 02:36:04 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

. /etc/rc.d/init.d/functions
source ~/global_variables.txt

PACKAGES_DIR=$GLOBAL_DIRECTORY/nagios_for_client
NAGIOS_INSTALL_DIR=/usr/local

function Install_Check_linux_stats {
    echo -e "\e[1;33mInstalling plugin: check_linux_stats.pl \e[0m"

    cd $PACKAGES_DIR/plugins
    cp check_linux_stats.pl $NAGIOS_INSTALL_DIR/nagios/libexec/
    cd $NAGIOS_INSTALL_DIR/nagios/libexec/
    chmod 755 check_linux_stats.pl
    chown nagios:nagios check_linux_stats.pl
    dos2unix check_linux_stats.pl

    cd $PACKAGES_DIR/packages
    tar -xf Sys-Statistics-Linux-0.66.tar.gz -C $NAGIOS_INSTALL_DIR
    cd $NAGIOS_INSTALL_DIR/Sys-Statistics-Linux-0.66
    yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker -y
    perl Makefile.PL
    make
    make test
    make install

}

Install_Check_linux_stats