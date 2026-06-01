# K8s 部署 OpenTelemetry 异构链路验证

### 一、验证目标

本目录用于验证 OTel 快速接入，并通过 OTel Collector 上报到 SkyWalking OAP。

链路目标：

```text
demo-k8s-otel-java
  -> OpenTelemetry Operator 自动注入 opentelemetry-javaagent
demo-k8s-otel-python
  -> OpenTelemetry Operator 自动注入 opentelemetry-python
demo-k8s-otel-go
  -> Go OTel SDK 显式接入
demo-k8s-otel-php
  -> PHP 手写 OTLP HTTP 上报 Span / Log
  -> Java / Go 使用 k8s 内 otel-collector.skywalking.svc.cluster.local:4317
  -> Python / PHP 使用 k8s 内 otel-collector.skywalking.svc.cluster.local:4318
  -> OTel Collector
  -> SkyWalking OAP
```

### 二、接入方式边界

| 语言 | 本示例接入方式 | 是否 Operator 自动注入 |
| --- | --- | --- |
| Java | OpenTelemetry Java Agent | 是 |
| Python | OpenTelemetry Python instrumentation | 是 |
| Go | OTel SDK 显式接入 Trace / Metrics / Logs | 否，需要代码接入 |
| PHP | 手写 OTLP HTTP 上报 Span / Log | 否，用于验证异构链路传播 |

Go 和 PHP 不依赖 Operator 自动注入。Go 侧使用 SDK 保证链路、指标和日志字段稳定；PHP 侧通过 `traceparent` 解析和 OTLP HTTP 上报验证跨语言链路传播。

### 三、前置组件安装

#### 1、安装 cert-manager

```shell
# 安装 cert-manager   https://cert-manager.io/docs/installation/
# 最新版本
# kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
# 指定版本
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.2/cert-manager.yaml

# 验证：等待 pod 都 Running
kubectl get pods -n cert-manager
# NAME                                      READY   STATUS    RESTARTS   AGE
# cert-manager-68756bcf6f-4r2h9             1/1     Running   0          31s
# cert-manager-cainjector-c664cf9b8-xsflq   1/1     Running   0          31s
# cert-manager-webhook-5749c6dc95-lkwvx     1/1     Running   0          31s
```

#### 2、安装 OpenTelemetry Operator

前提：集群中已经安装 `cert-manager`。

```shell
# 安装 OpenTelemetry Operator
kubectl apply -f https://github.com/open-telemetry/opentelemetry-operator/releases/latest/download/opentelemetry-operator.yaml

# 验证 Operator 状态
kubectl get pods -n opentelemetry-operator-system
kubectl get crd | grep -i opentelemetry
kubectl get mutatingwebhookconfigurations | grep -i opentelemetry
```

### 四、一键部署 / 删除

#### 1、一键部署

```shell
kubectl apply -f namespace.yaml
kubectl apply -f instrumentation-java.yaml
kubectl apply -f demo-k8s-otel-java.yaml
kubectl apply -f instrumentation-python.yaml
kubectl apply -f demo-k8s-otel-python.yaml
kubectl apply -f demo-k8s-otel-go.yaml
kubectl apply -f demo-k8s-otel-php.yaml
```

#### 2、一键重启

```shell
kubectl rollout restart deployment/demo-k8s-otel-java -n k8s-otel
kubectl rollout restart deployment/demo-k8s-otel-python -n k8s-otel
kubectl rollout restart deployment/demo-k8s-otel-go -n k8s-otel
kubectl rollout restart deployment/demo-k8s-otel-php -n k8s-otel
```

#### 3、一键删除

```shell
kubectl delete -f demo-k8s-otel-php.yaml
kubectl delete -f demo-k8s-otel-go.yaml
kubectl delete -f demo-k8s-otel-python.yaml
kubectl delete -f instrumentation-python.yaml
kubectl delete -f demo-k8s-otel-java.yaml
kubectl delete -f instrumentation-java.yaml
kubectl delete -f namespace.yaml
```

### 五、分语言部署与验证

#### 1、Java 服务接入

##### 1.1、接入方式说明

`instrumentation-java.yaml` 负责统一配置 OTel Java Agent：

- `exporter.endpoint`：OTel Collector 地址。
- `OTEL_SERVICE_NAME`：通过 Downward API 从 Pod 的 `app` 标签动态获取。
- `OTEL_TRACES_EXPORTER` / `OTEL_METRICS_EXPORTER` / `OTEL_LOGS_EXPORTER`：统一使用 `otlp`。
- `OTEL_INSTRUMENTATION_LOGBACK_MDC_ENABLED`：开启 Logback MDC 链路字段。

