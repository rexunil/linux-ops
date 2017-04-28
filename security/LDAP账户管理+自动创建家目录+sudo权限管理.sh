
//freeipa也值得研究

 一：server端
安装LDAP：
# yum install openldap-servers
 cp /usr/share/openldap-servers/slapd.conf.obsolete /etc/openldap/slapd.conf
得到ldap管理帐号的密码，下面会把这个密码加入slapd.conf的rootpw：
# slappasswd
New password:
Re-enter new password:
{SSHA}L19zkWmhL8zXnKfLDetVAwXt3Lm7qBOa

修改slapd.conf：
# vi /etc/openldap/slapd.conf
...
include         /etc/openldap/schema/nis.schema
......
suffix          "dc=hanborq,dc=com"
rootdn          "cn=Manager,dc=hanborq,dc=com"
...
rootpw                  {SSHA}L19zkWmhL8zXnKfLDetVAwXt3Lm7qBOa
...
access to attrs=shadowLastChange,userPassword
      by self write
      by * auth
access to *
      by * read
...


默认DB配置：
# cp /etc/openldap/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
删除默认/etc/openldap/slapd.d下面的所有内容，否则后面在使用ldapadd的时候会报错：
# rm -rf /etc/openldap/slapd.d/*

增加LOG：
# echo "local4.* /var/log/slapd.log" >> /etc/syslog.conf
# service syslog restart


启动：
# service ldap restart
# chkconfig slapd on
赋予配置目录相应权限：
# chown -R ldap:ldap /var/lib/ldap
# chown -R ldap:ldap /etc/openldap/

测试并生成配置文件：
slaptest  -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
返回config file testing succeeded,则配置成功。
赋予生成的配置文件予权限并重启：
# chown -R ldap:ldap /etc/openldap/slapd.d
# chmod 755 /etc/openldap/slapd.d/
# service slapd restart


安装配置migrationtools
# yum install migrationtools -y


进入migrationtool配置目录
# cd /usr/share/migrationtools/
首先编辑migrate_common.ph（70-74行，自己看，不列出）
下面利用pl脚本将/etc/passwd 和/etc/shadow生成LDAP能读懂的文件格式，保存在/tmp/下
# ./migrate_base.pl > /tmp/base.ldif
# ./migrate_passwd.pl  /etc/passwd > /tmp/passwd.ldif
# ./migrate_group.pl  /etc/group > /tmp/group.ldif

下面就要把这三个文件导入到LDAP，这样LDAP的数据库里就有了我们想要的用户
# ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f /tmp/base.ldif
# ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f /tmp/passwd.ldif
# ldapadd -x -D "cn=admin,dc=example,dc=com" -W -f /tmp/group.ldif
过程若无报错，则LDAP服务端配置完毕
这里的-x表示简单鉴权，-W为提醒输入口令。
重启slapd完成配置
# service slapd restart

检查一下：
# ldapsearch -x -b "dc=hanborq,dc=com"
可以看到所有用户和组都加入了。

URL方式检查：
非加密方式：
# ldapsearch -v -x -H ldap://nd0-rack2-cloud


二、客户端配置：
安装nss-pam-ldapd
修改所有/etc/hosts文件，把服务端ip和域名相对应
下面的配置最好使用setup命令来配置。
修改/etc/sysconfig/authconfig：
"USELDAP=yes"
"USELDAPAUTH=yes"   
"USEMD5=yes"         
"USESHADOW=yes"  
"USELOCAUTHORIZE=yes"
FORCELEGACY=no（非加密方式修改为yes，若使用TLS修改为no）
修改/etc/openldap/ldap.conf：（centos 6.x可以不修改这个文件，亲测）
centos6.x 修改/etc/pam_ldap.conf和/etc/nslcd.conf
# vi /etc/pam_ldap.conf
host nd0-rack2-cloud（可以注释掉）
base dc=hanborq,dc=com
uri ldap://nd0-rack2-cloud（使用服务端的主机名）

