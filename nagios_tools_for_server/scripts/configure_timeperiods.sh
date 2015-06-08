#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.
NAGIOS_INSTALL_DIR=/usr/local

TIMEPERIODS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/timeperiods.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Configuring timeperiod.cfg, adding  normalhours and workhours.........."
show_tail
cp $TIMEPERIODS_CFG $TIMEPERIODS_CFG.ori
cat >>$TIMEPERIODS_CFG<<EOF
# 'normalhours' timeperiod definition
define timeperiod{
        timeperiod_name normalhours
        alias           18 Hours A Day, 7 Days A Week
        sunday          06:00-22:00
        monday          06:00-22:00
        tuesday         06:00-22:00
        wednesday       06:00-22:00
        thursday        06:00-22:00
        friday          06:00-22:00
        saturday        06:00-22:00
        }
EOF