#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com

NAGIOS_INSTALL_DIR=/usr/local
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15

rm -rf $NAGIOS_INSTALL_DIR/nagios
rm -rf $NAGIOS_INSTALL_DIR/$NAGIOS_PLUGIN_VERSION
rm -rf $NAGIOS_INSTALL_DIR/$NRPE_VERSION
rm -rf $NAGIOS_INSTALL_DIR/Sys-Statistics-Linux-0.66
