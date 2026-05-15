# Apache SkyWalking 10.4.0

分布式系统的应用程序性能监控工具，特别为微服务、云原生和基于容器(Kubernetes)架构设计。

- 官网：https://skywalking.apache.org/
- github：https://github.com/apache/skywalking
- 文档：https://skywalking.apache.org/docs/
- OpenTelemetry：https://opentelemetry.io/zh/

### 当前方案

这是一个偏 **低内存** 的 `10.4.0` 单机部署方案，并额外集成了 `OTel Collector` 作为统一接入入口：

- 存储使用 `BanyanDB`，不再引入 `Elasticsearch`
- 当前 `BanyanDB` 镜像版本使用 `0.10.1`
- OAP 堆内存先压到 `512m`
- OTel 数据统一先进入 `OTel Collector`，再转发到 `SkyWalking OAP`
- 第一版同时打通 `OTel traces / metrics / logs`
- BanyanDB 写入并发和 shard 数量做了保守配置
- 适合本地测试、PoC、小流量环境

如果你的机器内存比较紧张，这套通常会比 `Elasticsearch` 方案更省内存；如果你的目标是验证异构语言统一通过 `OTLP` 接入 SkyWalking，这套也比纯原生 agent 方案更贴近后续标准化演进方向。

# 运行说明

## 启动

```bash
# 启动
docker compose up -d

# 停止并删除容器、网络
docker compose down
```

## 访问

- SkyWalking UI: http://127.0.0.1:18080
- Zipkin Trace UI: http://127.0.0.1:18080/zipkin
- OAP HealthCheck: http://127.0.0.1:12800/healthcheck
- OTel Collector gRPC: 127.0.0.1:4317
- OTel Collector HTTP: 127.0.0.1:4318
- OTel Collector HealthCheck: http://127.0.0.1:13133
- OAP gRPC: 127.0.0.1:11800

## 推荐链路

```text
App -> OTel Collector(4317/4318) -> SkyWalking OAP(11800/12800) -> BanyanDB -> SkyWalking UI
```

## Java 标准接入

下载`opentelemetry-javaagent.jar` https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases
eg: https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/download/v2.27.0/opentelemetry-javaagent.jar

JVM 参数：

```shell
-javaagent:/data/opentelemetry-javaagent.jar
-Dotel.service.name=demo-skywalking-otel
-Dotel.resource.attributes=deployment.environment=dev,service.namespace=default
-Dotel.traces.exporter=otlp
-Dotel.metrics.exporter=otlp
-Dotel.logs.exporter=otlp
-Dotel.exporter.otlp.protocol=grpc
-Dotel.exporter.otlp.endpoint=http://127.0.0.1:4317
-Dotel.metric.export.interval=10000
```

补充说明：

- `JVM runtime metrics` 例如 CPU、内存、GC、线程，`opentelemetry-javaagent.jar` 默认就会采集，不需要额外增加 `otel.jmx.target.system`。
- `otel.jmx.target.system` / `otel.jmx.config` 只用于采集 Tomcat、Jetty 或自定义 MBean 这类 JMX 指标。

## 验证

1. 启动服务后，先确认 `http://127.0.0.1:12800/healthcheck` 返回 `200 OK`
2. 再确认 `http://127.0.0.1:13133` 返回 `Server available`
3. 启动应用并访问几次业务接口，例如 `http://127.0.0.1/time`
4. 打开 `http://127.0.0.1:18080/zipkin`，优先确认能按服务名查看 OTel traces
5. 打开 SkyWalking UI，确认服务、OTel metrics 与应用日志都能按服务维度查看
6. 不要优先用 `General-Service -> Trace` 作为 OTel traces 的验证入口；该页面更偏 SkyWalking 原生 trace 模型，OTel traces 当前优先以 `/zipkin` 作为验证入口

## 说明

- 当前 OAP 不再强制覆盖 `SW_OTEL_RECEIVER_ENABLED_OTEL_METRICS_RULES`，而是回退到 SkyWalking 官方默认的 OTel metrics rules。
- `vm` 是 Linux / node-exporter 的主机监控规则，不是 Java `JVM runtime metrics` 规则，不能把它当作 OTel Java JVM 面板开关使用。
- 继续走 OTel 时，可以在 SkyWalking 中看服务、实例、Endpoint、日志以及 OTel metrics，但不要期待它和 SkyWalking 原生 Java Agent 的 `JVM` 页完全等价。
- 如果后续要展示业务自定义 metrics，通常还需要继续补充 OAP 侧 otel-rules，而不是只改 Collector。
- 这套目录当前采用的是 `OTel Agent/SDK -> OTel Collector -> SkyWalking OAP` 标准 OTLP 方案。
- OAP 的 `9090` PromQL 端口当前先不对宿主机暴露，避免与独立 Prometheus 的 `9090` 冲突；如需验证 SkyWalking PromQL，再手动取消 compose 里的端口注释。
- `13133` 端口用于 OTel Collector 的 health_check 扩展，便于排查 Collector 是否真正 ready。
- 在 SkyWalking 中，OTel traces 会转换为 Zipkin trace 模型，因此正确查看入口是 UI 的 `/zipkin` 或 Zipkin Trace 相关菜单，而不是 `General-Service -> Trace` 原生页。
- SkyWalking 原生 UI 中的 `General-Service -> Trace` 更适合 SkyWalking 原生 agent / trace 模型；如果你的目标是直接在原生 Trace 页查看链路，应改用 SkyWalking 原生 agent 探针方式接入。
- 日志与指标仍然通过 SkyWalking 自身的 Log / Metrics 页面查看，不受 Zipkin Trace UI 入口影响。

---

结论：
- SkyWalking 原生 agent 更适合在 SkyWalking 原生页面看链路
- OTel 也能看链路，但在 SkyWalking 里通常走的是 Zipkin/Lens 这套查询入口。https://skywalking.apache.org/docs/main/v10.4.0/en/setup/backend/otlp-trace/

即分为2步查看数据
- 看链路：http://127.0.0.1:18080/zipkin
- 看日志：SkyWalking 原来的 Log 页面

![](./images/run-1776329793561.png)

# otel 服务指标说明

skywalking中无法展示相关服务指标
![](./images/run-1778843250179.png)

可以通过 [Grafana+Prometheus](../../prometheus/v3.11.2-prometheus-grafana-otel) 去查看指标
![](./images/run-1778843284228.png)

可在 Grafana 以下 Dashboard ID 查看数据
JMX Overview (OpenTelemetry): [`17582`](https://grafana.com/grafana/dashboards/17582-jmx-overview-opentelemetry/)
![](./images/run-1778843533669.png)
