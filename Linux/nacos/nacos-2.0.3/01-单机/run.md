### Nacos

```shell
# nacos2.0.3版本
docker-compose -f docker-compose-nacos-2.0.3.yml -p nacos_v2.0.3 up -d
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

