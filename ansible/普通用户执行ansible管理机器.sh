1.创建普通的用户
useradd -d /home/ansible -m ansible
echo 'paassword' |passwd --stdin ansible

2.在被管理的机器上执行这个，赋予sudo权限。

3.在ansible管理机生成ssh公私钥文件，并分发到其他机器
ssh-keygen -t rsa
ssh-copy-id -i 192.168.154.205

4.修改ansible管理机/etc/ansible/ansible.cfg文件
private_key_file = /home/jldev/.ssh/id_rsa

5.修改ansible相关目录的属主（之前是root）
chown -R ansible:onip /etc/ansible
chown -R ansible:onip /usr/share/ansible
或者执行命令的时候带u
ansible -i iplist all -m ping -umrdTomcat

6./tmp/ansible.log
chmod a+w ansible.log
