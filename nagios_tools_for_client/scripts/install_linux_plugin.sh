#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.

. /etc/rc.d/init.d/functions

TOOLS_PACKAGE_NAME=nagios_tools_for_client

NAGIOS_TOOLS_LOCATION=/usr/local
NAGIOS_TOOLS_DIR=$NAGIOS_TOOLS_LOCATION/$TOOLS_PACKAGE_NAME
NAGIOS_INSTALL_DIR=/usr/local

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Installing check_linux_stats.pl.........."
show_tail
cp $NAGIOS_TOOLS_DIR/plugin/check_linux_stats.pl $NAGIOS_INSTALL_DIR/nagios/libexec/
cd $NAGIOS_INSTALL_DIR/nagios/libexec/
chmod 755 check_linux_stats.pl
chown nagios:nagios check_linux_stats.pl
dos2unix check_linux_stats.pl

cd $NAGIOS_TOOLS_DIR
tar -zxvf Sys-Statistics-Linux-0.66.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/Sys-Statistics-Linux-0.66
yum install perl-ExtUtils-CBuilder perl-ExtUtils-MakeMaker -y
perl Makefile.PL
make
make test
make install
