#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.
NAGIOS_INSTALL_DIR=/usr/local

CONTACTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/contacts.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Configuring contacts.cfg, adding  Admin Contacts.........."
show_tail
cp $CONTACTS_CFG $CONTACTS_CFG.ori
rm -f $CONTACTS_CFG
touch $CONTACTS_CFG

cat >>$CONTACTS_CFG<<EOF
#################Admin Contacts#######################################
EOF

exec <nagios_admin.list
while read line
do
	echo 'define contact{' >>$CONTACTS_CFG
	echo "		contact_name				`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo '		use					generic-contact'>>$CONTACTS_CFG
	echo "		alias					`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo "		email					`echo $line|awk '{print $2}'`">>$CONTACTS_CFG
	echo "		#telephone				`echo $line|awk '{print $3}'`">>$CONTACTS_CFG
	echo '#	service-notification-commands				notify-service-by-phone' >>$CONTACTS_CFG
	echo "}">>$CONTACTS_CFG
	echo >>$CONTACTS_CFG
done

LINE_OF_HOST_LIST=`cat nagios_admin.list|wc -l`
>tmp.host
exec <nagios_admin.list
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
cat >>$CONTACTS_CFG<<EOF

define contactgroup{
		contactgroup_name		admins
		alias				Nagios Administrators 
		members				$members
}
EOF


cat >>$CONTACTS_CFG<<EOF
#################Emergency Contacts#######################################
EOF

exec <emergency_contacts.list
while read line
do
	echo 'define contact{' >>$CONTACTS_CFG
	echo "		contact_name				`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo '		use					generic-contact'>>$CONTACTS_CFG
	echo "		alias					`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo "		email					`echo $line|awk '{print $2}'`">>$CONTACTS_CFG
	echo "		#telephone				`echo $line|awk '{print $3}'`">>$CONTACTS_CFG
	echo '#	service-notification-commands			notify-service-by-phone' >>$CONTACTS_CFG
	echo "}">>$CONTACTS_CFG
	echo >>$CONTACTS_CFG
done

LINE_OF_HOST_LIST=`cat emergency_contacts.list|wc -l`
>tmp.host
exec <emergency_contacts.list
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
cat >>$CONTACTS_CFG<<EOF

define contactgroup{
		contactgroup_name		emergency_contacts_group
		alias				Emergency Response Team 
		members				$members
}
EOF

show_head
echo "Configuring contacts.cfg, adding  normal_contacts.........."
show_tail 
exec <normal_contacts.list

cat >>$CONTACTS_CFG<<EOF
#################Normal Contacts#######################################
EOF
while read line
do
	echo 'define contact{' >>$CONTACTS_CFG
	echo "		contact_name			`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo '		use				generic-contact'>>$CONTACTS_CFG
	echo "		alias				`echo $line|awk '{print $1}'`">>$CONTACTS_CFG
	echo "		email				`echo $line|awk '{print $2}'`">>$CONTACTS_CFG
	echo "		#telephone			`echo $line|awk '{print $3}'`">>$CONTACTS_CFG
	echo '#	service-notification-commands				notify-service-by-phone' >>$CONTACTS_CFG
	echo "}">>$CONTACTS_CFG
	echo >>$CONTACTS_CFG
done

LINE_OF_HOST_LIST=`cat normal_contacts.list|wc -l`
>tmp.host
exec <normal_contacts.list
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
cat >>$CONTACTS_CFG<<EOF

define contactgroup{
		contactgroup_name		normal_contacts_group
		alias				Normal Response Team 
		members				$members
}
EOF
