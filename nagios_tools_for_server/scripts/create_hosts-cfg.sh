#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		
NAGIOS_INSTALL_DIR=/usr/local
HOSTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/hosts.cfg


function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Creating file:hosts.cfg.........."
show_tail
rm -f $HOSTS_CFG
exec <hosts.list
while read line
do
	echo 'define host {' >>$HOSTS_CFG
	echo '		use				linux-server'>>$HOSTS_CFG
	echo "		host_name			`echo $line|awk '{print $1}'`">>$HOSTS_CFG
	echo "		alias				`echo $line|awk '{print $1}'`">>$HOSTS_CFG
	echo "		address				`echo $line|awk '{print $2}'`">>$HOSTS_CFG
	echo "}">>$HOSTS_CFG
	echo >>$HOSTS_CFG
done

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
cat >>$HOSTS_CFG<<EOF
define hostgroup{
		hostgroup_name			remote-linux-servers
		alias				Remote Linux Servers
		members				$members
}
EOF