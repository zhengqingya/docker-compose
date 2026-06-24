# Grafana OTel K8s 异构 APM 验证

本目录用于在 Docker Desktop Kubernetes 中独立部署：

- Grafana `13.1.0`
- Tempo `2.9.0`
- Loki `3.6.7`
- Prometheus `3.12.0`
- OpenTelemetry Collector `0.154.0`
- Java / Python / Go / PHP OpenTelemetry 示例服务

这套环境不依赖 SigNoz 或 SkyWalking，也不会向旧环境双写数据。

## 一、架构

```text
Java / Python / Go / PHP
              -> OpenTelemetry Collector(4317/4318)
                    |- Traces  -> Tempo
                    |- Logs    -> Loki
                    `- Metrics -> Prometheus
                                         |
                                      Grafana(30080)
```

命名空间：

```text
grafana-observability  Grafana、Tempo、Loki、Prometheus、OTel Collector
grafana-demo           Java、Python、Go、PHP 示例服务
```

本方案只接收四个 Demo 主动发送的 OTLP Logs，不部署节点日志采集 DaemonSet。

## 二、前置条件

### 1、检查 Kubernetes 和 Helm

```shell
kubectl config current-context
kubectl get nodes
kubectl get storageclass
helm version --short
```

预期：

- Kubernetes context 为 `docker-desktop`。
- 默认 StorageClass 为 `standard`。
- Helm 版本为 `v3.18.0` 或兼容版本。
- Docker Desktop 建议分配至少 `6 CPU / 8GB` 内存。

### 2、检查 OpenTelemetry Operator

Java 和 Python 使用 OpenTelemetry Operator 自动注入：

```shell
kubectl get pods -n opentelemetry-operator-system
kubectl get crd | grep -i opentelemetry
```

本环境沿用 Operator `v0.151.0`。未安装时先安装 cert-manager 和 Operator：

```shell
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/download/v0.151.0/opentelemetry-operator.yaml
```

### 3、同步镜像

安装并登录 skopeo：

```shell
brew install skopeo
skopeo login registry.cn-hangzhou.aliyuncs.com
```

同步全部多架构镜像：

```shell
chmod +x sync-images.sh
./sync-images.sh
```

确认阿里云仓库已设为公开，并抽查镜像：

```shell
skopeo inspect --raw docker://registry.cn-hangzhou.aliyuncs.com/zhengqing/tempo:2.9.0 | jq
skopeo inspect --raw docker://registry.cn-hangzhou.aliyuncs.com/zhengqing/loki:3.6.7 | jq
skopeo inspect --raw docker://registry.cn-hangzhou.aliyuncs.com/zhengqing/grafana:13.1.0 | jq
skopeo inspect --raw docker://registry.cn-hangzhou.aliyuncs.com/zhengqing/prometheus:v3.12.0 | jq
skopeo inspect --raw docker://registry.cn-hangzhou.aliyuncs.com/zhengqing/opentelemetry-collector-k8s:0.154.0 | jq
```

## 三、一键部署后端

### 1、更新 Chart 依赖

`Chart.yaml` 声明依赖，`Chart.lock` 锁定实际版本，`charts/` 是本地下载产物，不提交 Git。

首次拉取代码或本地 `charts/` 不存在时执行：

```shell
helm dependency build
```

仅在主动修改 `Chart.yaml` 中的组件版本后执行 `helm dependency update`，并提交更新后的 `Chart.lock`。

### 2、一键安装或升级

一个 Helm Release 同时部署 Grafana、Tempo、Loki、Prometheus、OpenTelemetry Collector、Dashboard 和 `grafana-demo` namespace：

```shell
helm upgrade --install grafana-otel . \
  --namespace grafana-observability \
  --create-namespace \
  --values values.yaml \
  --wait \
  --timeout 20m
