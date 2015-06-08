#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Create the host.cfg file
#Attention:		The file host.list can not has one or more empty row, or there will be something wrong.

NAGIOS_INSTALL_DIR=/usr/local

COMMANDS_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/objects/commands.cfg

function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

show_head
echo "Configuring commands.cfg.........."
show_tail
cp $COMMANDS_CFG $COMMANDS_CFG.ori
echo '#configure command check_nrpe' >>$COMMANDS_CFG
echo 'define command{ ' >>$COMMANDS_CFG
echo 'command_name		check_nrpe'>>$COMMANDS_CFG
echo 'command_line		\$USER1\$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$'>>$COMMANDS_CFG
echo '}'>>$COMMANDS_CFG

cat >>$COMMANDS_CFG<<EOF
define command{
        command_name   linux_cpu_stats
        command_line   \$USER1\$/check_linux_stats.pl -C -w 100 -s 5
}
 
define command{
        command_name   linux_load_stats
        command_line   \$USER1\$/check_linux_stats.pl -L -w 10,8,5 -c 20,18,15
}
 
define command{
        command_name   linux_mem_stats
        command_line   \$USER1\$/check_linux_stats.pl -M -w 99,50 -c 100,50
}
 
define command{
        command_name   linux_disk_stats
        command_line   \$USER1\$/check_linux_stats.pl -D -w 10 -c 5 -p / -u GB
}
 
define command{
        command_name   linux_disk_IO_stats
        command_line   \$USER1\$/check_linux_stats.pl -I -w 100,70 -c 150,100 -p sda1
}
 
define command{
        command_name   linux_network_stats
        command_line   \$USER1\$/check_linux_stats.pl -N -w 30000 -c 45000 -p eth0
}
 
define command{
        command_name   linux_openfiles_stats
        command_line   \$USER1\$/check_linux_stats.pl -F -w 10000,150000 -c 15000,250000
}
 
define command{
        command_name   linux_sockets_stats
        command_line   \$USER1\$/check_linux_stats.pl -S -w 1000 -c 2000
}
 
define command{
        command_name   linux_process_stats
        command_line   \$USER1\$/check_linux_stats.pl -P -w 2000 -c 3000
}
EOF