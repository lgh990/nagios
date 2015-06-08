#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/7
#End date:		2015/6/7
#Contact email:	kylinlingh@foxmail.com
#Usage:			Configure pnp4nagios
#Attention:	

NAGIOS_INSTALL_DIR=/usr/local
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg	
HOSTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/hosts.cfg
EMERGENCY_SERVICES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services/emergency_services.cfg
NORMAL_SERVICES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services/normal_services.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}
show_head
echo "Configure pnp4nagios for localhost.........."
show_tail
sed -i '25s/linux-server/linux-server,host-pnp/' $LOCALHOST_CFG
sed -i 's/local-service/local-service,service-pnp/g' $LOCALHOST_CFG

show_head
echo "Configure pnp4nagios for remote host.........."
show_tail
sed -i 's/linux-server$/linux-server,host-pnp/g' $HOSTS_CFG

show_head
echo "Configure pnp4nagios for remote services.........."
show_tail
sed -i 's/emergency-service/emergency-service,service-pnp/g' $EMERGENCY_SERVICES_CFG
sed -i 's/normal-service/normal-service,service-pnp/g' $NORMAL_SERVICES_CFG
