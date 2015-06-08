#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com

NAGIOS_INSTALL_DIR=/usr/local
NAGIOS_CORE_VERSION=nagios-4.0.8
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15
TOOLS_PACKAGE_NAME=nagios_tools_for_server

cd $NAGIOS_INSTALL_DIR
rm -rf nagios
rm -rf $NAGIOS_CORE_VERSION
rm -rf $NAGIOS_PLUGIN_VERSION
rm -rf $NRPE_VERSION
rm -rf libxml2-2.7.1
