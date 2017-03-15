#安装pip,便于管理python软件的安装包
#官网 https://pip.pypa.io/en/latest/installing/
#简单就两条命令

1.安装
wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py

2.升级自己
pip install --upgrade pip

3.查找和安装某个package
使用search、install这两个参数。什么都给弄出来
[root@VM_63_97_centos ~]# pip search ansible
mistral-ansible-actions (0.1.2.dev1)    - A Mistral action to execute Ansible playbooks
ansiblator (0.6-13-28-10-2014)          - Ansiblator - makes Ansible api more Pythonic

4.指定安装在某个用户目录
pip install pkg_name --user

5.查看安装信息
[root@VM_63_97_centos ~]# pip show ansible
Name: ansible
Version: 2.2.1.0
Summary: Radically simple IT automation
Home-page: http://ansible.com/
Author: Ansible, Inc.
Author-email: info@ansible.com
License: GPLv3
Location: /usr/lib/python2.7/site-packages
Requires: jinja2, pycrypto, setuptools, PyYAML, paramiko

6.查看安装列表
pip list


