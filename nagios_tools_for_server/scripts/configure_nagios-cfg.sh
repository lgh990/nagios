#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.
NAGIOS_INSTALL_DIR=/usr/local
NAGIOS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nagios.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Operating file:/usr/local/nagios/etc/objects/.........."
show_tail
cp $NAGIOS_CFG $NAGIOS_CFG.ori
sed -i "34 i cfg_file=/usr/local/nagios/etc/objects/hosts.cfg" $NAGIOS_CFG
#sed -i "34 i cfg_file=/usr/local/nagios/etc/objects/services.cfg" $NAGIOS_CFG
sed -i "34 i cfg_dir=/usr/local/nagios/etc/objects/services" $NAGIOS_CFG

#sed -i '/localhost.cfg/d' $NAGIOS_CFG
