如何搭建一个Spark基于Mesos集群，国外有个Mesosphere公司就基于Mesos做了一个数据中心控制和管理系统，官网上有很多详细mesos集成方案,我就是参考其中的Mesos+Spark方案，结果很多次失败，终于算是在各个节点上运行成功就写下了这边文档，已被大家参考快速学习。
操作系统

CentOS 7
JDK 1.6以上， 如：/usr/share/jdk1.7.0_45
修改节点名字

本次搭建Spark集群机器主从节点， 修改host（/etc/hosts）如下：
Hostname Ip 
Master  xd-ui   192.168.1.5
Slave 1 Xd-1    192.168.1.6
Slave 2 Xd-2    192.168.1.7
Slave 3 Xd-3    192.168.1.8

安装Mesosphere repo

sudo rpm -Uvh http://repos.mesosphere.io/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm 

下载Apache Mesos

wget http://downloads.mesosphere.io/master/centos/7/mesos-0.21.1-1.1.centos701406.x86_64.rpm
sudo rpm -Uvh mesos-0.21.1-1.1.centos701406.x86_64.rpm

安装Marathon

sudo yum -y install marathon

安装Chronos

sudo yum -y install chronos

配置Mesosphere master节点

quorum
设置：/etc/mesos-master/quorum内容： 1
目前个人理解Quorum主节点个数，类似hadoop临时主节点，大家有意见的可以反馈我。

Hostname
设置/etc/mesos-master/hostname为xd-ui 

Work_dir
设置/etc/mesos-master/work_dir为工作目前，默认为：/var/lib/mesos，我这里设置/alidata1/mesos

Zookeeper
设置/etc/mesos/zk为:zk://xd-1:2181,xd-2:2181,xd-3:2181/mesos
如何配置zookeeper 此处略，详细配置看zook配置文档

配置结构显示如下
[dev@xd-ui ~]$ tree /etc/mesos-master/
/etc/mesos-master/
├── hostname    -> xd-ui
├── quorum       -> 1
└── work_dir      -> /alidata1/mesos

重启Mesos Master:
[dev@xd-ui ~]$sudo service mesos-master restart

配置Mesosphere slave节点

Xd-1
配置各个节点的Slaves
[dev@spark-1 ~]$ tree /etc/mesos-slave/
/etc/mesos-slave/
├── hostname    xd-1
└── work_dir    /alidata1/mesos

Xd-2
配置各个节点的Slaves
[dev@spark-2 ~]$ tree /etc/mesos-slave/
/etc/mesos-slave/
├── hostname    xd-2
└── work_dir    /alidata1/mesos

Xd-3
配置各个节点的Slaves
[dev@spark-3 ~]$ tree /etc/mesos-slave/
/etc/mesos-slave/
├── hostname    xd-3
└── work_dir     /alidata1/mesos

在节点[xd-1，xd-2，xd-3]上重启各个Mesos Slaves:

[dev@xd-1 ~]$sudo service mesos-slave restart

检查各个节点是否起来

[dev@xd-ui ~]$sudo ps -ef | grep mesos 
/usr/sbin/mesos-slave --master=zk://xd-1:2181,xd-2:2181,xd-3:2181/mesos --log_dir=/var/log/mesos --hostname=xd-3 --work_dir=/alidata1/mesos

出现类似内容则启动正常
访问Mesosphere主页,确认各个节点是否正常

浏览器输入 http://xd-ui:5050/，点击slaves标签页就可以看到spark的web界面
