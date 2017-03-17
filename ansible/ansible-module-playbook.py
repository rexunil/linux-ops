9.尽管ansible通过命令可以进行批量执行了，对于一台主机一台主机的管理来说是个质的飞跃。
但是每次敲N多相同的命令去执行一个相同任务是一个痛苦的事。于是就有playbook的说法。
剧本，大家都按照剧本action。要执行啥，把剧本下发就OK了。

10.playbook格式是yaml，或者yml.格式和json类似。也称为ansible脚本。执行方式：
ansible-playbook deploy-apache.yml 
$ansible-palybook deploy.yml。

11.编写playbook,首先要了解剧本的执行步骤，达到什么目的。playbook有如下关键字：
	-hosts：为主机的IP，或者主机组名，或者关键字all
	-remote_user: 以哪个用户身份执行。
	-vars： 变量
	-tasks: playbook的核心，定义顺序执行的动作action。每个action调用一个ansbile module。
	       action 语法： module： module_parameter=module_value
	       常用的module有yum、copy、template等，module在ansible的作用，
	       相当于bash脚本中yum，copy这样的命令。
	-handers： 是playbook的event，默认不会执行，在action里触发才会执行。多次触发只执行一次。

12.部署apache的步骤流程，然后形成playbook
	-安装apache包；
	-拷贝配置文件httpd，并保证拷贝文件后，apache服务会被重启；
	-拷贝默认的网页文件index.html；
	-启动apache服务；

---
- hosts: web
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest

  - name: Write the configuration file
    template: src=templates/httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf
    notify:
    - restart apache

  - name: Write the default index.html file
    template: src=templates/index.html.j2 dest=/var/www/html/index.html

  - name: ensure apache is running
    service: name=httpd state=started
  handlers:
    - name: restart apache
      service: name=httpd state=restarted

#src=temlates的路径在哪里，谁能大声告诉我。saltstack一个德行啊，也有这个的。

13.什么是Ansible Module？
linux的系统命令，如ls,yum，copy等等被ansible通过module的形式重新定义了。
所以执行的规则需要按照ansible来。不能按照linux哪样命令带个参数，可交互地执行了。
moudle的参数和linux所带的参数没有关系，自己定义的。
在命令行中有：
	-m后面接调用module的名字
	-a后面接调用module的参数
$ #使用module copy拷贝管理员节点文件/etc/hosts到所有远程主机/tmp/hosts
$ ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
$ #使用module yum在远程主机web上安装httpd包
$ ansible web -m yum -a "name=httpd state=present"
在playbook脚本中，tasks中的每一个action都是对module的一次调用。在每个action中：
	-冒号前面是module的名字
	-冒号后面是调用module的参数
---
  tasks:
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: write the apache config file
    template: src=templates/httpd.conf.j2 dest=/etc/httpd/conf/httpd.conf
  - name: ensure apache is running
    service: name=httpd state=started

14.Module的特性
（1）、像Linux中的命令一样，Ansible的Module既上命令行调用，也可以用在Ansible的脚本Playbook中。
（2）、每个Module的参数和状态的判断，都取决于该module的具体实现，
       所以在使用他们之前都需要查阅该module对应的文档。
       可以通过文档查看具体的用法： http://docs.ansible.com/ansible/list_of_all_modules.html
（3）、通过命令ansible-doc也可以查看module的用法
（4）、Ansible提供一些常用功能的Module，同时Ansible也提供API，
       让用户可以自己写Module，使用的编程语言是Python。
（5）、常用module: copy、file、cron、group、user、yum、service、script、ping、command、raw、
				   geturl、synchronize、template。

15.module例子   #学习ansible就是学习模块+playbook+api
copy模块：
    目的：把主控端/root目录下的a.sh文件拷贝到到指定节点上
    命令：ansible 10.1.1.113 -m copy -a 'src=/root/a.sh dest=/tmp/'
file模块：
    目的：更改指定节点上/tmp/t.sh的权限为755，属主和属组为root
    命令：ansible all -m file -a "dest=/tmp/t.sh mode=755 owner=root group=root"
cron模块：
    目的：在指定节点上定义一个计划任务，每隔3分钟到主控端更新一次时间
    命令：ansible all -m cron -a 'name="custom job" minute=*/3 hour=* day=* month=* weekday=* job="/usr/sbin/ntpdate 172.16.254.139"'
    group模块：
    目的：在所有节点上创建一个组名为nolinux，gid为2014的组
    命令：ansible all -m group -a 'gid=2014 name=nolinux'
    user模块：
    目的：在指定节点上创建一个用户名为nolinux，组为nolinux的用户
    命令：ansible 10.1.1.113 -m user -a 'name=nolinux groups=nolinux state=present'
    	  ansible 10.1.1.113 -m user -a 'name=nolinux  state=absent remove=yes'
yum模块：
    目的：在指定节点上安装 lrzsz 服务
    命令：ansible all -m yum -a "state=present name=httpd"
service模块：
    目的：启动指定节点上的 puppet 服务，并让其开机自启动
    命令：ansible 10.1.1.113 -m service -a 'name=puppet state=restarted enabled=yes'
script模块：
    目的：在指定节点上执行/root/a.sh脚本(该脚本是在ansible控制节点上的)
    命令：ansible 10.1.1.113 -m script -a '/root/a.sh'
ping模块：
    目的：检查指定节点机器是否还能连通
    命令：ansible 10.1.1.113 -m ping
command模块：
    目的：在指定节点上运行hostname命令
    命令：ansible 10.1.1.113 -m command -a 'hostname'
raw模块：
    目的：在10.1.1.113节点上运行hostname命令
    命令：ansible 10.1.1.113 -m raw-a 'hostname|tee'
get_url模块：
    目的：将http://10.1.1.116/favicon.ico文件下载到指定节点的/tmp目录下
    命令：ansible 10.1.1.113 -m get_url -a 'url=http://10.1.1.116/favicon.ico dest=/tmp'
synchronize模块：
    目的：将主控方/root/a目录推送到指定节点的/tmp目录下
    命令：ansible 10.1.1.113 -m synchronize -a 'src=/root/a dest=/tmp/ compress=yes'
    执行效果：
delete=yes   使两边的内容一样（即以推送方为主）
compress=yes  开启压缩，默认为开启
--exclude=.git  忽略同步.git结尾的文件
