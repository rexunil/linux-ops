###基本介绍和使用

1.简介
ansible基于Python开发，集合了众多运维工具（puppet、cfengine、chef、func、fabric）的优点，
实现了批量系统配置、批量程序部署、批量运行命令等功能。ansible是基于模块工作的，
本身没有批量部署的能力。真正具有批量部署的是ansible所运行的模块，ansible只是提供一种框架。
类似于jenkins一样，也是个框架。主要包括：
(1)、连接插件connection plugins：负责和被监控端实现通信；
(2)、host inventory：主机清单。指定操作的主机，是一个配置文件里面定义监控的主机；
(3)、各种模块核心模块、command模块、自定义模块；
(4)、借助于插件完成记录日志邮件等功能；
(5)、playbook：剧本执行多个任务时，非必需可以让节点一次性运行多个任务。

2.特性
(1)、no agents：不需要在被管控主机上安装任何客户端；
(2)、no server：无服务器端，使用时直接运行命令即可；
(3)、modules in any languages：基于模块工作，可使用任意语言开发模块；
(4)、yaml，not code：使用yaml语言定制剧本playbook；
(5)、ssh by default：基于SSH工作；新版本都是基于密钥来进行了。
(6)、strong multi-tier solution：可实现多级指挥。

3.优点
(1)、轻量级，无需在客户端安装agent，更新时，只需在操作机上进行一次更新即可；
(2)、批量任务执行可以写成脚本，而且不用分发到远程就可以执行；
(3)、使用python编写，维护更简单；
(4)、支持sudo。

4.有用的文章
http://sofar.blog.51cto.com/353572/1579894/
http://www.axiaoxin.com/article/167/
http://getansible.com/

5.安装
pip install ansible   or
sudo easy_install ansible
按照过程会自动装一些其他的包
Installing collected packages: MarkupSafe, jinja2, PyYAML, ansible
如果报gcc的错误，不一定是gcc没装。如下操作一下就OK。要装openssl。
yum install gcc libffi-devel python-devel openssl-devel

6.配置项
配置项-----ansible.cfg。主机清单host inverntory
ansible执行的时候会按照以下顺序查找配置项(python都这德行，没有自己建吧)
* ANSIBLE_CONFIG (环境变量)
* ansible.cfg (当前目录下)
* .ansible.cfg (用户家目录下)
* /etc/ansible/ansible.cfg

# /etc/ansible/hosts是默认路径
sudo mkdir /etc/ansible
sudo vi /etc/ansible/hosts

hosts文件很重要，是机器列表。也可以放用户家目录下。
[v1]
192.168.1.134
[v2]
192.168.10.202:12321  #若非202端口时，记得这样。

ansible -i hosts all -m ping 
ansible -i hosts all -a 'who'    # -i 是指定hosts文件吧，默认TMD会去/etc/ansible/下查找！
								 # [WARNING]: Host file not found: /etc/ansible/hosts

7.客户机和ansible机器如何建立信任关系？相同的用户和密码？
还是直接把ansible机器的pub证书丢上去？怎么丢比较方便呢？困扰我。本机22端口时无需操作可以执行。
saltstack是安装了客户端，两者之间会传输证书，这个很好理解。

哈哈，果然是这样的。ansible的ssh证书管理是个蛋疼的问题。
ansible为了避免证书的外泄，开发了个商业版的ansible tower,证书全部在tow存放，ops不能移动和查看。
主机少于10台就免费。多了要买许可。

//免密码的SSH连接，这个还是要的！用户规划好。
$ # 生成ssh key
$ ssh-keygen
$ # 拷贝ssh key到远程主机，ssh的时候就不需要输入密码了
$ ssh-copy-id remoteuser@remoteserver
$ # ssh的时候不会提示是否保存key
$ ssh-keyscan remote_servers >> ~/.ssh/known_hosts

客户机不需要特别的。只要求python > 2.4 一般默认是支持的。

8.ad-hoc 临时执行命令，本意是点对点的意思。就是无需保存的快速执行shell命令。
官方称，Ad-Hoc Commands，以前基本就干这个了。
（1）、检查ansible安装环境
检查所有的远程主机，是否以bruce用户创建了ansible主机可以访问的环境。
$ansible all -m ping -u bruce
（2）、执行命令
在所有的远程主机上，以当前bash的同名用户，在远程主机执行“echo bash”
$ansible all -a "/bin/echo hello"
$ansible all -a "/bin/echo hello" -u root #以root用户执行。
（3）、拷贝文件
拷贝文件/etc/host到远程主机（组）web，位置为/tmp/hosts
$ ansible web -m copy -a "src=/etc/hosts dest=/tmp/hosts"
（4）、安装包
远程主机（组）web安装yum包acme
$ ansible web -m yum -a "name=acme state=present"
（5）、添加用户
$ ansible all -m user -a "name=foo password=<crypted password here>"
（6）、下载git包
$ ansible web -m git -a "repo=git://foo.example.org/repo.git dest=/srv/myapp version=HEAD"
（7）、启动服务
$ ansible web -m service -a "name=httpd state=started"
（8）、并行执行
启动10个并行进行执行重起，-f并行数
$ansible lb -a "/sbin/reboot" -f 10

