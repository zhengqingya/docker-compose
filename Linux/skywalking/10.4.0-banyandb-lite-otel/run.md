# Apache SkyWalking 10.4.0

分布式系统的应用程序性能监控工具，特别为微服务、云原生和基于容器(Kubernetes)架构设计。

- 官网：https://skywalking.apache.org/
- github：https://github.com/apache/skywalking
- 文档：https://skywalking.apache.org/docs/

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
- OAP PromQL: http://127.0.0.1:9090
- OTel Collector gRPC: 127.0.0.1:4317
- OTel Collector HTTP: 127.0.0.1:4318
- OTel Collector HealthCheck: http://127.0.0.1:13133
- OAP gRPC: 127.0.0.1:11800

## 推荐链路

```text
App -> OTel Collector(4317/4318) -> SkyWalking OAP(11800/12800) -> BanyanDB -> SkyWalking UI
```

## Java 标准接入

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
```

## 验证

1. 启动服务后，先确认 `http://127.0.0.1:12800/healthcheck` 返回 `200 OK`
2. 再确认 `http://127.0.0.1:13133` 返回 `Server available`
3. 启动应用并访问几次业务接口，例如 `http://127.0.0.1/time`
4. 打开 `http://127.0.0.1:18080/zipkin`，优先确认能按服务名查看 OTel traces
5. 打开 SkyWalking UI，确认服务、JVM / Runtime 指标与应用日志都能按服务维度查看
6. 不要优先用 `General-Service -> Trace` 作为 OTel traces 的验证入口；该页面更偏 SkyWalking 原生 trace 模型，OTel traces 当前优先以 `/zipkin` 作为验证入口

## 说明

- 第一版 metrics rules 先启用 `vm`，目的是优先让 JVM / Runtime 指标在 SkyWalking 中可读可展示。
- 如果后续要展示业务自定义 metrics，通常还需要继续补充 OAP 侧 otel-rules，而不是只改 Collector。
- 这套目录当前采用的是 `OTel Agent/SDK -> OTel Collector -> SkyWalking OAP` 标准 OTLP 方案。
- `9090` 端口已暴露 OAP 的 PromQL 服务，可供 Grafana 以 `Prometheus` 数据源方式读取 SkyWalking 暴露出的部分指标。
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
