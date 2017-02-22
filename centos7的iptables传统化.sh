# centos 7---7.2版本 iptables起不来的原因

# 一直用CentOS 6 习惯了，一下没适应过来。
# 防火墙配置后执行service iptables save 
# 出现”Failed to restart iptables.service: Unit iptables.service failed to load: No such file or directory.”
# 错误,在CentOS 7或RHEL 7或Fedora中防火墙由firewalld来管理，当然你可以还原传统的管理方式。
# 或则使用新的命令进行管理。
# 假如采用传统请执行一下命令：

systemctl stop firewalld
systemctl mask firewalld 

并且安装iptables-services：

yum install iptables-services
设置开机启动：
systemctl enable iptables

systemctl [stop|start|restart] iptables
#or
service iptables [stop|start|restart]
#保存规则
service iptables save

#or
/usr/libexec/iptables/iptables.init save
