#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/6
#Contact email:	kylinlingh@foxmail.com
#Usage:			To begin installing nagios on moniting host automatically
#Attention:	

NAGIOS_INSTALL_DIR=/usr/local
TOOLS_NAME=nagios_tools_for_server

cd $NAGIOS_INSTALL_DIR/$TOOLS_NAME/scripts
sh change_configure.sh 2>&1 | tee $NAGIOS_INSTALL_DIR/$TOOLS_NAME/log/reconfigure_nagios.log