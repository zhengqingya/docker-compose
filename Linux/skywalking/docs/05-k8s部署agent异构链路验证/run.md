# K8s 部署 SkyWalking 原生 Agent 异构链路验证

### 一、验证目标

本目录用于验证 SkyWalking 原生 Agent 接入，不使用 OTel Collector，也不使用 `OTEL_*` 配置。

链路目标：

```text
demo-k8s-agent-java
  -> Java 使用 SWCK 自动注入 SkyWalking Java Agent
demo-k8s-agent-python
  -> Python 使用 apache-skywalking 的 sw-python run 启动
demo-k8s-agent-go
  -> Go 使用 SkyWalking Go Agent 构建期增强
demo-k8s-agent-php
  -> PHP 使用 skywalking_agent 扩展
  -> SkyWalking OAP(11800)
```

### 二、接入方式边界

#### 1、语言接入方式

| 语言 | 本示例接入方式 | 是否纯 K8s 自动注入 |
| --- | --- | --- |
| Java | SWCK Java Agent Injector | 是 |
| Python | 镜像内安装 `apache-skywalking`，启动命令使用 `sw-python run` | 否，需要统一镜像/启动命令 |
| Go | SkyWalking Go Agent 构建期增强 | 否，需要改 CI/CD 构建链路 |
| PHP | 镜像内安装 `skywalking_agent` 扩展，启动时打开扩展 | 否，需要统一 PHP 基础镜像 |

> Go 不是运行时挂载型 agent。当前 `demo-k8s-agent-go` 在 Dockerfile 构建阶段执行 `go-agent -inject` 和 `-toolexec` 增强；后续更多 Go 项目可以把这段构建逻辑沉到统一 CI/CD 或基础构建模板里。

#### 2、日志上报边界

本示例的日志关联验证以 SkyWalking 原生 Agent 日志上报为准：

- Java 使用 `GRPCLogClientAppender` 上报日志。
- Python 使用 `SW_AGENT_LOG_REPORTER_ACTIVE=true` 上报日志。
- Go 使用 SkyWalking Go Agent 的 zap 日志插件和 `SW_LOG_REPORTER_ENABLE=true` 上报日志。
- PHP 使用 `skywalking_agent.psr_logging_level=Info` hook PSR-3 LoggerInterface 上报日志。

如果同时部署了 OTel filelog DaemonSet，它只能作为 stdout/stderr 兜底采集链路；SkyWalking UI 的追踪 ID 关联筛选以原生 Agent 上报的日志为准。

### 三、前置组件安装

Java 服务依赖 SWCK 自动注入 SkyWalking Java Agent，部署本示例前需要先准备 SWCK 相关组件。

#### 1、安装 cert-manager

检查并安装 `cert-manager`，用于给 SWCK webhook 证书签发和注入。

```shell
# 如果已经安装，可跳过
kubectl get pods -A | grep cert-manager

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml

kubectl get pods -n cert-manager
```

确认 `cert-manager`、`cert-manager-cainjector`、`cert-manager-webhook` 都是 `Running`。

#### 2、安装 SWCK Operator

检查并安装 SWCK Operator，提供 `SwAgent` CRD、自动注入 webhook 和 controller。

```shell
# 1、如果已经安装，可跳过
kubectl get pods -A | grep -i skywalking
kubectl get crd | grep -i skywalking
kubectl get mutatingwebhookconfigurations | grep -i skywalking

# 2、生成 SWCK Operator 安装清单到本地文件，方便统一调整镜像后再安装
kubectl kustomize "github.com/apache/skywalking-swck/operator/config/default?ref=v0.9.0" > swck-operator-v0.9.0.yaml

# 3、将 kube-rbac-proxy 镜像地址替换为当前环境更容易拉取的地址 -- 解决镜像拉取问题
sed -i '' 's#gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0#kubebuilder/kube-rbac-proxy:v0.8.0#g' swck-operator-v0.9.0.yaml

# 4、应用处理后的 SWCK Operator 安装清单
kubectl apply -f swck-operator-v0.9.0.yaml
```

验证：

```shell
kubectl get pods -n skywalking-swck-system
kubectl get crd | grep -i skywalking
kubectl get mutatingwebhookconfigurations | grep -i skywalking
```

#### 3、开启目标命名空间自动注入

创建 `k8s-agent` 命名空间，并开启 SWCK 自动注入开关。

```shell
kubectl apply -f namespace.yaml
kubectl label namespace k8s-agent swck-injection=enabled --overwrite
kubectl get namespace k8s-agent --show-labels
```

