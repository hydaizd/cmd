#!/bin/bash
# :set fileformat=unix

# 修改host，追加内容
cat >> /etc/hosts << EOF
192.168.33.10 apiserver.cluster.local
EOF

# 修改init配置
# 官方文档：https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2
cat << EOF > /home/kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration

# 指定k8s的版本
kubernetesVersion: v1.16.0

# 指定镜像仓库源
imageRepository: registry.aliyuncs.com/google_containers

# apiServer的集群访问地址（haproxy地址及端口）
controlPlaneEndpoint: "192.168.33.10:6443"
apiServer:
  certSANs:
  - "192.168.33.10"

# flannel网络插件，指定pod网段及掩码（pod之间相互通信插件默认网段：flannel：10.244.0.0/16 我们使用flannel，calico：192.168.0.0/16）
networking:
  serviceSubnet: "10.96.0.0/12"
  podSubnet: "10.244.0.0/16"
EOF

# 通过阿里源预先拉镜像
kubeadm config images pull --config /home/kubeadm-config.yaml

# 重新初始化需重置
# kubeadm reset

# --ignore-preflight-errors参数如果是物理机，内存比较大可以不指定此参数
# --upload-certs参数可以在后续执行加入节点时自动分发证书文件（--experimental-upload-certs已被弃用, 使用--upload-certs代替）
kubeadm init --config=/home/kubeadm-config.yaml --ignore-preflight-errors=Swap --upload-certs --v=5

# 初始化完成后需要按提示的操作执行一遍，否则配置网络会出错：Get http://localhost:8080/api?timeout=32s: dial tcp [::1]:8080: connect: connection refused
mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 初始化后，需要在master节点上配置网络，否则master节点上的coredns容器无法启动（yml文件中已包含了rbac配置）
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 查看token
# kubeadm token list
# 加入集群除了需要 token 外，还需要 Master 节点的 ca 证书 sha256 编码 hash 值，这个可以通过如下命令获取（保持不变）：
# openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
# -------------------------------------------
# 重新生成加入命令
# kubeadm token create --print-join-command

# https://192.168.33.10:16443/api/v1/namespaces/default/pods?limit=500
# kube-apiserver 支持同时提供 https（默认监听在 6443 端口）和 http API（默认监听在 127.0.0.1 的 8080 端口），其中 http API 是非安全接口，不做任何认证授权机制，不建议生产环境启用

# ---------------------------------------- 错误列表 ----------------------------------------
# 1.手动执行
# scp -r /etc/kubernetes/admin.conf root@192.168.33.12:/etc/kubernetes/，再输入密码
# -------------------------------------------
# 查看错误详情
# systemctl status kubelet -l

# 查看pod状态 
# kubectl get pod --all-namespaces
# 查看某个pos的日志
# kubectl describe pod kube-flannel-ds-amd64-7d2dx --namespace=kube-system
# kubectl logs kube-flannel-ds-amd64-7d2dx -n=kube-system 