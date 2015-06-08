#!/bin/bash
#Arthur:		kylinlin
#Begin date:	2015/6/1
#End date:		2015/6/1
#Contact email:	kylinlingh@foxmail.com
#Usage:			Prepare the development environment for nagios
#Attention:		

. /etc/rc.d/init.d/functions

TOOLS_PACKAGE_NAME=nagios_tools_for_server

NAGIOS_TOOLS_LOCATION=/usr/local
NAGIOS_TOOLS_DIR=$NAGIOS_TOOLS_LOCATION/$TOOLS_PACKAGE_NAME
NAGIOS_INSTALL_DIR=/usr/local

NAGIOS_CORE_VERSION=nagios-4.0.8
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15

RESULT=0
function show_head(){
	echo $'\n++++++++++++++++++++++++BEGIN++++++++++++++++++++++++++++++++++'
}

function show_tail(){
	echo '++++++++++++++++++++++++END++++++++++++++++++++++++++++++++++'
}
show_head
read -p "Insert the nagios login username: " login_username
read -p "Insert the nagios login password: " login_password


show_head
echo "Let's begin the magic trip."
echo "Nagios will be installed in this path: /usr/local"
show_tail


show_head
echo "Installing wget.........."
show_tail
yum install wget -y

show_head
echo "Installing mail.........."
show_tail
yum install mailx -y
yum install sendmail -y
systemctl restart sendmail.service

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
echo "Installing apache.........."
show_tail
yum install httpd -y


show_head
echo "Installing php and perl.........."
show_tail
yum install php -y
yum install php-gd -y
yum install perl -y


show_head
echo "Installing mysql lib.........."
show_tail
yum install mysql-devel -y 
yum install php-mysql -y 


show_head
echo "Installing others.........."
show_tail
yum –y install gd 
yum –y install gd-devel 
yum install openssl -y
yum install openssl-devel -y
#yum install libpng libmng libjpeg zlib xinetd -y
yum install sysstat -y
yum install dos2unix -y
yum install unzip -y
yum install net-tools -y
yum install vim -y

systemctl enable httpd.service #start http automatically


show_head
echo "Synchornizing time.........."
show_tail
yum install ntp -y
yum install ntpdate -y
timedatectl set-timezone Asia/Shanghai
ntpdate time.nist.gov

show_head
echo "Configuring time check automatically.........."
show_tail
/usr/sbin/ntpdate time.nist.gov
echo '#time sync'>>/var/spool/cron/root
echo '*/10**** /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1'>>/var/spool/cron/root


show_head
echo "Configuring firewall.........."
show_tail
firewall-cmd --add-service=http             #allow port 80
firewall-cmd --permanent --add-service=http
firewall-cmd --reload

show_head
echo "Add user:nagios and group:nagcmd.........."
show_tail
useradd -m nagios
groupadd nagcmd                                   
usermod -a -G nagcmd nagios                          
usermod -a -G nagcmd apache 


show_head
echo "First of all, uninstall nagios.........."
show_tail
cd $NAGIOS_TOOLS_DIR
cd scripts
sh uninstall_nagios.sh

show_head
echo "Installing nagios.........."
show_tail
cd $NAGIOS_TOOLS_DIR
tar -zxvf $NAGIOS_CORE_VERSION.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/$NAGIOS_CORE_VERSION
./configure --with-command-group=nagcmd
make all
make install
make install-init
make install-config
make install-commandmode
make install-webconf


show_head
echo "Coniguring the login account.........."
show_tail
htpasswd -bc /usr/local/nagios/etc/htpasswd.users $login_username $login_password


show_head
echo "Installing nagios-plugins.........."
show_tail
cd $NAGIOS_TOOLS_DIR
tar zxf $NAGIOS_PLUGIN_VERSION.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/$NAGIOS_PLUGIN_VERSION
./configure --with-nagios-user=nagios --with-nagios-group=nagios
make
make install 

echo -n "There are " `ls /usr/local/nagios/libexec/|wc -l` $'plugins have been installed\n'
chkconfig --add nagios   #start nagios with booting
chkconfig nagios on


show_head
echo "Installing nrpe.........."
show_tail
cd $NAGIOS_TOOLS_DIR
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



show_head
echo "Nagios has been installed."
echo "Startup service"
show_tail
systemctl restart httpd.service
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg
systemctl start nagios.service
systemctl start nagios.service

show_head
echo "Installing libxml2.........."
show_tail
cd $NAGIOS_TOOLS_DIR
tar -zxvf libxml2-2.7.1.tar.gz -C $NAGIOS_INSTALL_DIR
cd $NAGIOS_INSTALL_DIR/libxml2-2.7.1
./configure
make
make install


show_head
echo "Compiling nagios_configure.c.........."
show_tail
cd $NAGIOS_TOOLS_DIR/scripts
gcc -g nagios_configure.c -o nagios_configure -I /usr/local/include/libxml2/ -lxml2
./nagios_configure

show_head
echo "Configuring nagios.........."
show_tail
cd  $NAGIOS_TOOLS_DIR/scripts
sh nagios_configure.sh


show_head
echo "Checking.........."
show_tail
NAGIOS_CONFIG_STATUS=`/etc/init.d/nagios checkconfig | awk ' NR==2 {print $1}'`
if [[ $NAGIOS_CONFIG_STATUS == "OK." ]]
then
	action "Nagios configuration: " /bin/true
else
	action "Nagios configuration: " /bin/false
fi

CHECK_HTTP=`lsof -i tcp:80`
if [[ $CHECK_HTTP != "" ]]
then
	action "Http service on: " /bin/true
else
	action "Http service on: " /bin/false
fi

CHECK_NAGIOS=`ps -ef|grep nagios`
if [[ $CHECK_NAGIOS != "" ]]
then
	action "Nagios service on: " /bin/true
	RESULT=1
else
	action "Nagios service on: " /bin/false
fi


show_head
echo "Auorthizing to kylinlin.........."
show_tail
sed -i "s#nagiosadmin#$login_username#g" /usr/local/nagios/etc/cgi.cfg
/etc/init.d/nagios reload

if [[ $RESULT -eq 1 ]]
then
	systemctl restart nagios.service
	show_head
	echo "Congratulations, you are such a genius."
	show_tail  
else
	show_head
	echo "Whoops, something bad happended,check the log whose location is /usr/local/nagios_auto_install.log right now."
	show_tail 
fi

echo "Please reboot your system. Just enter reboot"
