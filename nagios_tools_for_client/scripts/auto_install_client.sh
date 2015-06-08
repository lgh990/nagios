#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com

. /etc/rc.d/init.d/functions

TOOLS_PACKAGE_NAME=nagios_tools_for_client #change here to match your package name

NAGIOS_TOOLS_LOCATION=/usr/local
NAGIOS_INSTALL_DIR=/usr/local

NAGIOS_CORE_VERSION=nagios-4.0.8
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15
NRPE_VERSION_CHECK="NRPE v2.15"

NRPE_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nrpe.cfg

RESULT=0
function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}

read -p "Input the moniting host address, use comma to seperate hosts: " HOST_ADDRESS 


show_head
echo "Let's begin the magic trip."
show_tail

#show_head
#echo "Updating yum.........."
#show_tail
#yum update -y

show_head
echo "Uninstall nagios first."
show_tail
sh uninstall_nagios.sh

show_head
echo "Installing net-tools.........."
show_tail
yum install net-tools -y

show_head
echo "Installing lsof.........."
show_tail
yum install lsof -y

show_head
echo "Shutting down Selinux.........."
show_tail
sed -i 's/enforcing/disabled/g' /etc/selinux/config

show_head
echo "Installing compiler.........."
show_tail
yum -y install gcc 
yum -y install glibc 
yum -y install glibc-common 

show_head
echo "Installing others.........."
show_tail
yum –y install gd 
yum –y install gd-devel 
yum install openssl -y
yum install openssl-devel -y
#yum install libpng libmng libjpeg zlib xinetd -y
yum install sysstat -y
yum install wget -y
yum install vim -y

systemctl enable httpd.service #start http automatically


show_head
echo "Synchornizing time.........."
show_tail
yum install ntp -y
yum install ntpdate -y
timedatectl set-timezone Asia/Shanghai
ntpdate time.nist.gov
ntpdate time.nist.gov


show_head
echo "Configuring time check itself automatically.........."
show_tail
/usr/sbin/ntpdate time.nist.gov
echo '#time sync'>>/var/spool/cron/root
echo '*/10**** /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1'>>/var/spool/cron/root


show_head
echo "Configuring firewall.........."
show_tail
firewall-cmd --add-service=http
firewall-cmd --permanent --add-service=http
firewall-cmd --zone=public --add-port=5666/tcp --permanent
firewall-cmd --reload

#cd $NAGIOS_INSTALL_DIR
#show_head
#echo "Downloading nagios-plugin from sourceforge.........."
#show_tail
#wget http://www.nagios-plugins.org/download/nagios-plugins-2.0.3.tar.gz

#show_head
#echo "Downloading nrpe from sourceforge.........."
#show_tail
#wget http://sourceforge.net/projects/nagios/files/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz


show_head
echo "Create user: nagios.........."
show_tail
useradd -s /sbin/nologin nagios 

show_head
echo "Installing nagios-plugins.........."
show_tail
cd $NAGIOS_INSTALL_DIR/$TOOLS_PACKAGE_NAME
tar -zxvf $NAGIOS_PLUGIN_VERSION.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/$NAGIOS_PLUGIN_VERSION
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install 

show_head
echo "Installing nrpe.........."
show_tail
cd $NAGIOS_INSTALL_DIR/$TOOLS_PACKAGE_NAME
tar -zxvf $NRPE_VERSION.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/$NRPE_VERSION
./configure --with-nrpe-user=nagios \
     --with-nrpe-group=nagios \
     --with-nagios-user=nagios \
     --with-nagios-group=nagios \
     --enable-command-args \
     --enable-ssl
make all
make install-plugin
make install-daemon
make install-daemon-config
#make install-xined

show_head
echo "Writing start script for nrpe.........."
show_tail
NRPE_START_SCRIPT=/etc/init.d/nrpe
if [[ -f $NRPE_START_SCRIPT ]]
then
	rm -rf $NRPE_START_SCRIPT
fi
echo '#!/bin/bash
# chkconfig: 2345 88 12
# description: NRPE DAEMON
NRPE=/usr/local/nagios/bin/nrpe
NRPECONF=/usr/local/nagios/etc/nrpe.cfg

