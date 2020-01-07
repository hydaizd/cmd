k8s官方charts列表没有harbor
https://github.com/helm/charts/tree/master/stable

harbor官方charts文件：
https://github.com/goharbor/harbor-helm/blob/master/README.md

1.安装harbor
(1)添加harbor的helm库：
```
helm repo add harbor https://helm.goharbor.io
```
(2)将harbor下载到本地：
```
helm pull harbor/harbor --version 1.2.3
tar xf harbor-1.2.3.tgz
```
(3)自定义配置，修改文件values.yaml：
```
externalURL: https://harbor.mytest.io
tls:
  commonName: "harbor.mytest.io"
harborAdminPassword: "admin12345"
```
(4)执行安装：
```
helm install harbor-release --namespace harbor-ops  ./harbor
```

2.服务需要请求pv，所以这里我们使用hostPath来创建pv
```
apiVersion: v1 
kind: PersistentVolume
metadata:
  name: harbor-pv1
spec: 
  capacity: #容量
    storage: 10Gi
  volumeMode: Filesystem  #存储卷模式
  accessModes:  #访问模式
  -  ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain # 持久化卷回收策略
  hostPath:
    path: /helm/harbor/pv1
```

重新安装：
```
(1)helm uninstall harbor-release
(2)浏览器输入地址：https://192.168.0.200:32000/#/persistentvolumeclaim?namespace=harbor-ops
删除对应的registry、chartmuseum、jobservice、database、redis存储类
```