```

Tempo Chart `1.24.4` 可能输出 `This chart is deprecated`，这是 Chart 维护状态提示，不影响本方案固定版本的本地验证。

### 3、查看后端状态

```shell
helm list -n grafana-observability
kubectl get pods -n grafana-observability
kubectl get svc -n grafana-observability
kubectl get pvc -n grafana-observability
```

持续观察 Pod：

```shell
kubectl get pods -n grafana-observability -w
```

## 四、访问 Grafana

```text
地址：http://127.0.0.1:30080
账号：admin
密码：grafana123
```

健康检查：

```shell
curl http://127.0.0.1:30080/api/health
```

Docker Desktop 无法直接访问 LoadBalancer 时使用：

```shell
kubectl port-forward -n grafana-observability svc/grafana 30080:30080
```

Grafana 已自动配置：

- Prometheus：默认数据源
- Loki：日志数据源
- Tempo：链路数据源
- `OTel/OTel 异构接口监控` Dashboard

## 五、部署异构 Demo

### 1、一键部署

`grafana-demo` namespace 已由 `grafana-otel` Helm Release 创建：

```shell
kubectl apply -f instrumentation-java.yaml
kubectl apply -f instrumentation-python.yaml
kubectl apply -f demo-k8s-otel-java.yaml
kubectl apply -f demo-k8s-otel-python.yaml
kubectl apply -f demo-k8s-otel-go.yaml
kubectl apply -f demo-k8s-otel-php.yaml
```

### 2、查看状态

```shell
kubectl get instrumentation -n grafana-demo
kubectl get pods -n grafana-demo -o wide
kubectl get svc -n grafana-demo
```

确认 Java、Python 已被 Operator 注入：

```shell
kubectl describe pod -n grafana-demo -l app=demo-k8s-otel-java
kubectl describe pod -n grafana-demo -l app=demo-k8s-otel-python
```

### 3、一键重启

```shell
kubectl rollout restart deployment/demo-k8s-otel-java -n grafana-demo
kubectl rollout restart deployment/demo-k8s-otel-python -n grafana-demo
kubectl rollout restart deployment/demo-k8s-otel-go -n grafana-demo
kubectl rollout restart deployment/demo-k8s-otel-php -n grafana-demo
```

## 六、访问地址

```text
Java:   http://127.0.0.1:31082
Python: http://127.0.0.1:31083
Go:     http://127.0.0.1:31084
PHP:    http://127.0.0.1:31085
```

集群内 Collector：

```text
OTLP gRPC: otel-collector.grafana-observability.svc.cluster.local:4317
OTLP HTTP: http://otel-collector.grafana-observability.svc.cluster.local:4318
```

宿主机应用临时接入：

```shell
kubectl port-forward -n grafana-observability svc/otel-collector 4317:4317 4318:4318
```

## 七、生成验证数据

### 1、单服务请求

```shell
curl "http://127.0.0.1:31082/hello?name=java"
curl "http://127.0.0.1:31083/hello?name=python"
curl "http://127.0.0.1:31084/hello?name=go"
curl "http://127.0.0.1:31085/hello?name=php"
```

### 2、双服务链路

```shell
curl "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http://demo-k8s-otel-python:31083/hello?name=from-java"
curl "http://127.0.0.1:31083/chain?targetName=go&targetUrl=http://demo-k8s-otel-go:31084/hello?name=from-python"
curl "http://127.0.0.1:31084/chain?targetName=php&targetUrl=http://demo-k8s-otel-php:31085/hello?name=from-go"
curl "http://127.0.0.1:31085/chain?targetName=java&targetUrl=http://demo-k8s-otel-java:31082/hello?name=from-php"
```

### 3、四语言嵌套链路

```shell
curl -s "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http%3A%2F%2Fdemo-k8s-otel-python%3A31083%2Fchain%3FtargetName%3Dgo%26targetUrl%3Dhttp%253A%252F%252Fdemo-k8s-otel-go%253A31084%252Fchain%253FtargetName%253Dphp%2526targetUrl%253Dhttp%25253A%25252F%25252Fdemo-k8s-otel-php%25253A31085%25252Fchain%25253FtargetName%25253Djava%252526targetUrl%25253Dhttp%2525253A%2525252F%2525252Fdemo-k8s-otel-java%2525253A31082%2525252Fhello%2525253Fname%2525253Dfrom-php"
```

### 4、生成接口统计数据

```shell
for i in {1..30}; do
  curl -s "http://127.0.0.1:31082/chain?targetName=python&targetUrl=http://demo-k8s-otel-python:31083/hello?name=load-$i" >/dev/null
done
```

Tempo metrics-generator 通常需要等待十几秒生成 span metrics。

## 八、Grafana 验证

### 1、接口耗时

进入：

```text
Dashboards -> OTel -> OTel 异构接口监控
```

确认可以按服务和接口筛选：

- 吞吐量
- 错误率
- 平均耗时
- P95
- P99
- 各接口请求量和 P95 耗时

接口指标来自 Tempo 根据 Trace 生成的 RED 指标，只统计 `SPAN_KIND_SERVER`。

### 2、链路

进入 `Explore`，选择 `Tempo`：

```traceql
{ resource.service.name = "demo-k8s-otel-java" }
```

按 Duration 降序查找慢链路，打开四语言嵌套 Trace，确认 Java、Python、Go、PHP Span 使用同一个 Trace ID。

进入 Tempo 的 Service Graph，确认四个服务的调用关系、请求量、错误率和耗时。

### 3、日志

进入 `Explore`，选择 `Loki`：

```logql
{service_name=~"demo-k8s-otel-.*"}
```

只查看包含 Trace ID 的日志：

```logql
{service_name=~"demo-k8s-otel-.*"} | trace_id != ""
```

展开日志详情，确认存在 `trace_id` 和 `span_id`。

### 4、日志与链路关联

- 在 Loki 日志详情中点击 `TraceID`，跳转到 Tempo Trace。
- 在 Tempo Span 详情中点击 `Logs for this span`，跳转到 Loki 并按 Trace ID 查询日志。
- 在 Prometheus 指标存在 exemplar 时，可从耗时曲线跳转对应 Trace。

## 九、排查

### 1、通用排查

```shell
# 持续观察 Pod 状态，按 Ctrl+C 退出
kubectl get pods -n grafana-observability -w