确认 `k8s-agent` 命名空间带有：

```text
swck-injection=enabled
```

### 四、一键部署 / 删除

#### 1、一键部署

```shell
kubectl apply -f namespace.yaml
kubectl label namespace k8s-agent swck-injection=enabled --overwrite
kubectl apply -f swagent.yaml
kubectl apply -f demo-k8s-agent-java.yaml
kubectl apply -f demo-k8s-agent-python.yaml
kubectl apply -f demo-k8s-agent-go.yaml
kubectl apply -f demo-k8s-agent-php.yaml
```

#### 2、一键重启

```shell
kubectl rollout restart deployment/demo-k8s-agent-java -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-python -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-go -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-php -n k8s-agent
```

#### 3、一键删除

```shell
kubectl delete -f demo-k8s-agent-php.yaml
kubectl delete -f demo-k8s-agent-go.yaml
kubectl delete -f demo-k8s-agent-python.yaml
kubectl delete -f demo-k8s-agent-java.yaml
kubectl delete -f swagent.yaml
kubectl delete -f namespace.yaml
```

### 五、分语言部署与验证

#### 1、Java 服务接入

##### 1.1、接入方式说明

Java 通过 SWCK 自动注入 SkyWalking Java Agent。本目录的 Java Deployment 已配置：

```yaml
swck-java-agent-injected: "true"
```

只要 SWCK Operator、命名空间标签和 `swagent.yaml` 都生效，Java Pod 就会自动注入：

```text
JAVA_TOOL_OPTIONS=-javaagent:/sky/agent/skywalking-agent.jar
```

##### 1.2、部署 Java 示例服务

```shell
kubectl apply -f swagent.yaml
kubectl apply -f demo-k8s-agent-java.yaml
# kubectl delete -f demo-k8s-agent-java.yaml
# kubectl rollout restart deployment/demo-k8s-agent-java -n k8s-agent
```

##### 1.3、验证 Java 注入是否生效

```shell
kubectl get pods -n k8s-agent -o wide
kubectl describe pod -n k8s-agent -l app=demo-k8s-agent-java
```

重点看是否出现：

```text
sidecar.skywalking.apache.org/succeed: true
JAVA_TOOL_OPTIONS=-javaagent:/sky/agent/skywalking-agent.jar
SW_AGENT_NAME=demo-k8s-agent-java
SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking.svc.cluster.local:11800
```

##### 1.4、请求 Java 接口

```shell
curl http://127.0.0.1:31082/hello
curl "http://127.0.0.1:31082/chain?targetName=python"
curl "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http://demo-k8s-agent-python:31083/hello?name=from-java"
```

##### 1.5、查看 Java 日志链路信息

```shell
kubectl logs -n k8s-agent deploy/demo-k8s-agent-java --tail=20 -f
```

#### 2、Python 服务接入

##### 2.1、接入方式说明

Python 通过镜像内 `apache-skywalking` 包接入，启动命令使用 `sw-python run`。

关键环境变量：

```text
SW_AGENT_NAME=demo-k8s-agent-python
SW_AGENT_PROTOCOL=grpc
SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking.svc.cluster.local:11800
SW_AGENT_LOG_REPORTER_ACTIVE=true
```

##### 2.2、部署 Python 示例服务

```shell
kubectl apply -f demo-k8s-agent-python.yaml
# kubectl delete -f demo-k8s-agent-python.yaml
# kubectl rollout restart deployment/demo-k8s-agent-python -n k8s-agent
```

##### 2.3、验证 Python Agent 配置

```shell
kubectl get pods -n k8s-agent -o wide
kubectl describe pod -n k8s-agent -l app=demo-k8s-agent-python
```

##### 2.4、请求 Python 接口

```shell
curl http://127.0.0.1:31083/hello
curl "http://127.0.0.1:31083/chain?targetName=go"
curl "http://127.0.0.1:31083/chain?targetName=go&targetUrl=http://demo-k8s-agent-go:31084/hello?name=from-python"
```

##### 2.5、查看 Python 日志链路信息

```shell
kubectl logs -n k8s-agent deploy/demo-k8s-agent-python --tail=20 -f
```

#### 3、Go 服务接入

##### 3.1、接入方式说明

Go 通过 SkyWalking Go Agent 构建期增强接入，不依赖运行时自动注入。

关键环境变量：

