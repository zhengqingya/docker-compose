### Nacos

```shell
# mysql数据库版 【 需自己建库`nacos_config`, 并执行`nacos_xxx/nacos-mysql.sql`脚本 】
# nacos1.4.1版本
docker-compose -f docker-compose-nacos-1.4.1.yml -p nacos_v1.4.1 up -d
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
