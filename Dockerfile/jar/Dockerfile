#FROM openjdk:8-jre-alpine   【 注：jre中并没有携带工具文件，但arthas需要依赖lib包和bin包里面的包和工具，arthas需要jps工具和lib包里的内容 】
# 使用自制jdk
FROM registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jdk-alpine

# 维护者信息
MAINTAINER zhengqingya

# 构建镜像时传参数据
ARG APP_NAME
ARG APP_PORT
ARG JAVA_OPTS

# 设置环境变量-运行时也可传参进来耍哈
ENV APP_NAME ${APP_NAME}
ENV APP_JAR ${APP_NAME}.jar
ENV APP_PORT ${APP_PORT}
ENV JAVA_OPTS ${JAVA_OPTS}
# -XX:+UseG1GC -Xms64m -Xmx64m -Xmn16m -XX:MetaspaceSize=100m -XX:MaxMetaspaceSize=100m -XX:MaxGCPauseMillis=200 -XX:ParallelGCThreads=8 -Ddefault.client.encoding=UTF-8 -Dfile.encoding=UTF-8 -Duser.language=Zh -Duser.region=CN -Dspring.profiles.active=xx -Dspring.cloud.nacos.discovery.server-addr=xx -Dspring.cloud.nacos.discovery.username=nacos -Dspring.cloud.nacos.discovery.password=nacos
# 远程调试参数： -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5001


# copy arthas
COPY --from=hengyunabc/arthas:latest /opt/arthas /opt/arthas


# 添加jar包到容器中 -- tips: xx.jar 和 Dockerfile 在同一级
ADD ${APP_JAR} /home/
RUN sh -c 'touch /'

VOLUME /tmp

# 对外暴漏的端口号
# [注：EXPOSE指令只是声明容器运行时提供的服务端口，给读者看有哪些端口，在运行时只会开启程序自身的端口！！]
EXPOSE ${APP_PORT}

# 让你先休息3秒再开始运行吧🏃🏃🏃
CMD echo "****** Start... " & \
    echo "****** APP_JAR: ${APP_JAR} " & \
    echo "****** APP_PORT: ${APP_PORT} " & \
    echo "****** JAVA_OPTS: ${JAVA_OPTS} " & \
    echo "****** ${APP_JAR} will run ..." & \
    sleep 3 & \
    echo "****** 运行命令：nohup java -jar ${JAVA_OPTS} /home/${APP_JAR} >> /home/${APP_NAME}.log 2>&1 &" & \
    nohup java -jar ${JAVA_OPTS} /home/${APP_JAR} >> /home/${APP_NAME}.log 2>&1 & \
    echo "****** 查看日志..." & \
    tail -f /home/${APP_NAME}.log
