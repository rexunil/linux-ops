通常我们使用pip安装python包，都会默认从 https://pypi.python.org/pypi 上安装，非常方便。

但是有些是公司内部的项目，不方便放到外网上去，这个时候我们就要搭建自己的内网pypi源服务器，需要安全并且拥有同样的舒适体验。

python官方有个pypi私有源实现的说明：http://wiki.python.org/moin/PyPiImplementations ，并且列出了几个比较成熟的实现方案:

PyPI , aka CheeseShop – The reference implementation, powering the main index.
ClueReleaseManager
EggBasket – A simple, lightweight Python Package Index (aka Cheeseshop) clone.
haufe.eggserver – Grok-based local repository with upload and no security model.
Plone Software Center
chishop – django based
pypiserver – minimal pypi server, easy to install & use
我选择pypiserver，因为他最小而且使用简单。下面是搭建的过程。

安装和快速上手

$ pip install pypiserver
$ mkdir ~/packages
# copy some source packages or eggs to this directory
$ pypi-server -p 8080 ~/packages
$ pip install -i http://localhost:8080/simple/ ...

$ pip install pypiserver
$ mkdir ~/packages
# copy some source packages or eggs to this directory
$ pypi-server -p 8080 ~/packages
$ pip install -i http://localhost:8080/simple/ ...
 
改进

我们用supervisor来管理pypi-server。

安装supervisor
$ sudo apt-get install supervisor $ ps aux|grep supervisor # 查看后台是否已经运行起来了

安装pypi server
$ cd /PATH/TO/PRIVATEPYPI $ virtualenv pypienv # 建立一个virtaulenv

$ source PATH/TO/PRIVATEPYPI/pypienv/bin/activate $ pip install pypiserver #安装pypi server

$ mkdir PATH/TO/PRIVATEPYPI/packages # 建立存放packages的文件夹

编写脚本/PATH/TO/PRIVATEPYPI/run-pypi.py，作用是在virtualenv中启动pypiserver。
#!/bin/sh # 启动virtualenv . /PATH/TO/PRIVATEPYPI/pypienv/bin/activate # 使用端口号3141，因为pypi与π谐音，π≈3.141 exec pypi-server -p 3141 /PATH/TO/PRIVATEPYPI/packages

在supervisor中配置启动pypi server
新建文件/PATH/TO/PRIVATEPYPI/pypi-server.conf，内容如下：

[program:pypi-server] directory=/PATH/TO/PRIVATEPYPI/ command=sh run-pypi.sh autostart=true autorestart=true redirect_stderr=true

将该文件软链到supervisor的配置文件夹下:

$ cd /etc/supervisor/conf.d/ $ sudo ln -s /PATH/TO/PRIVATEPYPI/pypi-supervisor.conf pypi-supervisor.conf

重启supervisor
$ sudo /etc/init.d/supervisor stop $ sudo /etc/init.d/supervisor start

这时候在浏览器中访问 http://localhost:3141/ ，就可以看到pypiserver的欢迎页面了。

上传package
上传package需要用户名密码，密码文件使用命令htpasswd生成

$ pip install passlib
$ apt-get install apache2-utils
$ htpasswd -sc /PATH/TO/PRIVATEPYPI/.htaccess user   # 回车后会提示输入密码，输入123

$ pip install passlib
$ apt-get install apache2-utils
$ htpasswd -sc /PATH/TO/PRIVATEPYPI/.htaccess user   # 回车后会提示输入密码，输入123
 
修改run-pypi.sh, 启动pypi server时加载密码文件

#!/bin/sh                                         

. ./pypienv/bin/activate                          
exec pypi-server -p 3141 -P ./.htaccess ./packages

#!/bin/sh                                         
 
. ./pypienv/bin/activate                          
exec pypi-server -p 3141 -P ./.htaccess ./packages
 
用前面的方法重新启动supervisor。
在用户的主目录下新建文件.pypirc(也可以在/PATH/TO/PRIVATEPYPI/下新建，通过软链链接到home目录下，推荐使用)，写入下面的内容：

[distutils]
index-servers =
  privatepypi 

[privatepypi]
repository:http://127.0.0.1:3141
username:user
password:123 

[distutils]
index-servers =
  privatepypi 
 
[privatepypi]
repository:http://127.0.0.1:3141
username:user
password:123 
 
上传package文件：

$ python setup.py sdist upload -r privatepypi 

$ python setup.py sdist upload -r privatepypi 
 
下载package
$ pip install -i http://localhost:3134/simple/ some-package
