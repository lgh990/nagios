
#安装说明
## 安装命令

### 监控端
+ 运行安装命令来下载项目：wget -qO- https://raw.github.com/Kylinlin/nagios/master/setup_for_server.sh | sh -x
+ 在克隆下来的项目中，修改文件nagios/nagios_for_server/scripts/configure_nagios.xml中的配置选项，分别修改联系人信息和被监控端的信息，还有对服务的分级
+ 手动运行文件nagios/nagios_for_server/scripts/install_nagios.sh文件来进行安装
+ 在安装的开始要进行一次输入，输入你登陆nagios的web界面的账号信息

### 被监控端
+ 运行安装命令即可：wget -qO- https://raw.github.com/Kylinlin/nagios/master/setup_for_client.sh | sh -x

## 安装注意事项
+ 不管是在监控端还是被监控端安装，都会完整下载整个github仓库，实际上会浪费一些空间
+ 安装完成后，nagios会被安装在目录/usr/local下
+ 监控端安装完成后，还会在目录/usr/local下生成一个名为nagios_configure的目录（在被监控端不会生成该目录），在该目录中保存有重新配置nagios（不是重新安装）的全部脚本，所以可以删除克隆下来的github仓库
+ 


