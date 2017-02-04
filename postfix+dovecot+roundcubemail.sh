postfix+dovecot+roundcubemail

//参考文档 http://blog.csdn.net/air_penguin/article/details/47662941
//CentOS 7.2下搭的，和6似乎没区别。
//最大的区别是，CentOS 7默认不支持mysql了。需要自己下载安装。

1.添加DNS的记录
(1) A记录mail.music.cn，47.90.82.197
(2) MX记录 @ mail.music.cn

2.关闭防火墙
或者检查25，110，143，993，995等端口。

3.配置hostname
(1)#暂时绑定hosts
hostname mail.music.cn
(2)#修改network文件
vim /etc/sysconfig/network
HOSTNAME=mail.music.cn
(3)#添加本地hosts,而且要注释掉ipv6 ::1
127.0.0.1 localhost
#::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
10.26.51.15 iz
147.190.82.197 mail.music.cn

4.源,repo文件，直接用云提供商的

5.配置LAMP
yum -y install httpd mysql mysql-devel mysql-server php php-pecl-Fileinfo php-mcrypt php-devel php-mysql php-common php-mbstring php-gd php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc pcre pcre-devel

6.整合Apache和PHP
#修改配置文件
#vim /etc/httpd/conf/httpd.conf

#增加以下参数
AddType application/x-httpd-php .php 
PHPIniDir "/etc/php.ini"

#修改以下参数
DirectoryIndex index.php index.html index.html.var
User vmail
Group vmail

7.测试PHP
#新建测试PHP文件
#vim /var/www/html/index.php
<?php
        phpinfo();
?>
#重启Apache.注：打开浏览器，输入你的IP，看到PHP详细信息，LAMP环境OK.
/etc/init.d/httpd restart

8.安装配置postfixadmin
(1)#下载并改名并解压postfixadmin
	cd /var/www/html && wget http://nchc.dl.sourceforge.net/project/postfixadmin/postfixadmin/postfixadmin-2.92/postfixadmin-2.92.tar.gz && tar xvf postfixadmin-2.92.tar.gz  && mv postfixadmin-2.92 postfixadmin
(2)#提前安装dovecot，配置postfixadmin需要用到
	yum install -y  dovecot dovecot-devel dovecot-mysql
(3)#修改配置文件
	#备份配置文件
	cd /var/www/html/postfix && cp config.inc.php config.inc.php.bak && cp setup.php setup.php.bak 

#修改配置文件中以下参数
vim config.inc.php
$CONF['configured'] = true;
$CONF['database_type'] = 'mysql';
$CONF['database_host'] = 'localhost';
$CONF['database_user'] = 'postfix';
$CONF['database_password'] = 'postfix';
$CONF['database_name'] = 'postfix';
$CONF['admin_email'] = 'postmaster@sst888.com';
$CONF['encrypt'] = 'dovecot:CRAM-MD5';
$CONF['dovecotpw'] = "/usr/bin/doveadm pw";
$CONF['domain_path'] = 'YES';
$CONF['domain_in_mailbox'] = 'NO';
$CONF['aliases'] = '1000';
$CONF['mailboxes'] = '1000';
$CONF['maxquota'] = '1000';
$CONF['fetchmail'] = 'NO';
$CONF['quota'] = 'YES';
$CONF['used_quotas'] = 'YES';
$CONF['new_quota_table'] = 'YES';

(4)安装mysql
#Centos 7 comes with MariaDB instead of MySQL. MariaDb is a open source equivalent to MySQL and can be installed with yum -y install mariadb-server mariadb. If you must have mysql you need to add the mysql-community repo sudo rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm and then you can install MySQLl like you normally do.

rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
yum install mysql-server

(5)mysql建库、授权
#Mysql中建库并授权,后面配置都需要于现在授权信息一致
/etc/init.d/mysqld start 
mysql
mysql> create database postfix;
mysql> grant all on postfix.* to postfix@'localhost' identified by 'postfix';
mysql> flush privileges;

#测试能否登录
mysql -upostfix -ppostfix

#修改所有者和所有组
chown -R vmail.vmail /var/www/html/postfixadmin/
chown -R vmail.vmail /var/lib/php/session/

