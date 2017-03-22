#!/bin/bash
#Centos 7 Java 1.8 Redis


rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat >> /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch-5.x]
name=Elasticsearch repository for 5.x packages
baseurl=https://artifacts.elastic.co/packages/5.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

yum install -y elasticsearch

cp /etc/elasticsearch/elasticsearch.yml{,.original}
cp /etc/elasticsearch/logging.yml{,.original}

systemctl daemon-reload
systemctl enable elasticsearch.service

#直接执行下面的也行。
#curl -s https://raw.githubusercontent.com/oscm/shell/master/search/elasticsearch/elasticsearch-5.2.sh | bash					
#curl -s https://raw.githubusercontent.com/oscm/shell/master/log/kibana/kibana-5.2.sh | bash					
#curl -s https://raw.githubusercontent.com/oscm/shell/master/log/kibana/logstash-5.2.sh | bash	
