#!/bin/bash
###############################################################
#File Name      :   configure_contacts.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 10:16:22 AM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################


NAGIOS_INSTALL_DIR=/usr/local

CONTACTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/contacts.cfg
TIMEPERIODS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/timeperiods.cfg
TEMPLATES_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/templates.cfg

function Configure_Contacts_Template {
    echo -e "\e[1;33mConfiguring contacts...\e[0m"
    if [[ -f $CONTACTS_CFG.bak ]]; then
        rm -f $CONTACTS_CFG
    else
        mv $CONTACTS_CFG $CONTACTS_CFG.bak
    fi
    touch $CONTACTS_CFG

#Configure admin contacts.
cat >>$CONTACTS_CFG<<EOF
#################Admin Contacts#######################################
EOF

    exec <nagios_admin.list
    while read line
    do
        echo 'define contact{' >>$CONTACTS_CFG
        echo "      contact_name                `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo '      use                 generic-contact'>>$CONTACTS_CFG
        echo "      alias                   `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo "      email                   `echo $line|awk '{print $2}'`">>$CONTACTS_CFG
        echo "      #telephone              `echo $line|awk '{print $3}'`">>$CONTACTS_CFG
        echo '# service-notification-commands               notify-service-by-phone' >>$CONTACTS_CFG
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
        contactgroup_name       admins
        alias               Nagios Administrators 
        members             $members
}
EOF

#Configure emergency contacts
cat >>$CONTACTS_CFG<<EOF
#################Emergency Contacts#######################################
EOF

    exec <emergency_contacts.list
    while read line
    do
        echo 'define contact{' >>$CONTACTS_CFG
        echo "      contact_name                `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo '      use                 generic-contact'>>$CONTACTS_CFG
        echo "      alias                   `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo "      email                   `echo $line|awk '{print $2}'`">>$CONTACTS_CFG
        echo "      #telephone              `echo $line|awk '{print $3}'`">>$CONTACTS_CFG
        echo '# service-notification-commands           notify-service-by-phone' >>$CONTACTS_CFG
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
        contactgroup_name       emergency_contacts_group
        alias               Emergency Response Team 
        members             $members
}
EOF
    
#Configure normal contacts
cat >>$CONTACTS_CFG<<EOF
#################Normal Contacts#######################################
EOF
    exec <normal_contacts.list
    while read line
    do
        echo 'define contact{' >>$CONTACTS_CFG
        echo "      contact_name            `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo '      use             generic-contact'>>$CONTACTS_CFG
        echo "      alias               `echo $line|awk '{print $1}'`">>$CONTACTS_CFG
        echo "      email               `echo $line|awk '{print $2}'`">>$CONTACTS_CFG
        echo "      #telephone          `echo $line|awk '{print $3}'`">>$CONTACTS_CFG
        echo '# service-notification-commands               notify-service-by-phone' >>$CONTACTS_CFG
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
        contactgroup_name       normal_contacts_group
        alias               Normal Response Team 
        members             $members
}
EOF

}

function Configure_Timeperiods_Template {
    echo -e "\e[1;33mCongfiguring timeperiods...\e[0m"
    if [[ -f $TIMEPERIODS_CFG.bak ]]; then
        rm -f $TIMEPERIODS_CFG
        mv $TIMEPERIODS_CFG.bak $TIMEPERIODS_CFG
    fi
    cp $TIMEPERIODS_CFG $TIMEPERIODS_CFG.bak
    
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

}

function Configure_Services_Template {
    echo -e "\e[1;33mConfiguring services's templates...\e[0m"
    if [[ -f $TEMPLATES_CFG.bak ]]; then
        rm -f $TEMPLATES_CFG
        mv $TEMPLATES_CFG.bak $TEMPLATES_CFG
    fi
    cp $TEMPLATES_CFG $TEMPLATES_CFG.bak

cat >>$TEMPLATES_CFG<<EOF

define service{
        name                            emergency-service                       
        use                             generic-service                         
        normal_check_interval           5           ; Check the service every 5 minutes under normal conditions                                 
        retry_check_interval            1           ; Re-check the service every minute until a hard state can be determined                                        
        contact_groups                  admins,emergency_contacts_group         
        notification_options            w,u,c,r         ; Send notifications about warning, unknown, critical, and recovery events
        notification_interval           60          ; Re-notify about service problems every hour
        notification_period             24x7            ; Notifications can be sent out at normalhours
        register                        0                                       
        }
        
define service{
        name                            normal-service                          
        use                             generic-service                         
        normal_check_interval           10          ; Check the service every 10 minutes under normal conditions                                    
        retry_check_interval            5           ; Re-check the service every 5 minutes until a hard state can be determined                                     
        contact_groups                  admins,normal_contacts_group                
        notification_options            w,u,c,r         ; Send notifications about warning, unknown, critical, and recovery events
        notification_interval           1440            ; Re-notify about service problems every day
        notification_period             workhours           ; Notifications can be sent out at workours
        register                        0                                       
        }

EOF

sed -i '86s/workhours/normalhours/' $TEMPLATES_CFG
sed -i '91s/admins/admins,emergency_contact_group,normal_contact_group/' $TEMPLATES_CFG
    
}

Configure_Contacts_Template
Configure_Timeperiods_Template
Configure_Services_Template
