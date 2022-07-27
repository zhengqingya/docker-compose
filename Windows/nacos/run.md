### Nacos

```shell
docker-compose -f docker-compose-nacos.yml -p nacos up -d

# mysql数据库版 【 需自己建库`nacos_config`, 并执行`/Windows/nacos_xxx/nacos-mysql.sql`脚本 】
docker-compose -f docker-compose-nacos-1.4.1.yml -p nacos up -d
```

访问地址：[`http://127.0.0.1:8848/nacos`](http://127.0.0.1:8848/nacos)
登录账号密码默认：`nacos/nacos`

> 注：`docker-compose-nacos-1.4.1-mysql.yml`已开启连接密码安全认证，在java连接时需新增配置如下

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