(6)登陆页面配置postfixadmin
#这个密码需要再改一下
$CONF['database_password'] = 'postfix';
#这个过程只是初始化，设置超管的权限等。

9.安装、配置postfix
(1) #yum安装postfix
yum remove -y sendmail && yum install postfix
(2)修改配置
#vim /etc/postfix/main.cf
#修改以下参数
myhostname = mail.free.com
mydomain = free.com
myorigin = $mydomain
inet_interfaces = all
mynetworks_style = host
mynetworks = 192.168.18/24, 127.0.0.0/8

#添加以下参数
#虚拟域名配置
virtual_mailbox_domains = proxy:mysql:/etc/postfix/mysql_virtual_domains_maps.cf
virtual_alias_maps = proxy:mysql:/etc/postfix/mysql_virtual_alias_maps.cf
virtual_mailbox_maps = proxy:mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf
# Additional for quota support
virtual_create_maildirsize = yes
virtual_mailbox_extended = yes
virtual_mailbox_limit_maps = mysql:/etc/postfix/mysql_virtual_mailbox_limit_maps.cf
virtual_mailbox_limit_override = yes
virtual_maildir_limit_message = Sorry, this user has exceeded their disk space quota, please try again later.
virtual_overquota_bounce = yes
#Specify the user/group that owns the mail folders. I'm not sure if this is strictly necessary when using Dovecot's LDA.
virtual_uid_maps = static:2000
virtual_gid_maps = static:2000
#Specifies which tables proxymap can read: http://www.postfix.org/postconf.5.html#proxy_read_maps
proxy_read_maps = $local_recipient_maps $mydestination $virtual_alias_maps $virtual_alias_domains $virtual_mailbox_maps $virtual_mailbox_domains $relay_recipient_maps $relay_domains $canonical_maps $sender_canonical_maps $recipient_canonical_maps $relocated_maps $transport_maps $mynetworks $virtual_mailbox_limit_maps
#SASL SUPPORT FOR CLIENTS
# Turns on sasl authorization
smtpd_sasl_auth_enable = yes
#Use dovecot for authentication
smtpd_sasl_type = dovecot
# Path to UNIX socket for SASL
smtpd_sasl_path = /var/run/dovecot/auth-client
#Disable anonymous login. We don't want to run an open relay for spammers.
smtpd_sasl_security_options = noanonymous
#Adds support for email software that doesn't follow RFC 4954.
#This includes most versions of Microsoft Outlook before 2007.
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions =  permit_sasl_authenticated, permit_mynetworks, reject_unauth_destination
# TRANSPORT MAP
virtual_transport = dovecot
dovecot_destination_recipient_limit = 1

(5)#vim /etc/postfix/master.cf
#注意flags前面的空格
dovecot   unix  -       n       n       -       -       pipe
  flags=DRhu user=vmail:vmail argv=/usr/libexec/dovecot/dovecot-lda -f ${sender} -d ${recipient}

(6) 创建mysql脚本
#请注意user password dbname 要和上面配置postfixadmin中授权的一致。

#vim /etc/postfix/mysql_virtual_domains_maps.cf
user = postfix
password = postfix
hosts = localhost
dbname = postfix
query = SELECT domain FROM domain WHERE domain='%s' AND active = '1'
#optional query to use when relaying for backup MX
#query = SELECT domain FROM domain WHERE domain='%s' AND backupmx = '0' AND active = '1'

# vim /etc/postfix/mysql_virtual_alias_maps.cf
user = postfix
password = postfix
hosts = localhost
dbname = postfix
query = SELECT goto FROM alias WHERE address='%s' AND active = '1'

#vim /etc/postfix/mysql_virtual_mailbox_maps.cf
user = postfix
password = postfix
hosts = localhost
dbname = postfix
query = SELECT CONCAT(domain,'/',maildir) FROM mailbox WHERE username='%s' AND active = '1'

#vim /etc/postfix/mysql_virtual_mailbox_limit_maps.cf
user = postfix
password = postfix
hosts = localhost
dbname = postfix
query = SELECT quota FROM mailbox WHERE username='%s' AND active = '1'

