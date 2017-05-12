站点免费证书解决方案

一、certbot免费解决

1.安装certbot
$ sudo yum install epel-release
$ sudo yum install certbot  
#妈的，centos7没有问题。centos6问题多多，装不了

2.为域名申请一个证书

certbot certonly --webroot -w /data/wwwroot/www-d www.163.com 
-w后面是站点根目录
-d后面是站点域名，如果多个域名，可以使用多个-d参数，每个-d参数跟一个域名，-d之间用空格分开
certbot certonly --webroot -w 站点根目录 -d 站点域名
yum install certbot
certbot certonly --webroot -w /data/wwwroot/www-d www.163.com 

提示输入邮箱，用于紧急通知以及密钥恢复
阅读文档，选Agree即可
如果成功证书和私钥会保存在/etc/letsencrypt/live/站点域名/ 中
证书格式为pem格式。

3.nginx配置证书

ssl_certificate /etc/letsencrypt/live/站点域名/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/站点域名/privkey.pem;

4.重启nginx服务器

5.证书自动续期
证书有效期为90天，所以需要写一个定时任务
#minute   hour    day  month  week    command
0         3    *    *      *       certbot renew > /var/log/certbot.log & echo certbot last renew at `date` >> /var/log/certbot.log

在每天3点会更新一次证书，并将结果保存到/var/log/certbot.log日志中。


二、腾讯云的一年免费证书解决方案
1.申请证书
2.CNAME
3.下载证书，证书包含nginx、IIS、Apache三种版本的。crt和key.
4.线上有crt转pem格式的站点。
https://www.myssl.cn/tools/merge-pem-cert.html

server {
    listen       443 ssl;
    server_name www.163.com;
    root /data/wwwroot/
	ssl on;
	ssl_certificate /usr/local/nginx/conf/key/1_www.163.com_bundle.crt;
	ssl_certificate_key /usr/local/nginx/conf/key/2_www.163.com.key;
	ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
	ssl_prefer_server_ciphers on; 
	} 
  
  三、CDN的证书解决
  1.阿里云
  申请证书转化为pem格式，后端配置即可。但是https会另行收钱。
  2.网宿以及其他的厂商
  申请证书转为pem格式，把证书私钥一并给其运维人员，比较蛋疼。
  
  四、通配符域名的证书
  需要花钱买了


//免费的证书，有个大坑，证书尽管自动更新了，但是nginx需要reload才能重新加载！所以设置一个月reload一次nginx是非常有必要的！
