yum install glances

[root@10-9-108-59 ~]$ glances  

                 10-9-108-59 (CentOS Linux 7.2.1511 64bit / Linux 3.10.0-327.22.2.el7.x86_64)                  Uptime: 6 days, 6:56:46

CPU       0.6%  steal:    0.0%   Load   4-core   Mem    16.2%  active:   1.50G   Swap    0.0%
user:     0.3%  nice:     0.0%   1 min:   0.00   total: 7.64G  inactive: 1.17G   total:  512M
system:   0.2%  iowait:   0.0%   5 min:   0.01   used:  1.24G  buffers:   868K   used:      0
idle:    99.4%  irq:      0.0%   15 min:  0.05   free:  6.40G  cached:   1.76G   free:   512M

Network    Rx/s    Tx/s   Tasks  106 (157 thr),  1 run, 105 slp,  0 oth  sorted automatically
eth0       784b     4Kb
lo           0b      0b    VIRT   RES  CPU%  MEM%   PID USER        NI S    TIME+ IOR/s IOW/s NAME
                           235M   16M   2.9   0.2 28947 root         0 R  0:00.40     0     0 /usr/bin/python /usr/bin/glances
Disk I/O   In/s   Out/s    1.1G  781M   0.6  10.0 25062 mongod       0 S 31:27.92     0    3K mongod
vda1          0       0    139M    5M   0.6   0.1 28951 root         0 S  0:00.50     0    1K sshd: root [priv]
vdb         682       0       0     0   0.3   0.0    13 root         0 S  1:48.66     0     0 rcu_sched
                              0     0   0.3   0.0  3980 root         0 S  2:28.82     0     0 xfsaild/vdb
Mount      Used   Total     40M    3M   0.0   0.0     1 root         0 S  0:19.23     0     0 systemd
/         2.89G   20.0G       0     0   0.0   0.0     2 root         0 S  0:00.20     0     0 kthreadd
/data      731M  100.0G       0     0   0.0   0.0     3 root         0 S  0:00.70     0     0 ksoftirqd/0
/run       112M   3.82G       0     0   0.0   0.0     5 root       -20 S  0:00.00     0     0 kworker/0:0H
_/user/0      0    782M       0     0   0.0   0.0     7 root         0 S  0:00.13     0     0 migration/0
                              0     0   0.0   0.0     8 root         0 S  0:00.00     0     0 rcu_bh
                              0     0   0.0   0.0     9 root         0 S  0:00.00     0     0 rcuob/0
                              0     0   0.0   0.0    10 root         0 S  0:00.00     0     0 rcuob/1
                              0     0   0.0   0.0    11 root         0 S  0:00.00     0     0 rcuob/2
                              0     0   0.0   0.0    12 root         0 S  0:00.00     0     0 rcuob/3

Press 'h' for help                                                                                                2017-03-27 17:05:04
