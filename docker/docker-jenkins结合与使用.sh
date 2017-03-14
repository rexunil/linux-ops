#一直在想怎么结合起来，让发布、测试更自动化，还好，有人也一样做了。
# 地址 http://www.cnblogs.com/Leo_wl/p/4314792.html
# 以下操作的目标：jenkins放置在宿主机内(Ubuntu14.04),apache容器放置在容器里，以后apache镜像一做修改，
触发构建一个jenkins的job，宿主机会停掉原来的容器，生成一个新的容器。

1.安装Jenkins
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | #sudo apt-key add -  
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'  
sudo apt-get update  
sudo apt-get install jenkins  

2.装插件
登陆http://IP:8080,进入jenkins，在http://IP:8080/pluginManager/available
安装一些必要的插件SCM Sync Configuration Plugin ，GitHub plugin ，GIT plugin ，GIT client plugin ,安装结束后重启jenkins.

3.新建item
=============================================
#!/bin/sh
id
set +e
echo '>>> Get old container id'

CID=$(docker ps | grep "apache" | awk '{print $1}')

echo $CID

/usr/local/bin/docker build -t apache /var/lib/jenkins/jobs/apache/workspace | tee /var/lib/jenkins/jobs/apache/workspace/Docker_build_result.log
RESULT=$(cat /var/lib/jenkins/jobs/apache/workspace/Docker_build_result.log | tail -n 1)

#if [["$RESULT" != *Successfully*]];then
#  exit -1
#fi

echo '>>> Stopping old container'

if [ "$CID" != "" ];then
  /usr/local/bin/docker stop $CID
fi

echo '>>> Restarting docker'
service docker.io restart
sleep 5
  
echo '>>> Starting new container'
/usr/local/bin/docker run -p 3000:80 -d apache
===============================================================

4.配置用户

5.配置jenkins用户
此时还不能立即构建，因为jenkins触发脚本并不是root用户，因此需要将jenkins免用户，并将用户加入到docker组，否则获取不到容器ID.

root@iZ2893wjzgyZ:~# vim /etc/sudoers

# User privilege specification
root    ALL=(ALL:ALL) ALL
jenkins ALL=(ALL:ALL) ALL
jenkins@iZ2893wjzgyZ:~$ usermod -G docker jenkins
