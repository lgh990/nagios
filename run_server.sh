#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/6
#Contact email:	kylinlingh@foxmail.com
#Usage:			To begin installing nagios on moniting host automatically
#Attention:	

NAGIOS_INSTALL_DIR=/usr/local
TOOLS_NAME=nagios_tools_for_server

yum install lrzsz -y
yum install dos2unix -y
yum install unzip -y
rm -rf $NAGIOS_INSTALL_DIR/$TOOLS_NAME
cd $NAGIOS_INSTALL_DIR
unzip $TOOLS_NAME.zip -d $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/$TOOLS_NAME
dos2unix scripts/*
cd scripts/
sh auto_install_server.sh 2>&1 | tee $NAGIOS_INSTALL_DIR/$TOOLS_NAME/log/nagios_install.log