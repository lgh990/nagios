#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/7
#Contact email:	kylinlingh@foxmail.com
#Usage:			Install plugins and configure for nagios
#Attention:		


sh configure_contacts.sh
sh configure_nagios-cfg.sh
sh configure_templates.sh
sh configure_timeperiods.sh
sh create_hosts-cfg.sh
sh create_services-dir.sh
sh configure_commands.sh
sh configure_localhost.sh
sh install_linux_plugin.sh
sh install_pnp4nagios.sh
















