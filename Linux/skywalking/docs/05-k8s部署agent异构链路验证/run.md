# K8s 部署 SkyWalking 原生 Agent 异构链路验证

本目录用于验证 SkyWalking 原生 Agent 接入，不使用 OTel Collector，也不使用 `OTEL_*` 配置。

链路目标：

```text
demo-agent-java
  -> Java 使用 SWCK 自动注入 SkyWalking Java Agent
demo-agent-python
  -> Python 使用 apache-skywalking 的 sw-python run 启动
demo-agent-go
  -> Go 需要 SkyWalking Go Agent 构建期增强
demo-agent-php
  -> PHP 使用 skywalking_agent 扩展
  -> SkyWalking OAP(11800)
```

## 一、接入方式边界

| 语言 | 本示例接入方式 | 是否纯 K8s 自动注入 |
| --- | --- | --- |
| Java | SWCK Java Agent Injector | 是 |
| Python | 镜像内安装 `apache-skywalking`，启动命令使用 `sw-python run` | 否，需要统一镜像/启动命令 |
| Go | SkyWalking Go Agent 构建期增强 | 否，需要改 CI/CD 构建链路 |
| PHP | 镜像内安装 `skywalking_agent` 扩展，启动时打开扩展 | 否，需要统一 PHP 基础镜像 |

> Go 不是运行时挂载型 agent。当前 `demo-agent-go` 已去掉 OTel SDK，并在 Dockerfile 构建阶段执行 `go-agent -inject` 和 `-toolexec` 增强；后续更多 Go 项目可以把这段构建逻辑沉到统一 CI/CD 或基础构建模板里。

## 二、部署

```shell
kubectl apply -f namespace.yaml
kubectl apply -f swagent.yaml
kubectl apply -f demo-agent-java.yaml
kubectl apply -f demo-agent-python.yaml
kubectl apply -f demo-agent-go.yaml
kubectl apply -f demo-agent-php.yaml
```

查看 Pod：

```shell
kubectl get pods -n k8s-agent -o wide
```

Java 验证 SWCK 是否注入成功：

```shell
kubectl describe pod -n k8s-agent -l app=demo-agent-java
```

重点看是否出现：

```text
sidecar.skywalking.apache.org/succeed: true
JAVA_TOOL_OPTIONS=-javaagent:/sky/agent/skywalking-agent.jar
SW_AGENT_NAME=demo-agent-java
SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking.svc.cluster.local:11800
```

## 三、单服务请求

```shell
curl http://127.0.0.1:31082/hello
curl http://127.0.0.1:31083/hello
curl http://127.0.0.1:31084/hello
curl http://127.0.0.1:31085/hello
```

## 四、验证 Java -> Python -> Go -> PHP -> Java 闭环链路

```shell
curl -s "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http%3A%2F%2Fdemo-agent-python%3A31083%2Fchain%3FtargetName%3Dgo%26targetUrl%3Dhttp%253A%252F%252Fdemo-agent-go%253A31084%252Fchain%253FtargetName%253Dphp%2526targetUrl%253Dhttp%25253A%25252F%25252Fdemo-agent-php%25253A31085%25252Fchain%25253FtargetName%25253Djava%252526targetUrl%25253Dhttp%2525253A%2525252F%2525252Fdemo-agent-java%2525253A31082%2525252Ftrace%2525252Ffinal" | jq
```

链路方向：

```text
curl
  -> demo-agent-java
  -> demo-agent-python
  -> demo-agent-go
  -> demo-agent-php
  -> demo-agent-java
```

## 五、查看 SkyWalking

SkyWalking UI：

```text
http://127.0.0.1:18080
```

预期服务：

- `demo-agent-java`
- `demo-agent-python`
- `demo-agent-go`
- `demo-agent-php`

## 六、清理

```shell
kubectl delete -f demo-agent-php.yaml
kubectl delete -f demo-agent-go.yaml
kubectl delete -f demo-agent-python.yaml
kubectl delete -f demo-agent-java.yaml
kubectl delete -f swagent.yaml
kubectl delete -f namespace.yaml
```
