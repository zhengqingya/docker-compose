# 制作skywalking-agent的jdk8基础镜像

下载并解压 `skywalking-agent` https://skywalking.apache.org/downloads/

> eg: https://dlcdn.apache.org/skywalking/java-agent/9.1.0/apache-skywalking-java-agent-9.1.0.tgz

```shell
# 构建镜像
docker build -t registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.1.0 . --no-cache
# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.1.0
```

# 使用

```shell
# 1、Dockerfile中引用基础镜像
# FROM registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.1.0

# 2、设置jar运行参数 -javaagent:/home/skywalking-agent/skywalking-agent.jar  -DSW_AGENT_NAME=demo -DSW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800
```
