#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/7
#End date:		2015/6/7
#Contact email:	kylinlingh@foxmail.com
#Usage:			When you change the nagios_configure.xml, you should run this script to reconfigure nagios
#Attention:	

TOOLS_PACKAGE_NAME=nagios_tools_for_server

NAGIOS_TOOLS_LOCATION=/usr/local
NAGIOS_TOOLS_DIR=$NAGIOS_TOOLS_LOCATION/$TOOLS_PACKAGE_NAME
NAGIOS_SCRIPTS=$NAGIOS_TOOLS_DIR/scripts
NAGIOS_INSTALL_DIR=/usr/local

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Recompile nagios_configure.c.........."
show_tail
cd $NAGIOS_TOOLS_DIR/scripts
gcc -g nagios_configure.c -o nagios_configure -I /usr/local/include/libxml2/ -lxml2
./nagios_configure

show_head
echo "Recreate contacts.cfg.........."
show_tail
sh $NAGIOS_SCRIPTS/configure_contacts.sh

show_head
echo "Recreate hosts.cfg.........."
show_tail
sh $NAGIOS_SCRIPTS/create_hosts-cfg.sh

show_head
echo "Recreate create_services-dir.sh.........."
show_tail
sh $NAGIOS_SCRIPTS/create_services-dir.sh

show_head
echo "Recreate configure_pnp4nagios.sh.........."
show_tail
sh $NAGIOS_SCRIPTS/configure_pnp4nagios.sh

show_head
echo "Checking the configuration for nagios.........."
show_tail
NAGIOS_CONFIG_STATUS=`/etc/init.d/nagios checkconfig | awk ' NR==2 {print $1}'`
if [[ $NAGIOS_CONFIG_STATUS == "OK." ]]
then
	action "Nagios configuration: " /bin/true
else
	action "Nagios configuration: " /bin/false
fi

show_head
echo "Reloading nagios.........."
show_tail
/etc/init.d/nagios reload

