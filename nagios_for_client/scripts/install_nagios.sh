#!/bin/bash
###############################################################
#File Name      :   install_nagios.sh
#Arthor         :   kylin
#Created Time   :   Thu 24 Sep 2015 04:35:57 PM CST
#Email          :   kylinlingh@foxmail.com
#Blog           :   http://www.cnblogs.com/kylinlin/
#Github         :   https://github.com/Kylinlin
#Version        :
#Description    :
###############################################################

. /etc/rc.d/init.d/functions
source ~/global_directory.txt

NAGIOS_INSTALL_DIR=/usr/local
PACKAGES_DIR=$GLOBAL_DIRECTORY/nagios_for_client

NAGIOS_CORE_VERSION=nagios-4.0.8
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.0.3
NRPE_VERSION=nrpe-2.15
NRPE_VERSION_CHECK="NRPE v2.15"

NRPE_CFG=$NAGIOS_INSTALL_DIR/nagios/etc/nrpe.cfg

function Get_Informations {
    echo -n -e "\e[1;35mEnter the ip address for your remote server: \e[0m"
    read HOST_ADDRESS
}

function Prepare_Env {
    echo -e "\e[1;33mInstall necessary tools.\e[0m"

    yum install net-tools -y > /dev/null
    yum install lsof -y > /dev/null
    yum install gcc -y > /dev/null
    yum install glibc -y > /dev/null
    yum install glibc-common -y > /dev/null
    yum install gd -y > /dev/null
    yum install gd-devel -y > /dev/null
    yum install openssl -y > /dev/null
    yum install openssl-devel -y > /dev/null
    yum install sysstat -y > /dev/null
    yum install ntp -y > /dev/null
    yum install ntpdate -y > /dev/null
}

function Synchronize_Time {
    echo -e "\e[1;33mSynchronizating time to Beijing's timezone...\e[0m"
    timedatectl set-timezone Asia/Shanghai > /dev/null
    /usr/sbin/ntpdate time.nist.gov > /dev/null
    echo '#time sync'>>/var/spool/cron/root
    echo '*/10 * * * * /usr/sbin/ntpdate time.nist.gov >/dev/null 2>&1'>>/var/spool/cron/root
    echo -e "\e[1;32mSynchronizate time finished.\e[0m"
}

function Configure_Firewall {
    echo -e "\e[1;33mConfigure firewall\e[0m"
    firewall-cmd --add-service=http > /dev/null
    firewall-cmd --permanent --add-service=http > /dev/null
    firewall-cmd --zone=public --add-port=5666/tcp --permanent > /dev/null
    firewall-cmd --reload > /dev/null
}

function Add_User {
    echo -e "\e[1;33mAdd user: nagios\e[0m"
    id nagios
    if [[ $? == 1 ]]; then
        useradd -s /sbin/nologin nagios
    fi
}

function Install_Nagios {
    cd $PACKAGES_DIR/scripts
    sh uninstall_nagios.sh
    echo -e "\e[1;33mInstall plugins for nagios\e[0m"
    cd $PACKAGES_DIR/packages
    tar -xf $NAGIOS_PLUGIN_VERSION.tar.gz -C /usr/local/src > /dev/null
    cd /usr/local/src/$NAGIOS_PLUGIN_VERSION
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios > /dev/null
    make > /dev/null
    make install > /dev/null
}

function Install_Nrpe {
    echo -e "\e[1;33mInstall nrpe\e[0m"
    cd $PACKAGES_DIR/packages
    tar -xf $NRPE_VERSION.tar.gz -C /usr/local/src
    cd /usr/local/src/$NRPE_VERSION
    ./configure --with-nrpe-user=nagios \
     --with-nrpe-group=nagios \
     --with-nagios-user=nagios \
     --with-nagios-group=nagios \
     --enable-command-args \
     --enable-ssl > /dev/null
    
    make all > /dev/null
    make install-plugin > /dev/null
    make install-daemon > /dev/null
    make install-daemon-config > /dev/null
}

function Write_Script_For_Nrpe {
    echo -e "\e[1;33mWrite scripts for nrpe\e[0m"
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

}

function Configure_Nagios {
    echo -e "\e[1;33mConfigure nagios\e[0m"
    if [[ -f $NRPE_CFG.bak ]]; then
        rm -f $NRPE_CFG
        mv $NRPE_CFG.bak $NRPE_CFG
    else
        cp $NRPE_CFG $NRPE_CFG.bak
    fi
    
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

    cd $PACKAGES_DIR/scripts
    sh install_plugins.sh

}

function Startup {
    echo -e "\e[1;33mStartup nrpe\e[0m"
    $NAGIOS_INSTALL_DIR/nagios/bin/nrpe -c $NRPE_CFG -d
    systemctl restart nrpe.service > /dev/null

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
    else
        action "Nrpe version check: " /bin/false
    fi

}

Get_Informations
Prepare_Env
Synchronize_Time
Add_User
Configure_Firewall
Install_Nagios
Install_Nrpe
Write_Script_For_Nrpe
Configure_Nagios
Startup