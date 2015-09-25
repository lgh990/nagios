#!/bin/bash
###############################################################
#File Name      :   configure_nagios.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 11:29:03 AM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

NAGIOS_INSTALL_DIR=/usr/local

HOSTS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/hosts.cfg
NAGIOS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nagios.cfg
SERVICES_DIR=$NAGIOS_INSTALL_DIR/nagios/etc/objects/services
EMERGENCY_SERVICES_CFG=$SERVICES_DIR/emergency_services.cfg
NORMAL_SERVICES_CFG=$SERVICES_DIR/normal_services.cfg
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg

function Configure_Nagios {
    echo -e "\e[1;33mConfiguring nagios...\e[0m"
    if [[ -f $NAGIOS_CFG.bak ]]; then
        rm -f $NAGIOS_CFG
        mv $NAGIOS_CFG.bak $NAGIOS_CFG
    fi
    cp $NAGIOS_CFG $NAGIOS_CFG.bak
    
    #Make nagios to use hosts.cfg to configure hosts, and use files under directory services/ to configure services
    sed -i "34 i cfg_file=/usr/local/nagios/etc/objects/hosts.cfg" $NAGIOS_CFG
    sed -i "34 i cfg_dir=/usr/local/nagios/etc/objects/services" $NAGIOS_CFG


}

function Configure_Services {
    echo -e "\e[1;33mConfiguring services...\e[0m"
    if [[ -d $SERVICES_DIR ]]; then
        mv $SERVICES_DIR $SERVICES_DIR.bak
    fi
    mkdir -p $SERVICES_DIR

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
        echo '      use                 emergency-service' >>$EMERGENCY_SERVICES_CFG
        echo "      service_description         `echo $line|awk '{print $1}'`">>$EMERGENCY_SERVICES_CFG
        echo "      host_name               $members">>$EMERGENCY_SERVICES_CFG
        echo "      check_command               check_nrpe!`echo $line|awk '{print $1}'`">>$EMERGENCY_SERVICES_CFG
        echo '}'>>$EMERGENCY_SERVICES_CFG
        echo >>$EMERGENCY_SERVICES_CFG
    done
    
    echo "Creating normal_services.cfg.........."
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
        echo '      use                 normal-service' >>$NORMAL_SERVICES_CFG                                      
        echo "      service_description         `echo $line|awk '{print $1}'`">>$NORMAL_SERVICES_CFG
        echo "      host_name               $members">>$NORMAL_SERVICES_CFG
        echo "      check_command               check_nrpe!`echo $line| awk '{print $1}'`">>$NORMAL_SERVICES_CFG
        echo '}'>>$NORMAL_SERVICES_CFG
        echo >>$NORMAL_SERVICES_CFG
    done
}

function Configure_Localhost {
    echo -e "\e[1;33mConfiguring file localhost.cfg\e[0m"
    if [[ -f $LOCALHOST_CFG.bak ]]; then
        rm -f $LOCALHOST_CFG
        mv $LOCALHOST_CFG.bak $LOCALHOST_CFG
    fi
    cp $LOCALHOST_CFG $LOCALHOST_CFG.bak

    sed -i '46s/linux-servers/linux-servers-localhost/g' $LOCALHOST_CFG
    sed -i '46s/linux-servers/linux-servers-localhost/g' $LOCALHOST_CFG

cat >>$LOCALHOST_CFG<<EOF

#Add my services
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux disk stats
        check_command                   linux_disk_stats
        }
         
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux Processes stats
        check_command                   linux_process_stats
        }
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux Load stats
        check_command                   linux_load_stats
        }
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux mem stats
        check_command                   linux_mem_stats
        notifications_enabled           1
        }
 
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux cpu stats
        check_command                   linux_cpu_stats
        notifications_enabled           1
        }
 
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux socket stats
        check_command                   linux_sockets_stats
        notifications_enabled           1
        }
 
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux disk_io stats
        check_command                   linux_disk_IO_stats
        notifications_enabled           1
        }
 
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux network stats
        check_command                   linux_network_stats
        notifications_enabled           1
        }
 
define service{
        use                             local-service
        host_name                       localhost
        service_description             linux openfiles stats
        check_command                   linux_openfiles_stats
        notifications_enabled           1
        }

EOF

}

function Configure_Hosts {
    echo -e "\e[1;33mConfiguring file: hosts.cfg...\e[0m"
    if [[ -f $HOSTS_CFG ]]; then
        mv $HOSTS_CFG $HOSTS_CFG.bak
    fi
    touch $HOSTS_CFG
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

}

Configure_Nagios
Configure_Localhost
Configure_Services
Configure_Hosts
