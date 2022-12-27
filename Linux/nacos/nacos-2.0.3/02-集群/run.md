### Nacos

```shell
# nacos集群2.0.3版本
# java客户端连接 "-Dspring.cloud.nacos.discovery.server-addr=www.zhengqingya.com:8880 -Dspring.cloud.nacos.discovery.username=nacos -Dspring.cloud.nacos.discovery.password=nacos"
docker-compose -f docker-compose-nacos-cluster-2.0.3.yml -p nacos_cluster_v2.0.3 up -d
```

访问地址：[`ip地址:8848/nacos`](http://www.zhengqingya.com:8848/nacos)
登录账号密码默认：`nacos/nacos`

> 注：`docker-compose-nacos-xxx.yml`已开启连接密码安全认证，在java连接时需新增配置如下

```yml
spring:
  cloud:
    nacos:
      discovery:
        username: nacos
        password: nacos
      config:
        username: ${spring.cloud.nacos.discovery.username}
        password: ${spring.cloud.nacos.discovery.password}
```

集群
![nacos集群节点列表.png](./nacos-cluster-nodes.png)

nginx配置修改生效

```shell
# 进入容器
docker exec -it nacos_nginx /bin/bash
# nginx修改配置后重载
nginx -s reload
```
