#!/bin/bash
###############################################################
#File Name      :   setup.sh
#Arthor         :   kylin
#Created Time   :   Wed 23 Sep 2015 02:57:29 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

. /etc/rc.d/init.d/functions
source ~/global_directory.txt

PACKAGES_DIR=$GLOBAL_DIRECTORY/nagios_for_server
NAGIOS_CORE_VERSION=nagios-4.0.8
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15

function Prepare_Env {
    echo -e "\e[1;33mInstalling necessary softwares, please wait for a while...\e[0m"

    yum install mailx -y 
    yum install sendmail -y
    yum install lsof -y
    yum install gcc -y
    yum install glibc -y
    yum install glibc-common -y
    yum install httpd -y
    yum install php -y
    yum install php-gd -y
    yum install perl -y
    yum install mysql-devel -y
    yum install php-mysql -y
    yum install gd -y
    yum install gd-devel -y
    yum install openssl -y
    yum install openssl-devel -y
    yum install sysstat -y 
    yum install net-tools -y
    yum install ntp -y
    yum install ntpdate -y

    cd $PACKAGES_DIR/packages
    tar -xf libxml2-2.7.1.tar.gz -C /usr/local/src
    cd /usr/local/src/libxml2-2.7.1
    ./configure
    make
    make install
}

function Synchronizate_Time {
    echo -e "\e[1;33mSynchronizating time to Beijing's timezone, please wait for a while...\e[0m"
    timedatectl set-timezone Asia/Shanghai
    /usr/sbin/ntpdate time.nist.gov
    echo '#time sync'>>/var/spool/cron/root
    echo '*/10 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1'>>/var/spool/cron/root
    echo -e "\e[1;32mSynchronizate time finished.\e[0m"
}

function Configure_Firewall {
   echo -e "\e[1;33mConfiguring firewall...\e[0m"
   firewall-cmd --add-service=http        
   firewall-cmd --permanent --add-service=http
   firewall-cmd --reload

}

function Add_User {
    echo -e "\e[1;33mAdding user as nagios with group nagcmd...\e[0m"
    id nagios > /dev/null
    if [[ $? == 1 ]]; then
        useradd -m nagios
    fi
    cat /etc/group | grep nagcmd > /dev/null
    if [[ $? == 1 ]]; then
        groupadd nagcmd
        usermod -a -G nagcmd nagios
        usermod -a -G nagcmd apache
    fi
    echo -e "\e[1;32mAdding user finished.\e[0m"
}

function Install_Nagios {
    echo -e "\e[1;33mInstalling nagios...\e[0m"
    
    while true; do
        echo -n -e "\e[1;35mEnter the login name for nagios's website: \e[0m"
        read LOGIN_NAM
        echo -n -e "\e[1;35mEnter the login password for nagios's websit: \e[0m"
        read LOGIN_PASSWD
        echo -e "\e[1;36m+-------------Here is the information you enter-----------+
                Username for nagios's website : $LOGIN_NAM
                Password for nagios's website : $LOGIN_PASSWD
+---------------------------------------------------------+\e[0m"
        echo -n -e "\e[1;35mConfirm it? [y/n]: \e[0m"
        read CONFIRM
        if [[ $CONFIRM == y ]]; then
            break
        fi
    done
    
    
    #First of all, uninstall nagios.
    cd $PACKAGES_DIR/scripts
    sh uninstall_nagios.sh

    #Compile and install
    cd $PACKAGES_DIR/packages
    tar -xf $NAGIOS_CORE_VERSION.tar.gz -C /usr/local/src
    cd /usr/local/src/$NAGIOS_CORE_VERSION
    ./configure --with-command-group=nagcmd
    make all
    make install
    make install-init
    make install-config
    make install-commandmode
    make install-webconf

    htpasswd -bc /usr/local/nagios/etc/htpasswd.users $LOGIN_NAM $LOGIN_PASSWD
    echo -e "\e[1;32mNaigos installation complete.\e[0m"
}

function Install_Plugins {
    echo -e "\e[1;33mInstalling nagios's plugins...\e[0m"
    cd $PACKAGES_DIR/packages
    tar -xf $NAGIOS_PLUGIN_VERSION.tar.gz -C /usr/local/src
    cd /usr/local/src/$NAGIOS_PLUGIN_VERSION
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios
    make
    make install 
    systemctl enable nagios
    echo -e "\e[1;33mNagios's plugins installation complete.\e[0m"
} 

function Install_Nrpe {
    echo -e "\e[1;33mInstalling nrpe...\e[0m"
    cd $PACKAGES_DIR/packages
    tar -xf $NRPE_VERSION.tar.gz -C /usr/local/src
    cd /usr/local/src/$NRPE_VERSION

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
    echo -e "\e[1;32mNrpe installation complete.\e[0m"
}

function Configure_Nagios {
    echo -e "\e[1;33mConfiguring nagios...\e[0m"

    systemctl start nagios.service 
    
    #Active the xml configuration file
    cd $PACKAGES_DIR/scripts
    gcc -g nagios_configure.c -o nagios_configure -I /usr/local/include/libxml2/ -lxml2
    sh nagios_configure

    #Run each configuration script.
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

    echo -e "\e[1;32mNagios configuration complte\e[0m"
}

function Checkup {
    echo -e "\e[1;33mChecking nagios's running status...\e[0m"

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
    else
        action "Nagios service on: " /bin/false
    fi 

    echo -e "\e[1;32mNagios checking complete.\e[0m"
}

function Authorizate {
    echo -e "\e[1;33mAuthorizating to user...\e[0m"

    sed -i "s#nagiosadmin#$LOGIN_NAM#g" /usr/local/nagios/etc/cgi.cfg
    /etc/init.d/nagios reload
    systemctl restart nagios.service
    echo -e "\e[1;33mAuthorization complte.\e[0m"
}

#Call the functions
Prepare_Env
Synchronizate_Time
Configure_Firewall
Add_User
Install_Nagios
Install_Plugins
Install_Nrpe
Configure_Nagios
Checkup
Authorizate
