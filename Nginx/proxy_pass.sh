
# 反向代理 node-server，核心的配置文件
location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-NginX-Proxy true;
    # 代理的地址
    proxy_pass http://node-server;
    proxy_redirect off;
}
    
    
# 例子：
#img.test.com/img1 实际访问的路径是  http://127.0.0.1:123/a1
#img.test.com/img2 实际访问的路径是  http://127.0.0.1:123/a2

location / {
    proxy_set_header Host img.test.com;
    rewrite img1/(.+)$  /a1/$1  break;
    rewrite img2/(.+)$  /a2/$1  break;

    proxy_pass http://127.0.0.1:123/;#代理ip:127.0.0.1,端口123
    proxy_redirect off;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}


Reverse Proxy（反向代理）
我有一个 Nginx 服务部署在 www.mysite.com的80端口，用户访问它就可以看见我做的网站；在我的网站中有一些 Ajax请求去获取JSON 数据，然而提供这些数据的 API Service 部署在服务器上的 8000 端口，该端口由于防火墙的阻挠使得用户无法直接访问到。

于是我们重新配置了Nginx，让它把所有经由 :80/api/ 的访问请求都代理给 localhost:8000，然后把响应返回给原始的请求方（即：Origin Host），这就是反向代理。
现在我的用户可以正常访问www.mysite.com了。
PHP的9000就是，还有python的flask都是。

(1)这是反向代理的一种应用场景，但并非代表它只能这样用
(2)最重要的特征是我的用户压根不知道 localhost:8000 这个服务的存在，并且即使知道也访问不到——开 VPN 也访问不到，这是俩码事！
(3)对于用户来讲，唯一的“对话”方只有 www.mysite.com（80 端口），他们不知道也不必知道后面发生了什么。
