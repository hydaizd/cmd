#!/bin/bash
# :set fileformat=unix

# ---------------------------------------- master节点环境准备 start ----------------------------------------
# 修改host，追加内容
cat >> /etc/hosts << EOF
192.168.33.10 master1
192.168.33.11 master2
192.168.33.12 node1
EOF

# 修改主机名
sudo hostnamectl set-hostname master1

# 关闭防火墙
systemctl stop firewalld
systemctl disable firewalld

# 关闭swap分区，(1.8版本后的要求，目的应该是不想让swap干扰pod可使用的内存limit)
# 临时关闭swap分区（重启失效）
swapoff -a
# 永久关闭swap分区，注释swap
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 关闭selinux
# 临时关闭，不用重启机器
setenforce 0 #设置SELinux 成为permissive模式，##setenforce 1 设置SELinux 成为enforcing模式
# 永久关闭，需要重启机器
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

# 配置转发相关参数
# RHEL / CentOS 7上的一些用户报告了由于绕过iptables而导致流量无法正确路由的问题。您应该确保 net.bridge.bridge-nf-call-iptables在sysctl配置中将其设置为1
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-arptables = 1
EOF
sysctl --system

# 安装ipset软件包
yum install ipset -y

# [可选]为了方便查看ipvs规则我们要安装ipvsadm
yum install ipvsadm -y

# 设置终端代理
export http_proxy=http://$username:$password@$proxy_host:$port
export https_proxy=https://$username:$password@$proxy_host:$port
export no_proxy=127.0.0.1,localhost,192.168.2.100
# ---------------------------------------- master节点环境准备 end ----------------------------------------


# ---------------------------------------- 安装docker start ----------------------------------------
# 安装docker存储库前,我们建议使用yum-config-manager命令来管理安装源,而yum-utils提供了该命令
# docker存储模式默认为Storage Driver: overlay2（使用docker info命令可查看）
# 存储模式官方文档：https://docs.docker.com/storage/storagedriver/select-storage-driver/
yum install -y yum-utils

# 配置docker仓库
# yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

# 卸载旧版本（老版本的docker叫docker或docker-engine，新版本叫 docker-ce (社区版本)）
# yum remove docker docker-common docker-selinux docker-engine docker-ce
# rm -rf /etc/systemd/system

# 安装docker
# 查看可安装的版本列表
# yum list docker-ce --showduplicates | sort -r
# 安装指定版本
yum install -y docker-ce-19.03.0

# docker配置文件(配置自己的阿里云镜像加速)
# sudo systemctl daemon-reload
# sudo systemctl restart docker
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://6nmh6d70.mirror.aliyuncs.com"
  ],
  "exec-opts": [
    "native.cgroupdriver=systemd"
  ],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

# 启动docker，并配置开机启动
systemctl enable --now docker
# ---------------------------------------- 安装docker end ----------------------------------------


# ---------------------------------------- 安装docker-compose start ----------------------------------------
# 安装docker-compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.25.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
# ---------------------------------------- 安装docker-compose end ----------------------------------------


# ---------------------------------------- 安装k8s start ----------------------------------------
# 配置k8s的yum源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
#baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
#gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
# 安装k8s
yum install -y kubelet-1.17.0-0 kubeadm-1.17.0-0 kubectl-1.17.0-0 --disableexcludes=kubernetes

# 统一k8s与docker驱动
# docker info | grep Cgroup
# cat /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
# cat /var/lib/kubelet/kubeadm-flags.env
# 修改k8s配置文件与docker保持一致
# sed -i "s/cgroup-driver=cgroupfs/cgroup-driver=systemd/g" /var/lib/kubelet/kubeadm-flags.env

# 此时启动会出现报错：failed to load Kubelet config file /var/lib/kubelet/config.yaml
# 忽略以上的报错，设置为开机自启动即可，因为此时的配置还没初始化完成，所以此时不能启动kubelet,等后续kubeadm启动成功后再查看
systemctl enable --now kubelet
# ---------------------------------------- 安装k8s end ----------------------------------------


# ---------------------------------------- 初始化master节点 start ----------------------------------------
# flannel网络插件，指定pod网段及掩码（pod之间相互通信插件默认网段：flannel：10.244.0.0/16 我们使用flannel，calico：192.168.0.0/16）
kubeadm init \
--apiserver-advertise-address=192.168.33.10 \
--image-repository registry.aliyuncs.com/google_containers \
--kubernetes-version v1.17.0 \
--pod-network-cidr=10.244.0.0/16 \
--v=5

# 初始化当前用户配置 使用kubectl会用到
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 安装pod网络插件，否则master节点上的coredns容器无法启动（yml文件中已包含了rbac配置）
# 准备配置文件中需要的镜像：
# quay.io/coreos/flannel:v0.11.0-amd64
# quay.io/coreos/flannel:v0.11.0-arm64
# quay.io/coreos/flannel:v0.11.0-arm
# quay.io/coreos/flannel:v0.11.0-ppc64le
# quay.io/coreos/flannel:v0.11.0-s390x  => quay-mirror.qiniu.com/coreos/flannel:v0.11.0-s390x
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# ---------------------------------------- 常见问题列表 ----------------------------------------
# 1.集群初始化如果遇到问题，可以使用下面的命令进行清理：
kubeadm reset
ifconfig cni0 down
ip link delete cni0
ifconfig flannel.1 down
ip link delete flannel.1
rm -rf /var/lib/cni/

# 2.master节点初始化后并安装了pod网络插件flannel，但master节点一直处理NotReady状态，使用命令：journalctl -xeu kubelet，查看错误详情:
# Unable to update cni config: no networks found in /etc/cni/net.d
# 你可能需要设置http代理，因为kubeadm init需要访问https://dl.k8s.io去获取package的信息；
# 你可能还需要设置docker daemon的代理，因为kubeadm init要从http://k8s.gcr.io（这是google cloud的container registry）上pull一些image；
# 你还需要设置no_proxy环境变量为master的IP。否则会报错：“Unable to update cni config: No networks found in /etc/cni/net.d