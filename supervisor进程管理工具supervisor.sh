1.Supervisor (http://supervisord.org) 是一个用 Python 写的进程管理工具，
可以很方便的用来启动、重启、关闭进程（不仅仅是 Python 进程）。
除了对单个进程的控制，还可以同时启动、关闭多个进程，
比如很不幸的服务器出问题导致所有应用程序都被杀死，
此时可以用 supervisor 同时启动所有应用程序而不是一个一个地敲命令启动。

2.安装
sudo pip install supervisor

3.supervisor功能强大，一般只用到进程管理的小部分功能。

4.配置
supervisor是C/S结构。supervisord（server是服务端，客户端是supervisorctl)。
配置分两部分，一部分是supervisord端，一部分是应用程序（被管理的进程）。

supervisord端配置文件，安装完后，即可用命令echo_supervisord_conf输出默认配置文件
echo_supervisord_conf > /etc/supervisord.conf

==============关键配置信息==================
[unix_http_server]
file=/tmp/supervisor.sock   ; UNIX socket 文件，supervisorctl 会使用
;chmod=0700                 ; socket 文件的 mode，默认是 0700
;chown=nobody:nogroup       ; socket 文件的 owner，格式： uid:gid
 
;[inet_http_server]         ; HTTP 服务器，提供 web 管理界面
;port=127.0.0.1:9001        ; Web 管理后台运行的 IP 和端口，如果开放到公网，需要注意安全性
;username=user              ; 登录管理后台的用户名
;password=123               ; 登录管理后台的密码
 
[supervisord]
logfile=/tmp/supervisord.log ; 日志文件，默认是 $CWD/supervisord.log
logfile_maxbytes=50MB        ; 日志文件大小，超出会 rotate，默认 50MB
logfile_backups=10           ; 日志文件保留备份数量默认 10
loglevel=info                ; 日志级别，默认 info，其它: debug,warn,trace
pidfile=/tmp/supervisord.pid ; pid 文件
nodaemon=false               ; 是否在前台启动，默认是 false，即以 daemon 的方式启动
minfds=1024                  ; 可以打开的文件描述符的最小值，默认 1024
minprocs=200                 ; 可以打开的进程数的最小值，默认 200
 
; the below section must remain in the config file for RPC
; (supervisorctl/web interface) to work, additional interfaces may be
; added by defining them in separate rpcinterface: sections
[rpcinterface:supervisor]
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface
 
