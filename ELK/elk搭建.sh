1.ELK 由三部分组成elasticsearch、logstash、kibana.都不是什么高深的技术。

2.elasticsearch是一个近似实时的搜索平台,可以快输处理大数据成为可能。
其革命性在于将这些独立且有用的技术整合成一个一体化的、实时的应用。
Elasticsearch是面向文档(document oriented)的，这意味着它可以存储整个对象或文档(document)。
然而它不仅仅是存储，还会索引(index)每个文档的内容使之可以被搜索。
在Elasticsearch中，你可以对文档（而非成行成列的数据）进行索引、搜索、排序、过滤。
这种理解数据的方式与以往完全不同，这也是Elasticsearch能够执行复杂的全文搜索的原因之一。

3.Logstash：日志收集工具，可以从本地磁盘，网络服务（自己监听端口，接受用户日志），
消息队列中收集各种各样的日志，然后进行过滤分析，并将日志输出到Elasticsearch中。

4.Kibana：可视化日志Web展示工具，
对Elasticsearch中存储的日志进行展示，还可以生成炫丽的仪表盘。
kibana本质上是elasticsearch web客户端，是一个分析和可视化elasticsearch平台，可通过kibana搜索、查看和与存储在elasticsearch的索引进行交互。
可以很方便的执行先进的数据分析和可视化多种格式的数据，如图表、表格、地图等.

5.Elasticsearch是Java的，所以都是Java的程序。Java环境是跑不脱的。
yum install java 
//若源码安装，则要修改环境变量之类的

6.安装elasticsearch
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
添加yum文件
echo "
[elasticsearch-2.x]
name=Elasticsearch repository for 2.x packages
baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1" >> /etc/yum.repos.d/elasticsearch.repo
yum install elasticsearch -y

7.创建目录
mkdir /data/elk/{data,logs}

8.修改elasticsearch配置文件
vi /etc/elasticsearch/elasticsearch.yml
node.name: rexunil
cluster.name: es
path.data: /data/elk/data
path.logs: /data/elk/logs
bootstrap.mlockall: true
network.host: 0.0.0.0
http.port: 9200
discovery.zen.ping.unicast.hosts: ["106.75.73.109", "rexunil"]

9.启动与测试elasticsearch,有json数据就对了
/etc/init.d/elasticsearch start

10.安装两个插件
cd /usr/share/elasticsearch/bin/
./plugin install mobz/elasticsearch-head
./plugin install lmenezes/elasticsearch-kopf

http://ip:9200/_plugin/head/      //集群管理插件
http://ip:9200/_plugin/kopf      //集群资源查看和查询插件

11.安装kibana
https://download.elastic.co/kibana/kibana/kibana-4.5.1-linux-x64.tar.gz
tar zxvf kibana-4.5.1-linux-x64.tar.gz
mv kibana-4.5.1-linux-x64 /usr/local/
vi /etc/rc.local
/usr/local/kibana-4.5.1-linux-x64/bin/kibana > /var/log/kibana.log 2>&1 &
vi /usr/local/kibana-4.5.1-linux-x64/config/kibana.yml
server.port: 5601
server.host: "192.168.2.215"
elasticsearch.url: "http://192.168.2.215:9200"

12.安装logstash
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
echo "
[logstash-2.1]
name=Logstash repository for 2.1.x packages
baseurl=http://packages.elastic.co/logstash/2.1/centos
gpgcheck=1
gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
enabled=1" >> /etc/yum.repos.d/logstash.repo
yum install logstash -y

配置
input {
        file { 
          type => "messagelog"
          path => "/var/log/messages"
          start_position => "beginning"
        }
}
output {
        file {
          path => "/tmp/123.txt"
        }
        elasticsearch {
                hosts => ["106.75.73.109:9200"]
                index => "system-messages-%{+yyyy.MM.dd}"
        }
}

检查配置文件语法
/etc/init.d/logstash configtest

注意修改权限，使得他能读messages
vim /etc/init.d/logstash
LS_USER=root
LS_GROUP=root

基本就这些
后续深入
