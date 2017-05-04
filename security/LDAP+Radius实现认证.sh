CentOS 7.3环境下，LDAP和Radius的版本都有大的变化。
网上可借鉴的配置比较少了。


radius client.conf定义了客户端的IP，以及密码，使得他们可以访问radius。
192.168.0.0/24
radtest ops1 123456 172.16.249.7 0 testing123-1

192.168.0.0/24
radtest ops1 123456 172.16.249.7 0 testing123-2


值得一提的是，在软件目录结构，实现架构，radius值得学习
配置，模块分离，可用，不可用都分离，还有完善的工具包，freeradius-utils