```text
SW_AGENT_NAME=demo-k8s-agent-go
SW_AGENT_REPORTER_GRPC_BACKEND_SERVICE=skywalking-oap.skywalking.svc.cluster.local:11800
SW_LOG_REPORTER_ENABLE=true
```

##### 3.2、部署 Go 示例服务

```shell
kubectl apply -f demo-k8s-agent-go.yaml
# kubectl delete -f demo-k8s-agent-go.yaml
# kubectl rollout restart deployment/demo-k8s-agent-go -n k8s-agent
```

##### 3.3、验证 Go Agent 配置

```shell
kubectl get pods -n k8s-agent -o wide
kubectl describe pod -n k8s-agent -l app=demo-k8s-agent-go
```

##### 3.4、请求 Go 接口

```shell
curl http://127.0.0.1:31084/hello
curl "http://127.0.0.1:31084/chain?targetName=php"
curl "http://127.0.0.1:31084/chain?targetName=php&targetUrl=http://demo-k8s-agent-php:31085/hello?name=from-go"
```

##### 3.5、查看 Go 日志链路信息

```shell
kubectl logs -n k8s-agent deploy/demo-k8s-agent-go --tail=20 -f
```

#### 4、PHP 服务接入

##### 4.1、接入方式说明

PHP 通过镜像内 `skywalking_agent` 扩展接入，K8s 部署使用 `Nginx + PHP-FPM`。

关键环境变量和 ini 配置：

```text
SW_AGENT_NAME=demo-k8s-agent-php
SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking.svc.cluster.local:11800
skywalking_agent.enable=On
skywalking_agent.reporter_type=grpc
skywalking_agent.psr_logging_level=Info
```

##### 4.2、部署 PHP 示例服务

```shell
kubectl apply -f demo-k8s-agent-php.yaml
# kubectl delete -f demo-k8s-agent-php.yaml
# kubectl rollout restart deployment/demo-k8s-agent-php -n k8s-agent
```

##### 4.3、验证 PHP Agent 配置

```shell
kubectl get pods -n k8s-agent -o wide
kubectl describe pod -n k8s-agent -l app=demo-k8s-agent-php
```

##### 4.4、请求 PHP 接口

```shell
curl http://127.0.0.1:31085/hello
curl "http://127.0.0.1:31085/chain?targetName=java"
curl "http://127.0.0.1:31085/chain?targetName=java&targetUrl=http://demo-k8s-agent-java:31082/hello?name=from-php"
```

##### 4.5、查看 PHP 日志链路信息

```shell
# 查看 PHP Nginx 访问日志
kubectl logs -n k8s-agent deploy/demo-k8s-agent-php -c nginx --tail=20 -f

# 查看 PHP-FPM 应用日志
kubectl logs -n k8s-agent deploy/demo-k8s-agent-php -c php-fpm --tail=20 -f
```

### 六、单服务请求

```shell
# 请求 Java 服务 demo-k8s-agent-java
curl http://127.0.0.1:31082/hello

# 请求 Python 服务 demo-k8s-agent-python
curl http://127.0.0.1:31083/hello

# 请求 Go 服务 demo-k8s-agent-go
curl http://127.0.0.1:31084/hello

# 请求 PHP 服务 demo-k8s-agent-php
curl http://127.0.0.1:31085/hello
```

### 七、验证 Java -> Python -> Go -> PHP -> Java 闭环链路

```shell
curl -s "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http%3A%2F%2Fdemo-k8s-agent-python%3A31083%2Fchain%3FtargetName%3Dgo%26targetUrl%3Dhttp%253A%252F%252Fdemo-k8s-agent-go%253A31084%252Fchain%253FtargetName%253Dphp%2526targetUrl%253Dhttp%25253A%25252F%25252Fdemo-k8s-agent-php%25253A31085%25252Fchain%25253FtargetName%25253Djava%252526targetUrl%25253Dhttp%2525253A%2525252F%2525252Fdemo-k8s-agent-java%2525253A31082%2525252Ftrace%2525252Ffinal" | jq
```

链路方向：

```text
curl
  -> demo-k8s-agent-java
  -> demo-k8s-agent-python
  -> demo-k8s-agent-go
  -> demo-k8s-agent-php
  -> demo-k8s-agent-java
```

### 八、SkyWalking 中查看

SkyWalking UI：

```text
http://127.0.0.1:18080
```

预期服务：

- `demo-k8s-agent-java`
- `demo-k8s-agent-python`
- `demo-k8s-agent-go`
- `demo-k8s-agent-php`