[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; 通过 UNIX socket 连接 supervisord，路径与 unix_http_server 部分的 file 一致
;serverurl=http://127.0.0.1:9001 ; 通过 HTTP 的方式连接 supervisord
 
; 包含其他的配置文件
[include]
files = relative/directory/*.ini    ; 可以是 *.conf 或 *.ini

=========================================================

5.启动supervisordm -c带配置启动
如果不指定会按照这个顺序查找配置文件：
（$CWD/supervisord.conf, $CWD/etc/supervisord.conf, /etc/supervisord.conf）

supervisord -c /etc/supervisord.conf

6.应用程序的配置
 supervisrod 运行起来了，现在可以添加我们要管理的进程的配置文件。
 可以把所有配置项都写到 supervisord.conf 文件里，但并不推荐这样做，
 而是通过 include 的方式把不同的程序（组）写到不同的配置文件里。

 新建一个目录 /etc/supervisor/ 用于存放这些配置文件，
 相应的，把 /etc/supervisord.conf 里 include 部分的的配置修改一下：
====================
[include]
files = /etc/supervisor/*.conf
=====================

假设有个用 Python 和 Flask 框架编写的用户中心系统，取名 usercenter，
用 gunicorn (http://gunicorn.org/) 做 web 服务器。
项目代码位于 /home/leon/projects/usercenter，
gunicorn 配置文件为 gunicorn.py，
WSGI callable 是 wsgi.py 里的 app 属性。所以直接在命令行启动的方式可能是这样的：

cd /home/leon/projects/usercenter
gunicorn -c gunicorn.py wsgi:app

现在编写一份配置文件来管理这个进程
（需要注意：用 supervisord 管理时，gunicorn 的 daemon 选项需要设置为 False）：

======================================================
[program:usercenter]
directory = /home/leon/projects/usercenter ; 程序的启动目录
command = gunicorn -c gunicorn.py wsgi:app  ; 启动命令，可以看出与手动在命令行启动的命令是一样的
autostart = true     ; 在 supervisord 启动的时候也自动启动
startsecs = 5        ; 启动 5 秒后没有异常退出，就当作已经正常启动了
autorestart = true   ; 程序异常退出后自动重启
startretries = 3     ; 启动失败自动重试次数，默认是 3
user = leon          ; 用哪个用户启动
redirect_stderr = true  ; 把 stderr 重定向到 stdout，默认 false
stdout_logfile_maxbytes = 20MB  ; stdout 日志文件大小，默认 50MB
stdout_logfile_backups = 20     ; stdout 日志文件备份数
; stdout 日志文件，需要注意当指定目录不存在时无法正常启动，所以需要手动创建目录（supervisord 会自动创建日志文件）
stdout_logfile = /data/logs/usercenter_stdout.log
 
; 可以通过 environment 来添加需要的环境变量，一种常见的用法是修改 PYTHONPATH
; environment=PYTHONPATH=$PYTHONPATH:/path/to/somewhere

====================================================

一份配置文件至少需要一个 [program:x] 部分的配置，来告诉 supervisord 需要管理那个进程。
[program:x] 语法中的 x 表示 program name，会在客户端（supervisorctl 或 web 界面）显示，
在 supervisorctl 中通过这个值来对程序进行 start、restart、stop 等操作。

7.使用 supervisorctl

Supervisorctl 是 supervisord 的一个命令行客户端工具，
启动时需要指定与 supervisord 使用同一份配置文件，
否则与 supervisord 一样按照顺序查找配置文件。

supervisorctl -c /etc/supervisord.conf

上面这个命令会进入 supervisorctl 的 shell 界面，然后可以执行不同的命令了：

==============================================
> status    # 查看程序状态
> stop usercenter   # 关闭 usercenter 程序
> start usercenter  # 启动 usercenter 程序
> restart usercenter    # 重启 usercenter 程序
> reread    # 读取有更新（增加）的配置文件，不会启动新添加的程序
> update    # 重启配置文件修改过的程序
==============================================

上面这些命令都有相应的输出，除了进入 supervisorctl 的 shell 界面，
也可以直接在 bash 终端运行：

=================================================
supervisorctl status
supervisorctl stop usercenter
supervisorctl start usercenter
supervisorctl restart usercenter
supervisorctl reread
supervisorctl update
=================================================

8.其他
除了supervisorctl之外，还可以配置 supervisrod 启动 web 管理界面，
这个 web 后台使用 Basic Auth 的方式进行身份认证。
除了单个进程的控制，还可以配置 group，进行分组管理。
经常查看日志文件，包括 supervisord 的日志和各个 pragram 的日志文件，
程序 crash 或抛出异常的信息一半会输出到 stderr，可以查看相应的日志文件来查找问题。


9.supervisor好处
简单
以前管理linux进程的时候，需要自己编写一个能够实现进程start/stop/restart/reload功能的脚本，
然后丢到/etc/init.d/下面。这样做的问题是，编写脚本费事，而且进程挂了不会自动重启。这样需要自己再写一个监控重启脚本。
supervisor则可以完美的解决这些问题。通过supervisor管理进程，
就是通过fork/exec的方式把这些被管理的进程，当作supervisor的子进程来启动。
我们只需要在supervisor的配置文件中，把要管理的进程的可执行文件的路径写进去就OK了。
另外，被管理进程作为supervisor的子进程，当子进程挂掉的时候，
父进程可以准确获取子进程挂掉的信息的，所以当然也就可以对挂掉的子进程进行自动重启了，
当然重启还是不重启，也要看你的配置文件里面有木有设置autostart=true。

精确
linux对进程状态的反馈，有时候不太准确。为啥不准确? why? 
官方文档是这么说的。系统不能时刻知晓某个进程的状态？ 
而supervisor监控子进程，得到的子进程状态无疑是准确的。

进程组
supervisor可以对进程组统一管理，也就可以把需要管理的进程写到一个组里面，
然后把这个组作为一个对象进行管理，如启动，停止，重启等等操作。
而linux系统则是没有这种功能的，我们想要停止一个进程，只能一个一个的去停止，
要么就自己写个脚本去批量停止。

集中式管理
supervisor管理的进程，进程组信息，全部都写在一个ini格式的文件里就OK了。
而且，我们管理supervisor的时候的可以在本地进行管理，也可以远程管理，
而且supervisor提供了一个web界面，我们可以在web界面上监控，管理进程。 
当然了，本地，远程和web管理的时候，需要调用supervisor的xml_rpc接口。

有效性
当supervisor的子进程挂掉的时候，操作系统会直接给supervisor发信号。
而其他的一些类似supervisor的工具，则是通过进程的pid文件，来发送信号的，
然后定期轮询来重启失败的进程。显然supervisor更加高效。。。
听说过god,director，但是没用过。有兴趣的可以玩玩

可扩展性
supervisor是个开源软件，可以直接去改软件。
不过咱们大多数人还是老老实实研究supervisot提供的接口吧，
supervisor主要提供了两个可扩展的功能。一个是event机制，这个就是楼主这两天干的活要用到的东西。
再一个是xml_rpc,supervisor的web管理端和远程调用的时候，就要用到它了。

权限
大伙都知道linux的进程，特别是侦听在1024端口之下的进程，一般用户大多数情况下，
是不能对其进行控制的。想要控制的话，必须要有root权限。而supervisor提供了一个功能，
可以为supervisord或者每个子进程，设置一个非root的user，这个user就可以管理它对应的进程了。

10.supervisor组件

supervisord
supervisord是supervisor的服务端程序。
干的活：启动supervisor程序自身，启动supervisor管理的子进程，响应来自clients的请求，
重启闪退或异常退出的子进程，把子进程的stderr或stdout记录到日志文件中，生成和处理Event

supervisorctl
这东西还是有点用的，如果说supervisord是supervisor的服务端程序，
那么supervisorctl就是client端程序了。supervisorctl有一个类型shell的命令行界面，
我们可以利用它来查看子进程状态，启动/停止/重启子进程，获取running子进程的列表等等。。。
最牛逼的一点是，supervisorctl不仅可以连接到本机上的supervisord，
还可以连接到远程的supervisord，当然在本机上面是通过UNIX socket连接的，
远程是通过TCP socket连接的。supervisorctl和supervisord之间的通信，是通过xml_rpc完成的。    
相应的配置在[supervisorctl]块里面

Web Server
Web Server主要可以在界面上管理进程，Web Server其实是通过XML_RPC来实现的，
可以向supervisor请求数据，也可以控制supervisor及子进程。
配置在[inet_http_server]块里面

XML_RPC接口
这个就是远程调用的，上面的supervisorctl和Web Server就是它弄的