10.配置dovecot
(1) 前面已经安装
(2) 修改配置文件,原文件基础上修改

#vim /etc/dovecot/dovecot.conf
protocols = imap pop3
listen = *
dict {
  quota = mysql:/etc/dovecot/dovecot-dict-sql.conf.ext
}
!include conf.d/*.conf

#vim /etc/dovecot/conf.d/10-auth.conf
disable_plaintext_auth = no
auth_mechanisms = plain login cram-md5
!include auth-sql.conf.ext

#vim /etc/dovecot/conf.d/10-mail.conf
mail_location = maildir:%hMaildir
mbox_write_locks = fcntl

#vim /etc/dovecot/conf.d/10-master.conf
service imap-login {
  inet_listener imap {
  }
  inet_listener imaps {
  }
}
service pop3-login {
  inet_listener pop3 {
  }
  inet_listener pop3s {
  }
}
service lmtp {
  unix_listener lmtp {
  }
}
service imap {
}
service pop3 {
}
service auth {
  unix_listener auth-userdb {
    mode = 0600
    user = vmail
    group = vmail
  }
#新加下面一段，为smtp做认证
  unix_listener auth-client {
    mode = 0600
    user = postfix
    group = postfix
  }
}
service auth-worker {
}
service dict {
  unix_listener dict {
    mode = 0600
    user = vmail
    group = vmail
  }
}

#vim /etc/dovecot/conf.d/15-lda.conf
protocol lda {
  mail_plugins = quota
  postmaster_address = postmaster@sst888.com #管理员邮箱
}

#vim /etc/dovecot/conf.d/20-imap.conf
protocol imap {
        mail_plugins = quota imap_quota
}

#vim /etc/dovecot/conf.d/20-pop3.conf
protocol pop3 {
  pop3_uidl_format = %08Xu%08Xv
  mail_plugins = quota
}

#vim /etc/dovecot/conf.d/90-quota.conf
plugin {
  quota_rule = *:storage=1G
}
plugin {
}
plugin {
  quota = dict:User quota::proxy::quota
}
plugin {
}

(3) 添加文件

#vim /etc/dovecot/dovecot-sql.conf.ext
driver = mysql
connect = host=localhost dbname=postfix user=postfix password=postfix
default_pass_scheme = CRAM-MD5
user_query = SELECT CONCAT('/var/vmail/', maildir) AS home, 2000 AS uid, 2000 AS gid, CONCAT('*:bytes=', quota) as quota_rule FROM mailbox WHERE username = '%u' AND active='1'
password_query = SELECT username AS user, password, CONCAT('/var/vmail/', maildir) AS userdb_home, 2000 AS userdb_uid, 2000 AS userdb_gid, CONCAT('*:bytes=', quota) as userdb_quota_rule FROM mailbox WHERE username = '%u' AND active='1'

#vim /etc/dovecot/dovecot-dict-sql.conf.ext
connect = host=localhost dbname=postfix user=postfix password=postfix
map {
  pattern = priv/quota/storage
  table = quota2
  username_field = username
  value_field = bytes
}
map {
  pattern = priv/quota/messages
  table = quota2
  username_field = username
  value_field = messages
}

11.新建域和测试用户，不见不得行
测试SMTP和POP3
#telnet localhost smtp
#telnet localhost pop3

12.配置roundcubemail
(1) 安装
# 下载解压并改名
cd /var/www/html &&wget https://downloads.sourceforge.net/project/roundcubemail/roundcubemail/1.0.6/roundcubemail-1.0.6.tar.gz && tar xvf roundcubemail-1.0.6.tar.gz && mv roundcubemail-1.0.6/ webmail

(2)
#更改时区
#vim /etc/php.ini
date.timezone = Asia/Shanghai

#更改所有者所有组
chown vmail.vmail -R /var/www/html/webmail/

#重启Apache
/etc/init.d/httpd restart

# Mysql授权，稍后配置需要用到
# mysql
mysql> CREATE DATABASE roundcubemail;
mysql> GRANT ALL PRIVILEGES ON roundcubemail.* TO roundcubemail@localhost IDENTIFIED BY 'roundcubemail';
mysql> FLUSH PRIVILEGES;