##### 1.2、部署 Java 自动注入配置和示例服务

```shell
kubectl apply -f instrumentation-java.yaml
kubectl apply -f demo-k8s-otel-java.yaml
# kubectl delete -f demo-k8s-otel-java.yaml
# kubectl rollout restart deployment/demo-k8s-otel-java -n k8s-otel
```

##### 1.3、验证 Java 自动注入是否生效

```shell
kubectl get pods -n k8s-otel -o wide
kubectl describe pod -n k8s-otel -l app=demo-k8s-otel-java
```

重点看业务容器环境变量中是否出现：

```text
JAVA_TOOL_OPTIONS
OTEL_SERVICE_NAME=demo-k8s-otel-java
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.skywalking.svc.cluster.local:4317
OTEL_INSTRUMENTATION_LOGBACK_MDC_ENABLED=true
```

##### 1.4、请求 Java 接口

```shell
curl http://127.0.0.1:30082/hello
curl "http://127.0.0.1:30082/chain?targetName=python"
curl "http://127.0.0.1:30082/chain?targetName=python&targetUrl=http://demo-k8s-otel-python:30083/hello?name=from-java"
```

##### 1.5、查看 Java 日志链路信息

```shell
kubectl logs -n k8s-otel deploy/demo-k8s-otel-java --tail=20 -f
```

正常会看到类似：

```text
[trace_id=xxx span_id=xxx trace_flags=xx]
```

#### 2、Python 服务接入

##### 2.1、接入方式说明

`instrumentation-python.yaml` 负责统一配置 OTel Python Agent：

- `exporter.endpoint`：OTel Collector 地址。
- `OTEL_EXPORTER_OTLP_PROTOCOL`：Python 使用 `http/protobuf`，对应 Collector 的 `4318` 端口。
- `OTEL_SERVICE_NAME`：通过 Downward API 从 Pod 的 `app` 标签动态获取。
- `OTEL_PYTHON_LOG_CORRELATION`：开启 Python 日志链路字段注入。

##### 2.2、部署 Python 自动注入配置和示例服务

```shell
kubectl apply -f instrumentation-python.yaml
kubectl apply -f demo-k8s-otel-python.yaml
# kubectl delete -f demo-k8s-otel-python.yaml
# kubectl rollout restart deployment/demo-k8s-otel-python -n k8s-otel
```

##### 2.3、验证 Python 自动注入是否生效

```shell
kubectl get pods -n k8s-otel -o wide
kubectl describe pod -n k8s-otel -l app=demo-k8s-otel-python
```

重点看业务容器环境变量中是否出现：

```text
OTEL_SERVICE_NAME=demo-k8s-otel-python
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.skywalking.svc.cluster.local:4318
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_PYTHON_LOG_CORRELATION=true
```

##### 2.4、请求 Python 接口

```shell
curl http://127.0.0.1:30083/hello
curl "http://127.0.0.1:30083/chain?targetName=java"
curl "http://127.0.0.1:30083/chain?targetName=java&targetUrl=http://demo-k8s-otel-java:30082/hello?name=from-python"
```

##### 2.5、查看 Python 日志链路信息

```shell
kubectl logs -n k8s-otel deploy/demo-k8s-otel-python --tail=20 -f
```

正常会看到类似：

```text
[trace_id=xxx span_id=xxx trace_flags=xx]
```

#### 3、Go 服务接入

##### 3.1、接入方式说明

Go 服务不使用 Operator Go eBPF 自动注入，本示例改为在项目中通过 OTel SDK 显式接入：

- HTTP Server：使用 `otelhttp.NewHandler(...)` 创建服务端 Span。
- HTTP Client：使用 `otelhttp.NewTransport(...)` 传播链路上下文。
- Metrics：使用 `MeterProvider` 和 `otlpmetricgrpc` 上报 HTTP Server/Client 指标。
- Logs：使用 `otlploggrpc` 和 `otelslog` 上报带链路上下文的日志。
- 日志：通过 `slog.Handler` 包装器自动追加 `trace_id`、`span_id`、`trace_flags`。

##### 3.2、部署 Go 示例服务

```shell
kubectl apply -f demo-k8s-otel-go.yaml
# kubectl delete -f demo-k8s-otel-go.yaml
# kubectl rollout restart deployment/demo-k8s-otel-go -n k8s-otel
```

##### 3.3、验证 Go SDK 接入配置

```shell
kubectl get pods -n k8s-otel -o wide
kubectl describe pod -n k8s-otel -l app=demo-k8s-otel-go
```

重点看业务容器环境变量中是否出现：

