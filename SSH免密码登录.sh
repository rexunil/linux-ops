##SSH免密码登录

1.生成公钥和私钥
Shell代码 
　　ssh-keygen -t rsa

   默认在 ~/.ssh目录生成两个文件：
    id_rsa      ：私钥
    id_rsa.pub  ：公钥
2.导入公钥到认证文件,更改权限
    
    2.1 导入本机
Shell代码 
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys  

    2.2 导入要免密码登录的服务器
        首先将公钥复制到服务器
Shell代码 
    scp ~/.ssh/id_rsa.pub xxx@host:/home/xxx/id_rsa.pub  
        然后，将公钥导入到认证文件，这一步的操作在服务器上进行
Shell代码 
    cat ~/id_rsa.pub >> ~/.ssh/authorized_keys 


 
    2.3 在服务器上更改权限
    
Shell代码 
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/authorized_keys  
   
3.测试
 
    ssh xxx@host，第一次登录可能需要yes确认，之后就可以直接登录了。

4,可以直接执行命令
ssh xxx@10.207.139.62 'hostname'
