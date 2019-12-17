#!/bin/bash
# :set fileformat=unix

# ---------------------------------------- 环境准备 start ----------------------------------------
# 不建议使用vagrant安装虚拟机，存在双网卡问题，会影响ipvs
# 使用visualbox传统方式安装虚拟机，下载ios镜像：http://mirrors.huaweicloud.com/centos/7.7.1908/isos/x86_64/CentOS-7-x86_64-DVD-1908.iso
# CentOs版本从7.2升级到7.7后，可以解决很多问题，如d_type不支持，pids不支持等。目前kernel在3.10.0-514以上自动支持overlay2存储驱动了。
# 查看系统支持哪些subsystem：cat /proc/cgroups，列表中没有出现pids，说明不支持
# CentOs版本：rpm -q centos-release：centos-release-7-7.1908.0.el7.centos.x86_64
# CentOs内核版本：uname -r：3.10.0-957.12.2.el7.x86_64

# 检查服务器主机名
hostname
# 各服务器主机名不可重复
sudo hostnamectl set-hostname master1

# 务必同步服务器时间(-u：从man ntpdate中可以看出-u参数可以越过防火墙与主机同步；若不加上-u参数， 可能会出现以下提示：no server suitable for synchronization found):
# 查看时间：date -R
# 设置时区：
timedatectl set-timezone Asia/Shanghai
yum install -y ntpdate
ntpdate -u cn.pool.ntp.org 

# master节点CPU必须2C以上，否则会出现错误信息：the number of available CPUs 1 is less than the required 2
# 打开visualbox管理器，修改机器cpu数量即可。
# ---------------------------------------- 环境准备 end ----------------------------------------

# ---------------------------------------- 以下操作任一机器上执行一次即可完成k8s集群 start ----------------------------------------
# 官网地址：https://github.com/fanux/sealos
# 帮助文档：https://sealyun.com/docs/
# 下载并安装sealos, sealos是个golang的二进制工具，直接下载拷贝到bin目录即可
wget https://github.com/fanux/sealos/releases/download/v3.0.1/sealos && \
    chmod +x sealos && mv sealos /usr/bin

# 下载离线包
wget https://sealyun.oss-cn-beijing.aliyuncs.com/413bd3624b2fb9e466601594b4f72072-1.17.0/kube1.17.0.tar.gz

# 安装一个二master的kubernetes集群（只需要准备好服务器，在任意一台服务器上执行下面命令即可）
# 若没有安装docker，会自动安装此离线包中的19.03.0版本（如已安装则会忽略）
sealos init --master 192.168.0.200 \
#    --master 192.168.0.201  \
	--node 192.168.0.202 \
    --user root \
    --passwd 123456 \
	--pkg-url /root/kube1.17.0.tar.gz \
	--version v1.17.0

# 清理
sealos clean \
    --master 192.168.0.200 \
#    --master 192.168.0.201 \
    --node 192.168.0.202 \
    --user root \
    --passwd 123456

# 稍等几分钟，查看所有节点是否正常
kubectl get nodes
# 查看pod状态 
kubectl get pod --all-namespaces 
# ---------------------------------------- 以下操作任一机器上执行即可 end ----------------------------------------

# ---------------------------------------- 添加dashboard start ----------------------------------------
# 下载dashboard.tar离线包
wget https://github.com/sealstore/dashboard/releases/download/v2.0.0-bata5/dashboard.tar
# 安装app（执行第一次安装失败，再执行一次成功了，安装成功后会生成token）
sealos install --pkg-url /root/dashboard.tar
# 访问：https://你的master地址:32000，如：https://192.168.0.200:32000
# 获取dashboard登录token：
kubectl get secret -nkubernetes-dashboard \
    $(kubectl get secret -n kubernetes-dashboard|grep dashboard-token |awk '{print $1}') \
    -o jsonpath='{.data.token}'  | base64 --decode
# ---------------------------------------- 添加dashboard end ----------------------------------------


# ---------------------------------------- 添加一个master节点start ----------------------------------------
# ---------------------------------------- 添加一个master节点end ----------------------------------------

# ---------------------------------------- 添加一个node节点start ----------------------------------------
# ---------------------------------------- 添加一个node节点end ----------------------------------------

# ---------------------------------------- 错误列表 ----------------------------------------
# 1.某些机器初始化k8s提示failed to pull image k8s.gcr.io/kube-scheduler:v1.16.0
# 出错原因：load images离线包时，提示空间不足(可df -h查看空间使用情况)，导致镜像没有加载成功，添加磁盘空间即可：
# Error processing tar file(exit status 1): write /usr/local/bin/kube-controller-manager: no space left on device
# -------------------------------------------
# 2.kubeadm init --config=/root/kubeadm-config.yaml --upload-certs报错：Unable to update cni config: no networks found in /etc/cni/net.d
# 重启节点即可解决
# -------------------------------------------
# 3.node节点kubeadm join 10.103.97.2:6443 时一直卡住不动，排查步骤（在node节点上进行）：
# 参考文档：https://github.com/fanux/sealos/issues/134
# curl -k https://192.168.33.10:6443
# 检查apiserver联通性
# cat /etc/hosts
# curl -k https://apiserver.cluster.local:6443
# 如果不通，使用ipvsadm命令检查ipvs规则是否正常
# yum install -y ipvsadm
# ipvsadm -ln查看分流，ipvsadm -lnc查看分流详情
# 注意有没有虚拟IP 10.103.97.2 这个的规则，后端是不是对应你的master
# ip route|column -t （column -t格式化显示结果）
# 查看网卡信息：ip a
# 添加动态路由表，将node节点添加默认路由指向第二块网卡网关ip
# 临时解决方法：ip route add default via 192.168.33.1
# 注意：重启后规则就没有了，所以需要添加静态路由表
# 如果机器中存在多块网卡，而默认路由只能设置一个：
# -------------------------------------------