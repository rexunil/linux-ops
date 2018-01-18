vim /etc/profil
追加下述内容
==============================
history
 USER=`whoami`
 USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
 if [ "$USER_IP" = "" ]; then
 USER_IP=`hostname`
 fi
 if [ ! -d /var/log/history ]; then
 mkdir /var/log/history
 chmod 777 /var/log/history
 fi
 if [ ! -d /var/log/history/${LOGNAME} ]; then
 mkdir /var/log/history/${LOGNAME}
 chmod 300 /var/log/history/${LOGNAME}
 fi
 export HISTSIZE=4096
 DT=`date +"%Y%m%d_%H:%M:%S"`
 export HISTFILE="/var/log/history/${LOGNAME}/${USER}@${USER_IP}_$DT"
 chmod 600 /var/log/history/${LOGNAME}/*history* 2>/dev/null
 ==============================
 source /etc/profile 生效
 
 /var/log/history 日志的存放位置，该目录下以每个用户为名创建一个文件夹，
 每次用户退出后都会产生以用户名、登录IP、时间的日志文件，以及用户本次的所有操作。
 root用户的日志不会记录。
