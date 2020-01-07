# helm官网：https://helm.sh/
# harbor官方文档：https://github.com/goharbor/harbor-helm
# 参考文档：https://blog.51cto.com/wangpengtai/2418636?source=dra

# Harbor高可用部署
# -master: 192.168.0.200
# -node1: 192.168.0.202

# 1.安装helm（helm是Kubernetes官方提供的包管理工具，主要是是通过管理被称作Helm Chart的包来描述和管理云服务的。使用 Helm后就不需要再编写复杂的应用部署文件，可以以简单的方式在 Kubernetes 上查找、安装、升级、回滚、卸载应用程序。）
# helm3新特性：移除了 Tiller，其他特性具体参考：https://github.com/helm/helm/releases/tag/v3.0.0-alpha.1
$ curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
$ chmod 700 get_helm.sh
$ ./get_helm.sh

# 2.使用helm方式安装harbor到k8s集群中
helm repo add harbor https://helm.goharbor.io

# 创建harbor-ops命名空间
kubectl create namespace harbor-ops
# 查看当前的context
kubectl config current-context
# 设置 context 指定对应的 namespace ，不指定使用的是 default
kubectl config set-context <current-context> --namespace harbor-ops

# 为了简化测试操作，我关闭了数据卷的挂载并使用的是 NodePort 方式进行访问。
# 参数说明：
# persistence.enabled=false 关闭存储，为了方便操作，真实使用时需要挂在存储（pod重启数据会丢失）
# expose.type=nodePort 使用 NodePort 访问
# expose.tls.enabled=false 关闭tls
# externalURL=http://192.168.0.200:30002 设置登录 harbor 的外部链接
helm -n harbor-ops install harbor harbor/harbor \
--set persistence.enabled=false \
--set expose.type=nodePort \
--set expose.tls.enabled=false \
--set externalURL=http://192.168.0.200:30002

# 登录管理后台
# http://192.168.0.200:30002
# 默认账号密码是 admin/Harbor12345

# 删除
helm uninstall harbor harbor

# 查看pod日志
kubectl logs my-release-harbor-notary-server-7b4c79876d-gdm5r