CentOS6.x需要配置/etc/nslcd.conf：
# vi /etc/nslcd.conf
uri ldap://nd0-rack2-cloud
base dc=hanborq,dc=com

修改NSS:
# vi /etc/nsswitch.conf
...
passwd:     files ldap
shadow:     files ldap
group:      files ldap
...
netgroup:   files ldap
...
automount:  files ldap
...

修改系统鉴权：
# vi /etc/pam.d/system-auth和/etc/pam.d/password-auth
auth        requisite     pam_succeed_if.so uid >= 500 quiet
auth        sufficient    pam_ldap.so use_first_pass
...
account     sufficient    pam_succeed_if.so uid < 500 quiet
account     [default=bad success=ok user_unknown=ignore] pam_ldap.so
...
password    sufficient    pam_unix.so md5 shadow nullok try_first_pass use_authtok
password    sufficient    pam_ldap.so use_authtok
...
session     required      pam_unix.so
session     optional      pam_ldap.so

重启nslcd服务
三、用户登录自动创建家目录
服务端：
安装：openssh-ldap
拷贝：cp /usr/share/doc/openssh-ldap-5.3p1/openssh-lpk-openldap.schema /etc/openldap/schema
修改slapd.conf：
include         /etc/openldap/schema/openssh-lpk-openldap.schema
客户端：
安装oddjob-mkhomedir、oddjob、openssh-ldap
# yum install -y oddjob-mkhomedir oddjob openssh-ldap
# chkconfig oddjobd on
# service messagebus start
Starting system message bus: [ OK ]
# service oddjobd start
Starting oddjobd: [ OK ]
# authconfig --enablemkhomedir --update
Starting oddjobd: [ OK ]
修改客户端sshd_config
AuthorizedKeysCommand /usr/libexec/openssh/ssh-ldap-wrapper
手动添加/etc/pam.d/password-auth和system-auth
session     optional      pam_oddjob_mkhomedir.so umask=0077
重启sshd
重启 nslcd
四、添加sudo权限
服务端：
cp /usr/share/doc/sudo-1.8.6p3/schema.OpenLDAP /etc/openldap/schema/sudo.schema
然后include进/etc/openldap/slapd.conf
再执行一次slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d
重启slapd
Client端：
修改/etc/sudo-ldap.conf
uri ldap://manager.abc.com
sudoers_base dc=abc,dc=com
修改/etc/nsswitch.conf
sudoers:    files ldap
关于sudo.ldif的配置，个人觉得首先你得对sudoers的配置相当了解，然后结合ldap的格式操作即可，了解清楚了，就很好操作：

五、常规操作
1、导入时，执行：
# ldapadd -x -h 192.168.1.10 -D 'cn=admin,dc=test,dc=com' -W -f info.ldif

ldapadd 命令各参数含义如下：
-x 为使用简单密码验证方式
-D 指定管理员DN（与slapd.conf中一致）
-W 为管理员密码，可以使用-w password 直接输入密码
-f 为初始化数据LDIF的文件名
-h 为操作的服务器IP地址
2、搜索操作：
# ldapsearch -x -b 'dc=test,dc=com'
3、修改操作：
其实也可以使用文件进行批量修改，我们只要把需要修改信息写入文件即可，比如：
dn: uid=ldapuser1,ou=People,dc=test,dc=com
changetype: modify
replace: uidNumber
uidNumber: 1000
把以上内容写入test.ldif中，运行如下命令：
ldapmodify -x -D "cn=admin,dc=test,dc=com" -w yourpasswd -f test.ldif
4、删除操作
删除时，给出DN即可：
# ldapdelete -x -D 'cn=admin,dc=test,dc=com' -w yourpasswd -r 'dc=test,dc=com'
-r 表示以递归模式删除，即删除该节点下面的所有子节点。
