# K8s 部署 SkyWalking 原生 Agent 异构链路验证

本目录用于验证 SkyWalking 原生 Agent 接入，不使用 OTel Collector，也不使用 `OTEL_*` 配置。

链路目标：

```text
demo-k8s-agent-java
  -> Java 使用 SWCK 自动注入 SkyWalking Java Agent
demo-k8s-agent-python
  -> Python 使用 apache-skywalking 的 sw-python run 启动
demo-k8s-agent-go
  -> Go 需要 SkyWalking Go Agent 构建期增强
demo-k8s-agent-php
  -> PHP 使用 skywalking_agent 扩展
  -> SkyWalking OAP(11800)
```

### 一、接入方式边界

| 语言 | 本示例接入方式 | 是否纯 K8s 自动注入 |
| --- | --- | --- |
| Java | SWCK Java Agent Injector | 是 |
| Python | 镜像内安装 `apache-skywalking`，启动命令使用 `sw-python run` | 否，需要统一镜像/启动命令 |
| Go | SkyWalking Go Agent 构建期增强 | 否，需要改 CI/CD 构建链路 |
| PHP | 镜像内安装 `skywalking_agent` 扩展，启动时打开扩展 | 否，需要统一 PHP 基础镜像 |

> Go 不是运行时挂载型 agent。当前 `demo-k8s-agent-go` 已去掉 OTel SDK，并在 Dockerfile 构建阶段执行 `go-agent -inject` 和 `-toolexec` 增强；后续更多 Go 项目可以把这段构建逻辑沉到统一 CI/CD 或基础构建模板里。

### 二、前置组件安装

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
# 将 kube-rbac-proxy 镜像地址替换为当前环境更容易拉取的地址 -- 解决镜像拉取问题
sed -i '' 's#gcr.io/kubebuilder/kube-rbac-proxy:v0.8.0#kubebuilder/kube-rbac-proxy:v0.8.0#g' swck-operator-v0.9.0.yaml
# 应用处理后的 SWCK Operator 安装清单
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

本目录的 Java Deployment 已配置：

```yaml
swck-java-agent-injected: "true"
```

所以只要 SWCK Operator、命名空间标签和 `swagent.yaml` 都生效，Java Pod 就会自动注入 `JAVA_TOOL_OPTIONS=-javaagent:/sky/agent/skywalking-agent.jar`。

### 三、部署

#### 1、部署

部署 `SwAgent` 和 4 个异构语言 demo 服务。

```shell
kubectl apply -f swagent.yaml
kubectl apply -f demo-k8s-agent-java.yaml
kubectl apply -f demo-k8s-agent-python.yaml
kubectl apply -f demo-k8s-agent-go.yaml
kubectl apply -f demo-k8s-agent-php.yaml
```

#### 2、重启

重启 Deployment，重新拉起 Pod 以触发最新配置和 SWCK 注入。

```shell
kubectl rollout restart deployment/demo-k8s-agent-java -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-python -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-go -n k8s-agent
kubectl rollout restart deployment/demo-k8s-agent-php -n k8s-agent
```

#### 3、清理

清理本示例部署的 demo 服务、`SwAgent` 和命名空间。

```shell
kubectl delete -f demo-k8s-agent-php.yaml
kubectl delete -f demo-k8s-agent-go.yaml
kubectl delete -f demo-k8s-agent-python.yaml
kubectl delete -f demo-k8s-agent-java.yaml
kubectl delete -f swagent.yaml
kubectl delete -f namespace.yaml
```

#### 4、验证

查看 Pod：

```shell
kubectl get pods -n k8s-agent -o wide
```

Java 验证 SWCK 是否注入成功：

```shell
kubectl describe pod -n k8s-agent -l app=demo-k8s-agent-java
```

重点看是否出现：

```text
sidecar.skywalking.apache.org/succeed: true
JAVA_TOOL_OPTIONS=-javaagent:/sky/agent/skywalking-agent.jar
SW_AGENT_NAME=demo-k8s-agent-java
SW_AGENT_COLLECTOR_BACKEND_SERVICES=skywalking-oap.skywalking.svc.cluster.local:11800
```

### 四、单服务请求

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

### 五、验证 Java -> Python -> Go -> PHP -> Java 闭环链路

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

### 六、查看 SkyWalking

SkyWalking UI：

```text
http://127.0.0.1:18080
```

预期服务：

- `demo-k8s-agent-java`
- `demo-k8s-agent-python`
- `demo-k8s-agent-go`
- `demo-k8s-agent-php`
