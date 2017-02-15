#L2TPD，CentOS 7.2下可行。CentOS6.4下也无特别之处
# BY yzh
# MAIL:yue232@163.com
# Date:2016-08-25


yum install -y gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced man
yum install openswan ppp xl2tpd

lsof -i:1701

配置
rm -rf /etc/ipsec.conf
touch /etc/ipsec.conf
cat >>/etc/ipsec.conf <<EOF
config setup
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
    oe=off
    protostack=netkey

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    type=transport
    left=47.190.82.122
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
EOF

vim /etc/sysctl.conf
在/etc/sysctl.conf的末尾加上如下内容。
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.log_martians = 0
net.ipv4.conf.default.log_martians = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.icmp_ignore_bogus_error_responses = 1

sysctl -p 确认
ipsec restart ipsec确认
ipsec verify

预密钥
echo "47.190.82.122 %any: PSK \"Comvpn\"" >/etc/ipsec.d/l2tp.secrets

修改xl2tpd.conf
[global]
listen-addr = $your_vps_ip #替换成你的vpsip
ipsec saref = yes
[lns default]
ip range = 192.168.30.10-192.168.30.20
local ip = 192.168.30.1
require chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes


记录日志
ip-up
echo "Start_Time: `date -d today +%F_%T`" >> /var/log/xl2tpd.log 
echo "username: $PEERNAME" >> /var/log/xl2tpd.log
ip-down
echo "Stop_Time: `date -d today +%F_%T`" >> /var/log/xl2tpd.log
echo "username: $PEERNAME" >> /var/log/xl2tpd.log



修改options.xl2tpd

#require-pap
#require-chap
#require-mschap
ipcp-accept-local
ipcp-accept-remote
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
mtu 1400
noccp
connect-delay 5000
# To allow authentication against a Windows domain EXAMPLE, and require the
# user to be in a group "VPN Users". Requires the samba-winbind package
# require-mschap-v2
# plugin winbind.so
# ntlm_auth-helper '/usr/bin/ntlm_auth --helper-protocol=ntlm-server-1 --require-membership-of="EXAMPLE\VPN Users"'
# You need to join the domain on the server, for example using samba:
# http://rootmanager.com/ubuntu-ipsec-l2tp-windows-domain-auth/setting-up-openswan-xl2tpd-with-native-windows-clients-lucid.html

vim /etc/ppp/chap-secrets
添加用户，密码
  

阿里云清空iptables即可，需要这个命令
iptables -t nat -A POSTROUTING -o eth1 -s 172.29.29.0/24 -j MASQUERADE

自启动
chkconfig xl2tpd on
chkconfig iptables on
chkconfig ipsec on


开启xl2tpd的debug模式
xl2tpd -D


翻墙规则如下【有两个密码，请区别】：

服务器：vpn.iCom.cn
个人账号和密码保持不变。
共享密钥：Comvpn


windows下链接L2TP的vpn教程
http://jingyan.baidu.com/article/fdbd427713f4a2b89f3f487b.html
MAC OS 下链接L2TP的vpn教程
http://jingyan.baidu.com/article/22a299b53c38b69e19376a17.htm


service ipsec restart
service xl2tpd restart


用下面两个操作帮朋友排过错
1.net.ipv4.ip_forward = 1
2.iptables -t nat -A POSTROUTING -o eth1 -s 192.168.30.0/24 -j MASQUERADE
