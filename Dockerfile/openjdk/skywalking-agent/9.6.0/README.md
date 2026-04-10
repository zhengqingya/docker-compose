# 制作 skywalking-agent 9.6.0 的jdk8基础镜像

下载并解压 `skywalking-agent` https://skywalking.apache.org/downloads/

> eg: https://dlcdn.apache.org/skywalking/java-agent/9.6.0/apache-skywalking-java-agent-9.6.0.tgz

```shell
# 构建镜像
docker build -t registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.6.0 . --no-cache
# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.6.0
```

# 使用

```shell
# 1、Dockerfile中引用基础镜像
# FROM registry.cn-hangzhou.aliyuncs.com/zhengqing/openjdk:8-jre-alpine-skywalking-agent-9.6.0

# 2、设置jar运行参数 -javaagent:/home/skywalking-agent/skywalking-agent.jar  -Dskywalking.agent.service_name=demo -Dskywalking.collector.backend_service=127.0.0.1:11800
```

> 说明：镜像中需保留整个 `/home/skywalking-agent` 目录。
> 启动时会读取 `config/agent.config` 配置；加载 `plugins/` 目录里的插件 jar，删掉某个插件 jar 就等于禁用该插件
