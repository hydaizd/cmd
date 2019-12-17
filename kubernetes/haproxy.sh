#!/bin/bash
# :set fileformat=unix

# 安装haproxy
yum install haproxy -y

# 修改haproxy配置
cat << EOF > /etc/haproxy/haproxy.cfg
# 全局配置段
global
    log         127.0.0.1 local2        # 日志将被记录在本机的local2设施中
    chroot      /var/lib/haproxy        # 改变当前工作目录    
    pidfile     /var/run/haproxy.pid    # 当前进程pid文件
    maxconn     4000                    # 最大连接数
    user        haproxy                 # 所属用户
    group       haproxy                 # 所属组
    daemon                              # 以守护进程方式运行haproxy

# 为frontend, backend, listen提供默认配置
defaults
    mode                    tcp
    log                     global      # 应用全局的日志配置
    retries                 3           # 定义连接后端服务器的失败重连次数，连接失败次数超过此值后将会将对应后端服务器标记为不可用
    timeout connect         10s         # 连接超时
    timeout client          1m          # 客户端超时
    timeout server          1m          # 服务器端超时

# 前端，相当于nginx, server {}
frontend kube-apiserver-lb
    bind *:16443                                # 指定一个或多个前端侦听地址和端口
    mode tcp                                    # 定义haproxy的工作模式
    default_backend master

# 后端，相当于nginx, upstream {}
backend master # 定义一个名为master后端部分。PS：此处master只是一个自定义名字而已，但是需要与frontend里面配置项default_backend 值相一致
    mode tcp                                                    # 需要与frontend的mode一致
    balance roundrobin                                          # 负载均衡算法，负载方式为轮询
    server master-1  192.168.33.10:6443 check maxconn 2000      # 定义的多个后端
    server master-2  192.168.33.11:6443 check maxconn 2000      # 定义的多个后端
EOF

# 开机默认启动haproxy，开启服务
systemctl enable --now haproxy

# 检查服务端口情况：
# netstat -lntup | grep 6443