```text
OTEL_SERVICE_NAME=demo-k8s-otel-go
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.skywalking.svc.cluster.local:4317
OTEL_EXPORTER_OTLP_PROTOCOL=grpc
OTEL_METRIC_EXPORT_INTERVAL=10000
```

##### 3.4、请求 Go 接口

```shell
curl http://127.0.0.1:30084/hello
curl "http://127.0.0.1:30084/chain?targetName=python"
curl "http://127.0.0.1:30084/chain?targetName=python&targetUrl=http://demo-k8s-otel-python:30083/hello?name=from-go"
```

##### 3.5、查看 Go 日志链路信息

```shell
kubectl logs -n k8s-otel deploy/demo-k8s-otel-go -c app --tail=20 -f
```

正常会看到类似：

```text
"trace_id":"xxx","span_id":"xxx","trace_flags":"01"
```

#### 4、PHP 服务接入

##### 4.1、接入方式说明

PHP 服务当前不使用 Operator 自动注入，本示例通过项目内 `Otel.php` 手写 OTLP HTTP 上报：

- `/hello`：创建服务端 Span，并上报日志。
- `/chain`：可选传入 `targetUrl` 请求下游服务，创建客户端 Span。
- 日志：打印 `trace_id` / `span_id`，并通过 OTLP HTTP 上报 Log。
- 透传：请求下游服务时使用当前客户端 Span 生成 `traceparent`。

##### 4.2、部署 PHP 示例服务

```shell
kubectl apply -f demo-k8s-otel-php.yaml
# kubectl delete -f demo-k8s-otel-php.yaml
# kubectl rollout restart deployment/demo-k8s-otel-php -n k8s-otel
```

##### 4.3、验证 PHP OTel 配置

```shell
kubectl get pods -n k8s-otel -o wide
kubectl describe pod -n k8s-otel -l app=demo-k8s-otel-php
```

重点看业务容器环境变量中是否出现：

```text
OTEL_SERVICE_NAME=demo-k8s-otel-php
OTEL_EXPORTER_OTLP_ENDPOINT=http://otel-collector.skywalking.svc.cluster.local:4318
```

##### 4.4、请求 PHP 接口

```shell
curl http://127.0.0.1:30085/hello
curl "http://127.0.0.1:30085/chain?targetName=java"
curl "http://127.0.0.1:30085/chain?targetName=java&targetUrl=http://demo-k8s-otel-java:30082/hello?name=from-php"
```

##### 4.5、查看 PHP 日志链路信息

```shell
kubectl logs -n k8s-otel deploy/demo-k8s-otel-php -c app --tail=20 -f
```

正常会看到类似：

```text
[service=demo-k8s-otel-php trace_id=xxx span_id=xxx] info hello request, name=php
```

### 六、单服务请求

```shell
# 请求 Java 服务 demo-k8s-otel-java
curl http://127.0.0.1:30082/hello

# 请求 Python 服务 demo-k8s-otel-python
curl http://127.0.0.1:30083/hello

# 请求 Go 服务 demo-k8s-otel-go
curl http://127.0.0.1:30084/hello

# 请求 PHP 服务 demo-k8s-otel-php
curl http://127.0.0.1:30085/hello
```

### 七、验证 Java -> Python -> Go -> PHP -> Java 闭环链路

```shell
curl -s "http://127.0.0.1:30082/chain?targetName=python&targetUrl=http%3A%2F%2Fdemo-k8s-otel-python%3A30083%2Fchain%3FtargetName%3Dgo%26targetUrl%3Dhttp%253A%252F%252Fdemo-k8s-otel-go%253A30084%252Fchain%253FtargetName%253Dphp%2526targetUrl%253Dhttp%25253A%25252F%25252Fdemo-k8s-otel-php%25253A30085%25252Fchain%25253FtargetName%25253Djava%252526targetUrl%25253Dhttp%2525253A%2525252F%2525252Fdemo-k8s-otel-java%2525253A30082%2525252Fhello%2525253Fname%2525253Dfrom-php" | jq
```

链路方向：

```text
curl
  -> demo-k8s-otel-java
  -> demo-k8s-otel-python
  -> demo-k8s-otel-go
  -> demo-k8s-otel-php
  -> demo-k8s-otel-java
```

### 八、SkyWalking 中查看

OTel 方式接入后，优先查看：

- `http://127.0.0.1:18080/zipkin`
- SkyWalking 常规服务中的 `demo-k8s-otel-java`
- SkyWalking 常规服务中的 `demo-k8s-otel-python`
- SkyWalking 常规服务中的 `demo-k8s-otel-go`
- SkyWalking 常规服务中的 `demo-k8s-otel-php`

JVM / Runtime Metrics 建议继续使用 Prometheus + Grafana 查看。
