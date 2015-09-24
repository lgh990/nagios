
#安装说明
## 安装命令
+ 监控端的安装命令：wget -qO- https://raw.github.com/Kylinlin/nagios/master/setup_for_server.sh | sh -x
+ 被监控端的安装命令：wget -qO- https://raw.github.com/Kylinlin/nagios/master/setup_for_client.sh | sh -x

## 安装注意事项
+ 不管是在监控端还是被监控端安装，都会完整下载整个github仓库，实际上会浪费一些空间
+ 安装完成后，nagios会被安装在目录/usr/local下
+ 监控端安装完成后，还会在目录/usr/local下生成一个名为nagios_configure的目录（在被监控端不会生成该目录），在该目录中保存有重新配置nagios（不是重新安装）的全部脚本，所以可以删除克隆下来的github仓库
+ 