case "$1" in
	start)
		echo -n "Starting NRPE daemon..."
		$NRPE -c $NRPECONF -d
		echo " done."
		;;
	stop)
		echo -n "Stopping NRPE daemon..."
		pkill -u nagios nrpe
		echo " done."
	;;
	restart)
		$0 stop
		sleep 2
		$0 start
		;;
	*)
		echo "Usage: $0 start|stop|restart"
		;;
	esac
exit 0
' >$NRPE_START_SCRIPT

chmod +x /etc/init.d/nrpe


show_head
echo "Configuring nagios.........."
show_tail

cp $NRPE_CFG $NAGIOS_INSTALL_DIR/nagios/etc/nrpe.cfg.ori
sed -i "s/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,$HOST_ADDRESS/g" $NRPE_CFG

sed -i '218,224d' $NRPE_CFG
echo "command[check_users]=$NAGIOS_INSTALL_DIR/nagios/libexec/check_users -w 5 -c 10" >>$NRPE_CFG
echo "command[check_load]=$NAGIOS_INSTALL_DIR/nagios/libexec/check_load -w 15,10,5 -c 30,25,20">>$NRPE_CFG
echo "command[check_disk]=$NAGIOS_INSTALL_DIR/nagios/libexec/check_disk -w 20% -c 10% -p /dev/sda1">>$NRPE_CFG
echo "command[check_zombie_procs]=$NAGIOS_INSTALL_DIR/nagios/libexec/check_procs -w 5 -c 10 -s Z">>$NRPE_CFG
echo "command[check_total_procs]=$NAGIOS_INSTALL_DIR/nagios/libexec/check_procs -w 150 -c 200">>$NRPE_CFG
echo "command[check_mem]=/usr/local/nagios/libexec/check_linux_stats.pl -M -w 100,25 -c 100,50">>$NRPE_CFG
echo "command[check_cpu]=/usr/local/nagios/libexec/check_linux_stats.pl -C -w 99 -c 100 -s 5">>$NRPE_CFG
echo "command[check_open_file]=/usr/local/nagios/libexec/check_linux_stats.pl -F -w 10000,250000 -c 15000,350000">>$NRPE_CFG
echo "command[check_io]=/usr/local/nagios/libexec/check_linux_stats.pl -I -w 2000,600 -c 3000,800 -p sda1,sda3,sda4 -s 5">>$NRPE_CFG
echo "command[check_net]=/usr/local/nagios/libexec/check_linux_stats.pl -N -w 1000000 -c 1500000 -p eth0 -s 5">>$NRPE_CFG
echo "command[check_socket]=/usr/local/nagios/libexec/check_linux_stats.pl -S -w 500 -c 1000">>$NRPE_CFG
echo "command[check_uptime]=/usr/local/nagios/libexec/check_linux_stats.pl -U -w 5">>$NRPE_CFG

show_head
echo "Installing check_linux_stats.pl plugin.........."
show_tail
cd $NAGIOS_INSTALL_DIR/$TOOLS_PACKAGE_NAME/scripts
sh install_linux_plugin.sh


show_head
echo "Starting nrpe.........."
show_tail
$NAGIOS_INSTALL_DIR/nagios/bin/nrpe -c $NRPE_CFG –d
systemctl restart nrpe.service


show_head
echo "Checking nrpe working or not.........."
show_tail
CHECK_NRPE_STATUS=`netstat -tnlp | awk '{print $7}'|grep nrpe`
if [[ CHECK_NRPE_STATUS != "" ]]
then
	action "Nrpe working: " /bin/true
else
	action "Nrpe working: " /bin/false
fi

CHECK_NRPE_VERSION=`/usr/local/nagios/libexec/check_nrpe -H 127.0.0.1`
if [[ $CHECK_NRPE_VERSION == $NRPE_VERSION_CHECK ]]
then
	action "Nrpe version check: " /bin/true
	RESULT=1
else
	action "Nrpe version check: " /bin/false
fi

if [[ $RESULT -eq 1 ]]
then
	show_head
	echo "Congratulations, you are such a genius."
	show_tail  
else
	show_head
	echo "Whoops, something bad happended,check the log whose location is /usr/local/nagios_install_client.log right now."
	show_tail 
fi











