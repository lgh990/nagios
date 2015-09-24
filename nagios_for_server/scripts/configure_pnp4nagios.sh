#!/bin/bash
###############################################################
#File Name      :   configure_pnp4nagios.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 03:05:47 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

NAGIOS_INSTALL_DIR=/usr/local
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg  
HOSTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/hosts.cfg
EMERGENCY_SERVICES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services/emergency_services.cfg
NORMAL_SERVICES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services/normal_services.cfg

function Configure {
    echo -e "\e33mConfigure pnp4nagios.\e[0m"

    #Configure pnp4nagios for localhost
    sed -i '25s/linux-server/linux-server,host-pnp/' $LOCALHOST_CFG
    sed -i 's/local-service/local-service,service-pnp/g' $LOCALHOST_CFG

    #Configure pnp4nagios for remote host
    sed -i 's/linux-server$/linux-server,host-pnp/g' $HOSTS_CFG

    #Configure pnp4nagios for remote services
    sed -i 's/emergency-service/emergency-service,service-pnp/g' $EMERGENCY_SERVICES_CFG
    sed -i 's/normal-service/normal-service,service-pnp/g' $NORMAL_SERVICES_CFG
}

Configure