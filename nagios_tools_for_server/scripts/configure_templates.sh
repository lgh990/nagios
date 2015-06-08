#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.
NAGIOS_INSTALL_DIR=/usr/local

TEMPLATES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/templates.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Configuring templates.cfg, adding  emergency-service and normal-service.........."
show_tail
cp $TEMPLATES_CFG $TEMPLATES_CFG.ori
cat >>$TEMPLATES_CFG<<EOF
define service{
        name                            emergency-service 						
        use                             generic-service							
        normal_check_interval           5			; Check the service every 5 minutes under normal conditions									
        retry_check_interval            1			; Re-check the service every minute until a hard state can be determined										
        contact_groups                  admins,emergency_contacts_group			
        notification_options            w,u,c,r			; Send notifications about warning, unknown, critical, and recovery events
        notification_interval           60			; Re-notify about service problems every hour
        notification_period             normalhours			; Notifications can be sent out at normalhours
        register                        0       								
        }
		
define service{
        name                            normal-service 							
        use                             generic-service							
        normal_check_interval           10			; Check the service every 10 minutes under normal conditions									
        retry_check_interval            5			; Re-check the service every 5 minutes until a hard state can be determined										
        contact_groups                  admins,normal_contacts_group				
        notification_options            w,u,c,r			; Send notifications about warning, unknown, critical, and recovery events
        notification_interval           1440			; Re-notify about service problems every day
        notification_period             workhours			; Notifications can be sent out at workours
        register                        0       								
        }

EOF

sed -i '86s/workhours/normalhours/' $TEMPLATES_CFG
sed -i '91s/admins/admins,emergency_contact_group,normal_contact_group/' $TEMPLATES_CFG