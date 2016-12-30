1.安装
wget http://download.redis.io/releases/redis-3.2.6.tar.gz
tar -zxf redis-3.2.6.tar.gz
src/redis-server redis.conf &  #后台启动redis服务器,带配置文件redis.conf

[ -f redis.conf ] && cat /dev/null > redis.conf || touch redis.conf

####redis默认配置
cat >> redis.conf << EOF 
bind 127.0.0.1
protected-mode yes
port 6379
tcp-backlog 511
timeout 0
tcp-keepalive 300
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
slave-serve-stale-data yes
slave-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
slave-priority 100
appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
lua-time-limit 5000
slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0
notify-keyspace-events ""
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
hz 10
aof-rewrite-incremental-fsync yes
EOF

2.redis动态加内存{

    ./redis-cli -h 10.10.10.11 -p 6401
    save                                # 保存当前快照
    config get *                        # 列出所有当前配置
    config get maxmemory                # 查看指定配置
    config set maxmemory  15360000000   # 动态修改最大内存配置参数

}
