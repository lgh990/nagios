#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/7
#End date:		2015/6/7
#Contact email:	kylinlingh@foxmail.com
#Usage:			Install pnp4nagios
#Attention:		This script will call configure_pnp4nagios.sh to configure pnp4nagios
. /etc/rc.d/init.d/functions

TOOLS_PACKAGE_NAME=nagios_tools_for_server
NAGIOS_INSTALL_DIR=/usr/local
NAGIOS_TOOLS_LOCATION=/usr/local
NAGIOS_TOOLS_DIR=$NAGIOS_TOOLS_LOCATION/$TOOLS_PACKAGE_NAME

COMMANDS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/commands.cfg
NAGIOS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nagios.cfg
TEMPLATES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/templates.cfg
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg
PNP4NAGIOS=pnp4nagios-0.6.25

cp $COMMANDS_CFG $COMMANDS_CFG.pnporg
cp $NAGIOS_CFG $NAGIOS_CFG.pnporg
cp $TEMPLATES_CFG $TEMPLATES_CFG.pnporg
cp $LOCALHOST_CFG $LOCALHOST_CFG.pnporg
function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}
show_head
echo "Installing libs.........."
show_tail
#yum install cairo-devel libxml2-devel pango-devel pango libpng-devel freetype freetype-devel libart_lgpl-devel -y
yum install rrdtool librrds-perl -y

#show_head
#echo "Installing rrdtools.........."
#show_tail
#cd $NAGIOS_TOOLS_DIR
#tar -xvf rrdtool-1.5.3.tar.gz
#cd rrdtool-1.5.3
#./configure --prefix=/usr/local/rrdtool --disable-python --disable-tcl
#make && make install

show_head
echo "Installing pnp4nagios.........."
show_tail
cd $NAGIOS_TOOLS_DIR
tar -xvf $PNP4NAGIOS.tar.gz -C $NAGIOS_INSTALL_DIR
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

show_head
echo "Configuring pnp4nagios.........."
show_tail
sed -i 's/process_performance_data=0/process_performance_data=1/g' $NAGIOS_CFG
#sed -i 's/#host_perfdata_command=process-host-perfdata/host_perfdata_command=process-host-perfdata/g' nagios.cfg
#sed -i 's/#service_perfdata_command=process-service-perfdata/service_perfdata_command=process-service-perfdata/g' nagios.cfg

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
sed -i -e '35c\        command_line	 /usr/bin/printf "%b" "***** Nagios *****\\n\\nNotification Type: $NOTIFICATIONTYPE$\\n\\nService: $SERVICEDESC$\\nHost: $HOSTALIAS$\\nAddress: $HOSTADDRESS$\\nState: $SERVICESTATE$\\n\\nDate/Time: $LONGDATETIME$\\n\\nAdditional Info:\\n\\n$SERVICEOUTPUT$\\n" | /bin/mail -s "$HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ " $CONTACTEMAIL$' $COMMANDS_CFG

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
show_head
echo "Configuring pnp4nagios.........."
show_tail
cd $NAGIOS_TOOLS_DIR/scripts
sh configure_pnp4nagios.sh

rm -rf $NAGIOS_INSTALL_DIR/pnp4nagios/share/install.php

systemctl restart nagios.service
systemctl restart httpd.service

show_head
echo "Install pnp4nagios finish. enjoy it.........."
show_tail

