# Apache SkyWalking

分布式系统的应用程序性能监控工具，特别为微服务、云原生和基于容器(Kubernetes)架构设计。

- https://skywalking.apache.org

### 部署

```shell
docker-compose -f docker-compose.yml -p skywalking up -d
```

访问 http://127.0.0.1:8888

### Java项目配置

下载`Java Agent` https://skywalking.apache.org/downloads/

> eg: https://dlcdn.apache.org/skywalking/java-agent/8.15.0/apache-skywalking-java-agent-8.15.0.tgz

修改`skywalking-agent\config\agent.config`中配置参数 或 在jvm运行的时候指定

在java项目运行启动的时候，添加如下运行参数

```shell
-javaagent:D:\tmp\skywalking-agent\skywalking-agent.jar -DSW_AGENT_NAME=test -DSW_AGENT_COLLECTOR_BACKEND_SERVICES=127.0.0.1:11800
```

项目跑起来之后调用下接口，就可以去SkyWalking中查看拓扑图，追踪等信息了...
