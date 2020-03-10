1.创建服务
```
kit new service users
kit new service bugs
kit new service notificator
---
kit generate service users --dmw
kit generate service bugs --dmw
---
因为通知服务是一个内部服务，所以不需要 REST API，我们用 gRPC 来实现它
kit generate service notificator -t grpc --dmw
```

2.创建 docker-compose 模板
```
kit generate docker
```
