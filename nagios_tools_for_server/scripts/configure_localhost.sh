#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.

NAGIOS_INSTALL_DIR=/usr/local
LOCALHOST_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/localhost.cfg

sed -i '46s/linux-servers/linux-servers-localhost/g' $LOCALHOST_CFG
sed -i '46s/linux-servers/linux-servers-localhost/g' $LOCALHOST_CFG

cat >>$LOCALHOST_CFG<<EOF
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