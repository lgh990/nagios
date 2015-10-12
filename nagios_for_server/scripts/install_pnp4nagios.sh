#!/bin/bash
###############################################################
#File Name      :   install_pnp4nagios.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 02:44:35 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

. /etc/rc.d/init.d/functions
source ~/global_variables.txt

PACKAGES_DIR=$GLOBAL_DIRECTORY/nagios_for_server
NAGIOS_INSTALL_DIR=/usr/local
COMMANDS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/commands.cfg
NAGIOS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nagios.cfg
TEMPLATES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/templates.cfg
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg
PNP4NAGIOS=pnp4nagios-0.6.25

function Prepare_Env {
    echo -e "\e[1;33mInstalling necessary tools\e[0m"
    if [[ -f $COMMANDS_CFG.pnpbak ]]; then
        rm -f $COMMANDS_CFG
        mv $COMMANDS_CFG.pnpbak $COMMANDS_CFG
    else
        cp $COMMANDS_CFG $COMMANDS_CFG.pnpbak
    fi
    if [[ -f $NAGIOS_CFG.pnpbak ]]; then
        rm -f $NAGIOS_CFG
        mv $NAGIOS_CFG.pnpbak $NAGIOS_CFG
    else
        cp $NAGIOS_CFG $NAGIOS_CFG.pnpbak
    fi
    if [[ -f $TEMPLATES_CFG.pnpbak ]]; then
        rm -f $TEMPLATES_CFG
        mv $TEMPLATES_CFG.pnpbak $TEMPLATES_CFG
    else
        cp $TEMPLATES_CFG $TEMPLATES_CFG.pnpbak
    fi
    if [[ -f $LOCALHOST_CFG.pnpbak ]]; then
        rm -f $LOCALHOST_CFG
        mv $LOCALHOST_CFG.pnpbak $LOCALHOST_CFG
    else
        cp $LOCALHOST_CFG $LOCALHOST_CFG.pnpbak
    fi

    yum install rrdtool librrds-perl -y > /dev/null
        
}

function Install_Pnp4nagios {
    rm -rf $NAGIOS_INSTALL_DIR/pnp4nagios
    cd $PACKAGES_DIR/packages
    tar -xf $PNP4NAGIOS.tar.gz -C $NAGIOS_INSTALL_DIR
    cd $NAGIOS_INSTALL_DIR/$PNP4NAGIOS
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios
    make all
    make install
    make install-webconf
    make install-config
    make install-init
    cd ./sample-config 
    make install-webconf
    
    cd $NAGIOS_INSTALL_DIR/pnp4nagios/etc
    mv misccommands.cfg-sample misccommands.cfg
    mv rra.cfg-sample rra.cfg
    mv nagios.cfg-sample nagios.cfg

    cd pages/
    mv web_traffic.cfg-sample web_traffic.cfg

    cd ../check_commands/
    mv check_all_local_disks.cfg-sample check_all_local_disks.cfg
    mv check_nrpe.cfg-sample check_nrpe.cfg
    mv check_nwstat.cfg-sample check_nwstat.cfg

    /etc/init.d/npcd start
    chkconfig npcd on

    sed -i 's/process_performance_data=0/process_performance_data=1/g' $NAGIOS_CFG
   cat >>$NAGIOS_CFG<<EOF
#
# service performance data
#
service_perfdata_file=/usr/local/pnp4nagios/var/service-perfdata
service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::\$TIMET\$\tHOSTNAME::\$HOSTNAME\$\tSERVICEDESC::\$SERVICEDESC\$\tSERVICEPERFDATA::\$SERVICEPERFDATA\$\tSERVICECHECKCOMMAND::\$SERVICECHECKCOMMAND\$\tHOSTSTATE::\$HOSTSTATE\$\tHOSTSTATETYPE::\$HOSTSTATETYPE\$\tSERVICESTATE::\$SERVICESTATE\$\tSERVICESTATETYPE::\$SERVICESTATETYPE\$
service_perfdata_file_mode=a
service_perfdata_file_processing_interval=15
service_perfdata_file_processing_command=process-service-perfdata-file

#
# host performance data starting with Nagios 3.0
# 
host_perfdata_file=/usr/local/pnp4nagios/var/host-perfdata
host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::\$TIMET\$\tHOSTNAME::\$HOSTNAME\$\tHOSTPERFDATA::\$HOSTPERFDATA\$\tHOSTCHECKCOMMAND::\$HOSTCHECKCOMMAND\$\tHOSTSTATE::\$HOSTSTATE\$\tHOSTSTATETYPE::\$HOSTSTATETYPE\$
host_perfdata_file_mode=a
host_perfdata_file_processing_interval=15
host_perfdata_file_processing_command=process-host-perfdata-file
    
EOF

sed -i '226,238s/^/#&/g' $COMMANDS_CFG
sed -i -e '29c\        command_line  /usr/bin/printf "%b" "***** Nagios *****\\n\\nNotification Type: $NOTIFICATIONTYPE$\\nHost: $HOSTNAME$\\nState: $HOSTSTATE$\\nAddress: $HOSTADDRESS$\\nInfo: $HOSTOUTPUT$\\n\\nDate/Time: $LONGDATETIME$\\n" | /bin/mail -s "Host $HOSTSTATE$ alert for $HOSTNAME$ "$CONTACTEMAIL$' $COMMANDS_CFG
sed -i -e '35c\        command_line  /usr/bin/printf "%b" "***** Nagios *****\\n\\nNotification Type: $NOTIFICATIONTYPE$\\n\\nService: $SERVICEDESC$\\nHost: $HOSTALIAS$\\nAddress: $HOSTADDRESS$\\nState: $SERVICESTATE$\\n\\nDate/Time: $LONGDATETIME$\\n\\nAdditional Info:\\n\\n$SERVICEOUTPUT$\\n" | /bin/mail -s "$HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ " $CONTACTEMAIL$' $COMMANDS_CFG

cat >>$COMMANDS_CFG<<EOF
define command{
       command_name    process-service-perfdata-file
       command_line    /usr/local/pnp4nagios/libexec/process_perfdata.pl --bulk=/usr/local/pnp4nagios/var/service-perfdata
}

define command{
       command_name    process-host-perfdata-file
       command_line    /usr/local/pnp4nagios/libexec/process_perfdata.pl --bulk=/usr/local/pnp4nagios/var/host-perfdata
}
EOF

cat >>$TEMPLATES_CFG<<EOF
define host {
   name       host-pnp
   action_url /pnp4nagios/index.php/graph?host=\$HOSTNAME\$&srv=_HOST_
   register   0
}

define service {
   name       service-pnp
   action_url /pnp4nagios/index.php/graph?host=\$HOSTNAME\$&srv=\$SERVICEDESC\$
   register   0
}
EOF

    cd $PACKAGES_DIR/scripts
    sh configure_pnp4nagios.sh

    rm -rf $NAGIOS_INSTALL_DIR/pnp4nagios/share/install.php

    systemctl restart nagios.service
    systemctl restart httpd.service
}

Prepare_Env
Install_Pnp4nagios
