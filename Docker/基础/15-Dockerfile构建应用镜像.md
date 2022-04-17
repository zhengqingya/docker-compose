# Dockerfile构建应用镜像

> ex: 构建一个java的jar运行

### Dockerfile

```dockerfile
# 拉取jdk基础镜像
FROM openjdk:8-jdk-alpine

# 维护者信息
MAINTAINER zhengqingya

# 添加jar包到容器中 -- tips: xx.jar 和 Dockerfile 在同一级
ADD app.jar /home/

# 对外暴漏的端口号
# [注：EXPOSE指令只是声明容器运行时提供的服务端口，给读者看有哪些端口，在运行时只会开启程序自身的端口！！]
EXPOSE 80

# 运行🏃🏃🏃
CMD java -jar /home/app.jar
```

### 构建镜像

```shell
# 构建镜像 -f:指定Dockerfile文件路径 --no-cache:构建镜像时不使用缓存
docker build -f Dockerfile -t "registry.cn-hangzhou.aliyuncs.com/zhengqingya/demo:dev" . --no-cache
```

### 运行

```shell
# 运行
docker run -d -p 80:80 --name app registry.cn-hangzhou.aliyuncs.com/zhengqingya/demo:dev
# 进入容器
docker exec -it app /bin/sh
cd /home
```
