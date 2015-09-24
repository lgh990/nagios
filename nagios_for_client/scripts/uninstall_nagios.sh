#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com

NAGIOS_INSTALL_DIR=/usr/local

systemctl stop nagios.service
cd $NAGIOS_INSTALL_DIR
rm -rf nagios
rm -rf Sys-Statistics-Linux-0.66

