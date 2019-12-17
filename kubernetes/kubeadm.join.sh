#!/bin/bash
# :set fileformat=unix

cat <<EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/16
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF

# 新增master节点
kubeadm join 192.168.33.10:16443 --token oxio16.6lo2jos8m3sfcveu \
    --discovery-token-ca-cert-hash sha256:ab474955c3dd1ba090dbf53795ed9bbcdc18c1e45fa6dc2ad2e9681668dc4d9c \
    --control-plane --ignore-preflight-errors=Swap --v=5

# this Docker version is not on the list of validated versions: 19.03.5. Latest validated version: 18.09

# 新增node节点

kubeadm join 192.168.33.10:16443 --token oxio16.6lo2jos8m3sfcveu \
    --discovery-token-ca-cert-hash sha256:ab474955c3dd1ba090dbf53795ed9bbcdc18c1e45fa6dc2ad2e9681668dc4d9c \
    --ignore-preflight-errors=Swap --v=5

# (可选项)执行以下操作，方便从节点可以像master节点一样执行命令行操作（其中admin.conf需要从master节点先拷贝过来）
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config



# ---------------------------------------- 错误列表 ----------------------------------------
# 1. 执行kubeadm join时报错（前提条件保证token没有过期）：
# error execution phase preflight: couldn't validate the identity of the API Server: abort connecting to API servers after timeout of 5m0s
# To see the stack trace of this error execute with --v=5 or higher
# 解决方法：执行kubeadm join时，附加参数--v=5，可查看错误跟踪
# 注意token过期时间问题，查找中国时区的完整名称：
# timedatectl list-timezones |grep Shanghai
# 其他时区以此类推
# timedatectl set-timezone Asia/Shanghai
# 实际解决成功：kubeadm-config.yaml配置文件添加如下配置：
# apiServer:
#  certSANs:
#  - "192.168.33.10"
# -----------------------------------------------------
# 2.提示加入成功，但使用kubectl get nodes，却查找不到新加入的node节点
# 解决方法：执行tail -f /var/log/messages，可查看具体错误：network: open /run/flannel/subnet.env: no such file or directory
