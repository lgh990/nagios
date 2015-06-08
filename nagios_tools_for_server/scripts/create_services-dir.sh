#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.

NAGIOS_INSTALL_DIR=/usr/local

SERVICES_DIR=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services
EMERGENCY_SERVICES_CFG=$SERVICES_DIR/emergency_services.cfg
NORMAL_SERVICES_CFG=$SERVICES_DIR/normal_services.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Creating emergency_services.cfg.........."
show_tail
rm -rf $SERVICES_DIR

if [[ ! -d $SERVICES_DIR ]]
then
	mkdir $SERVICES_DIR
fi

LINE_OF_HOST_LIST=`cat hosts.list|wc -l`
>tmp.host
exec <hosts.list
i=1
while read line
do
	if [ $i -eq $LINE_OF_HOST_LIST ]
	then
		echo -n "`echo $line|awk '{print $1}'`">>tmp.host
	else
		echo -n "`echo $line|awk '{print $1}'`",>>tmp.host
	fi
	((i++))
done

members=`head -1 tmp.host`

exec <emergency_services.list
while read line
do
	if [[ ${#line} == 0 ]]
	then 
		break;
	fi
	echo 'define service{' >>$EMERGENCY_SERVICES_CFG
	echo '		use					emergency-service' >>$EMERGENCY_SERVICES_CFG
	echo "		service_description			`echo $line|awk '{print $1}'`">>$EMERGENCY_SERVICES_CFG
	echo "		host_name				$members">>$EMERGENCY_SERVICES_CFG
	echo "		check_command				check_nrpe!`echo $line|awk '{print $1}'`">>$EMERGENCY_SERVICES_CFG
	echo '}'>>$EMERGENCY_SERVICES_CFG
	echo >>$EMERGENCY_SERVICES_CFG
done

show_head
echo "Creating normal_services.cfg.........."
show_tail
exec <normal_services.list
if [[ !NORMAL_SERVICES_CFG ]]
then
	touch $NORMAL_SERVICES_CFG
fi
while read line
do
	if [[ ${#line} == 0 ]]
	then 
		break;
	fi
	echo 'define service{' >>$NORMAL_SERVICES_CFG
	echo '		use					normal-service' >>$NORMAL_SERVICES_CFG										
	echo "		service_description			`echo $line|awk '{print $1}'`">>$NORMAL_SERVICES_CFG
	echo "		host_name				$members">>$NORMAL_SERVICES_CFG
	echo "		check_command				check_nrpe!`echo $line| awk '{print $1}'`">>$NORMAL_SERVICES_CFG
	echo '}'>>$NORMAL_SERVICES_CFG
	echo >>$NORMAL_SERVICES_CFG
done
