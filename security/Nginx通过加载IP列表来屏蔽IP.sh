##########这种方式很好，内部站点都可以这么做。安全成分多一些，就放这里了。
###更进一步，可以通过定期统计nginx日志的IP行为，加载非法的IP列表中，这就是个简单有效的WAF了


nginx 通过加载IP列表文件来屏蔽特定IP。

1.在nginx的安装目录下面,新建屏蔽ip的文件，命名为stop.conf
（以后想屏蔽某个IP或者允许某个IP,在这个文件里添加即可）， 如下内容：
Deny 192.168.1.22;
Allow 192.168.1.2;
保存即可。

2.在nginx的配置文件nginx.conf中加入如下配置，可以放到http, server, location, limit_except语句块，需要注意相对路径，本例当中nginx.conf，stop.conf在同一个目录中。
Include stop.conf

3.重启一下nginx即可。
高级用法：
屏蔽ip的配置文件既可以屏蔽单个ip，也可以屏蔽ip段，或者只允许某个ip或者某个ip段访问。
deny IP;      # 屏蔽单个ip访问
allow IP;     # 允许单个ip访问
deny all;     # 屏蔽所有ip访问
allow all;    # 允许所有ip访问
deny 192.0.0.0/8      #屏蔽整个段
如果你想实现,除了几个IP外，其他IP全部拒绝，
那需要你在stop.conf中这样写
Allow 192.168.1.56;
Allow 192.168.1.11;
Deny all;

4.include stop.conf放的位置
单独网站屏蔽IP的方法，把include stop.conf; 放到网址对应的在server{}语句块，
所有网站屏蔽IP的方法，把include stop.conf; 放到http {}语句块。