# 查看最近事件，定位调度、镜像、PVC 和健康检查问题
kubectl get events -n grafana-observability --sort-by=.lastTimestamp | tail -30

# 深入查看具体 Pod
kubectl describe pod -n grafana-observability <pod-name>

# 查看已经启动过的容器日志
kubectl logs -n grafana-observability <pod-name> --tail=200
```

### 2、查看各组件日志

```shell
kubectl logs -n grafana-observability statefulset/tempo --tail=200
kubectl logs -n grafana-observability statefulset/loki --tail=200
kubectl logs -n grafana-observability deployment/prometheus-server --tail=200
kubectl logs -n grafana-observability deployment/otel-collector --tail=200
kubectl logs -n grafana-observability deployment/grafana --tail=200
```

实际资源类型不一致时先执行：

```shell
kubectl get deploy,statefulset -n grafana-observability
```

### 3、查看 Demo 日志

```shell
kubectl logs -n grafana-demo deploy/demo-k8s-otel-java --tail=100
kubectl logs -n grafana-demo deploy/demo-k8s-otel-python --tail=100
kubectl logs -n grafana-demo deploy/demo-k8s-otel-go -c app --tail=100
kubectl logs -n grafana-demo deploy/demo-k8s-otel-php -c app --tail=100
```

### 4、检查 Collector

```shell
kubectl get svc,endpoints -n grafana-observability otel-collector
kubectl logs -n grafana-observability deployment/otel-collector --tail=200
```

没有数据时依次检查：

1. Demo 是否指向 `otel-collector.grafana-observability.svc.cluster.local`。
2. Collector 是否开放 `4317/4318`。
3. Collector 是否能访问 `tempo:4317`、`loki:3100` 和 `prometheus-server`。
4. Java、Python 自动注入是否成功。

### 5、检查后端健康

```shell
kubectl port-forward -n grafana-observability svc/tempo 23200:3200
curl http://127.0.0.1:23200/ready
```

```shell
kubectl port-forward -n grafana-observability svc/loki 23100:3100
curl http://127.0.0.1:23100/ready
```

```shell
kubectl port-forward -n grafana-observability svc/prometheus-server 29090:80
curl http://127.0.0.1:29090/-/ready
```

检查 span metrics：

```shell
curl -G "http://127.0.0.1:29090/api/v1/query" \
  --data-urlencode 'query=traces_spanmetrics_calls_total'
```

## 十、清理

### 1、删除 Demo

```shell
kubectl delete -f demo-k8s-otel-java.yaml --ignore-not-found
kubectl delete -f demo-k8s-otel-python.yaml --ignore-not-found
kubectl delete -f demo-k8s-otel-go.yaml --ignore-not-found
kubectl delete -f demo-k8s-otel-php.yaml --ignore-not-found
kubectl delete -f instrumentation-java.yaml --ignore-not-found
kubectl delete -f instrumentation-python.yaml --ignore-not-found
```

### 2、卸载后端

```shell
helm uninstall grafana-otel -n grafana-observability --ignore-not-found
```

### 3、删除持久化数据

以下命令会删除本环境的全部 Trace、日志、指标和 Grafana 配置：

```shell
kubectl delete pvc --all -n grafana-observability
kubectl delete namespace grafana-observability --ignore-not-found
```

### 4、namespace 删除卡住

查看 namespace 删除条件：

```shell
kubectl get namespace grafana-observability -o yaml
```

列出仍然残留的资源：

```shell
kubectl api-resources --verbs=list --namespaced -o name \
  | xargs -n 1 kubectl get -n grafana-observability --ignore-not-found
```

如果确认环境已废弃，再针对报错中明确指出的残留资源检查并移除 finalizer：

```shell
kubectl get <resource-type> <resource-name> -n grafana-observability -o yaml
kubectl patch <resource-type> <resource-name> -n grafana-observability \
  --type=merge \
  -p '{"metadata":{"finalizers":[]}}'
```

不要在未确认资源用途时批量删除 finalizer。
