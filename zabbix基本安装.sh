zabbix3.2 install
#zabbix3.2的版本是最新的，但是官方支持的时间不长。正式环境下安装建议要选择个长时间支持的版本。
#基本的安装流程如下，海外的机器装的。
1.下载源码
wget wget http://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/3.2.1/zabbix-3.2.1.tar.gz

2.添加zabbix用户
groupadd zabbix
useradd -g zabbix zabbix

3.安装相关软件
yum -y install gcc-c++ autoconf httpd mysql mysql-server php-mysql httpd-manual mod_ssl mod_perl mod_auth_mysql php-gd php-xml php-mbstring php-ldap php-pear php-xmlrpc php-bcmath mysql-connector-odbc mysql-devel libdbi-dbd-mysql net-snmp-devel curl-devel unixODBC-devel OpenIPMI-devel java-devel
yum install php-mysql php-gd php-xml php-mbstring php-ldap php-pear php-xmlrpc php-bcmath

4.创建数据库,赋权限
create database zabbix character set utf8; 
insert into mysql.user(Host,User,Password) values('localhost','zabbix',password('zabbix_yzh123'));
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix_yzh123';
flush privileges; 
grant all on zabbix.* to 'zabbix'@'localhost' identified by 'zabbix_yzh123' with grant option;

5.导入表结构
source /root/yzh/zabbix-3.2.1/database/mysql/schema.sql 
source /root/yzh/zabbix-3.2.1/database/mysql/images.sql
source /root/yzh/zabbix-3.2.1/database/mysql/data.sql

6.配置文件修改
Zabbix
zabbix-agent 10050/tcp # Zabbix Agent
zabbix-agent 10050/udp # Zabbix Agent
zabbix-trapper 10051/tcp # Zabbix Trapper
zabbix-trapper 10051/udp # Zabbix Trapper

7.辅助操作
chmod +x /etc/rc.d/init.d/zabbix_server #添加脚本执行权限
chmod +x /etc/rc.d/init.d/zabbix_agentd #添加脚本执行权限
chkconfig zabbix_server on #添加开机启动
chkconfig zabbix_agentd on #添加开机启动

8.apache配置修改
AddType application/x-httpd-php .php 
AddType application/x-httpd-php-source .phps 
AddType application/x-httpd-php .php3 

9.报警脚本设置
#指定脚本位置
 /etc/zabbix/alertscripts
AlertScriptsPath=/etc/zabbix/alertscripts
#sendmail.sh
#!/bin/bash
echo "$3" | mutt -s "$2" $1
echo $3 $2 $1 >/var/log/aaa.log

10.msmtprc
account acc2
host smtp.qq.com
port 465
from 123456@qq.com
auth login
tls_starttls off
tls on
tls_certcheck off
user 123456@qq.com
password mypasswd
account default : acc2

11.Muttrc
set sendmail="/usr/local/msmtp/bin/msmtp"
set use_from=yes
set realname="monitor@llllll.com"
set editor="vim"
set copy=no

12.linux客户端安装
mkdir -p /root/yzh/
cd /root/yzh
wget http://xxx.com/security/zabbix-2.4.4.tar.gz
groupadd zabbix
useradd -g zabbix zabbix
cd /root/yzh
tar -zvxf zabbix-2.4.4.tar.gz
cd /root/yzh/zabbix-2.4.4
echo 'ok'
./configure --enable-agent && make install
make install
cp /root/yzh/zabbix-2.4.4/misc/init.d/fedora/core/zabbix_agentd /etc/rc.d/init.d/zabbix_agentd
chmod a+x /etc/init.d/zabbix_*
sed -i 's/\(Server=\)\S\S*/\1120.127.145.159/' /usr/local/etc/zabbix_agentd.conf
echo ok
#开机自启动
chkconfig zabbix_agentd on

13.windows客户端
(1).cmd以管理员身份运行[下面是一行，真TMD坑！]
C:\zabbix_agents_2.4.4.win\bin\win64\zabbix_agentd.exe --config C:\zabbix_agents_2.4.4.win\conf\zabbix_agentd.win.conf --install
(2).修改配置文件
Server=IP of Zabbix Server
ServerActive=IP of Zabbix Server
Hostname=use the FQDN of your windows host
(3).C:\zabbix_agents_2.4.4.win\bin\win64\zabbix_agentd.exe --start

14.注意事项
报警设置会端口和域名，25在国外被封，国内外域名不一致。
PHP的环境要大于5.6以上。
日志老化的时间要适当，时间长了IO很高。如果不想清表，就要及时老化。
zabbix调试的时候可以打出日志，按照等级输出日志。

15.监控项、动作和触发器等日后再补充



16.动作没效果的原因
新建的主机群组，关联了模板。但是触发后没有动作，也就是没有发邮件。
其原因是，zabbix“用户组”的“许可”对新加进来的模板默认是“拒绝”。把新的群组模板加入到用户组许可里就OK。
