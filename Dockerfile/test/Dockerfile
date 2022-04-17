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
