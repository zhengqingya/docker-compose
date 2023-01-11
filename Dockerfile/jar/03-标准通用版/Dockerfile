# jre基础环境
FROM openjdk:8-jre-alpine

# 维护者信息
MAINTAINER zhengqingya

# 构建镜像时传参数据
ARG JAVA_OPTS

# 设置环境变量-运行时也可传参进来耍哈
ENV JAVA_OPTS ${JAVA_OPTS}

# 添加jar包到容器中 -- tips: xx.jar 和 Dockerfile 在同一级
ADD *.jar /home/app.jar
RUN sh -c 'touch /'

# 对外暴漏的端口号
# [注：EXPOSE指令只是声明容器运行时提供的服务端口，给读者看有哪些端口，在运行时只会开启程序自身的端口！！]
EXPOSE 8080


# 以exec格式的CMD指令 -- 可实现优雅停止容器服务
# "sh", "-c" : 可通过exec模式执行shell  =》 获得环境变量
ENV RUN_CMD "java -jar ${JAVA_OPTS} /home/app.jar"
CMD ["sh", "-c", "echo \"****** 运行命令：${RUN_CMD}\"   &   ${RUN_CMD}"]
