
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
